/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package net.mekomsolutions.data.pipelines.streaming;

import com.fasterxml.jackson.databind.ObjectMapper;
import net.mekomsolutions.data.pipelines.shared.dsl.TableDSLFactory;
import net.mekomsolutions.data.pipelines.shared.jobs.Job;
import org.apache.flink.api.java.utils.ParameterTool;
import org.apache.flink.table.api.EnvironmentSettings;
import org.apache.flink.table.api.StatementSet;
import org.apache.flink.table.api.TableEnvironment;
//import org.apache.logging.slf4j.Log4jLoggerFactory;
//import org.slf4j.Logger;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;


/**
 * Flink Job Mekom ETL pipelines iy offers both Batch and Streaming options you can select the mode in the job.properties
 * file by setting job.streaming=true/false
 * <p>For a tutorial how to write a Flink streaming application, check the
 * tutorials and examples on the <a href="https://flink.apache.org/docs/stable/">Flink Website</a>.
 *
 * <p>To package your application into a JAR file for execution, run
 * 'mvn clean package' on the command line.
 *
 * <p>If you change the name of the main class (with the public static void main(String[] args))
 * method, change the respective entry in the POM.xml file (simply search for 'mainClass').
 */
public class StreamingETLJob {
    //private static final Logger LOG = new Log4jLoggerFactory().getLogger(StreamingETLJob.class.getName());

    public static void main(String[] args) throws Exception {
        String propertiesFilePath = System.getProperty("user.dir") + "/job.properties";
        final ParameterTool parameterTool = ParameterTool.fromArgs(args);
        propertiesFilePath = parameterTool.get("properties-file", "/opt/flink/usrlib/job.properties");
        ParameterTool parameter = ParameterTool.fromPropertiesFile(propertiesFilePath);
        boolean streaming = Boolean.parseBoolean(parameter.get("job.streaming", "true"));
        Map<String, String> openmrsConnectorOptions = Stream.of(new String[][]{
                {"connector", "jdbc"},
                {"url", parameter.get("openmrs.database.batch.url", "")},
                {"username", parameter.get("openmrs.database.username", "")},
                {"password", parameter.get("openmrs.database.password", "")},
        }).collect(Collectors.toMap(data -> data[0], data -> data[1]));
        Map<String, String> postgresConnectorOptions = Stream.of(new String[][]{
                {"connector", "jdbc"},
                {"url", parameterTool.get("sink-url", "")},
                {"username", parameterTool.get("sink-username", "")},
                {"password", parameterTool.get("sink-password", "")},
                {"sink.buffer-flush.max-rows", "1000"},
                {"sink.buffer-flush.interval", "1s"}
        }).collect(Collectors.toMap(data -> data[0], data -> data[1]));

        Map<String, String> fileSystemConnectorOptions = Stream.of(new String[][]{
                {"connector", "filesystem"},
                {"format", "parquet"},
                {"sink.partition-commit.delay", "1 h"},
                {"sink.partition-commit.policy.kind", "success-file"}
        }).collect(Collectors.toMap(data -> data[0], data -> data[1]));


        EnvironmentSettings settings = EnvironmentSettings
                .newInstance()
                .inBatchMode()
                .build();

        if (streaming) {
            settings = EnvironmentSettings
                    .newInstance()
                    .inStreamingMode()
                    .build();
            openmrsConnectorOptions = Stream.of(new String[][]{
                    {"connector", "kafka"},
                    {"properties.bootstrap.servers" ,parameter.get("properties.bootstrap.servers", "")},
                    {"scan.startup.mode" ,"earliest-offset"},
                    {"value.format" ,"debezium-json"},
                    {"value.debezium-json.ignore-parse-errors", "true"},
            }).collect(Collectors.toMap(data -> data[0], data -> data[1]));
        }

        TableEnvironment tEnv = TableEnvironment.create(settings);
        tEnv.getConfig().getConfiguration().setString("restart-strategy", "exponential-delay");
        //set the checkpoint mode to EXACTLY_ONCE
        if (streaming) {
            tEnv.getConfig().getConfiguration().setString("execution.checkpointing.mode", "EXACTLY_ONCE");
            tEnv.getConfig().getConfiguration().setString("execution.checkpointing.interval", "10min");
            tEnv.getConfig().getConfiguration().setString("execution.checkpointing.timeout", "10min");
            tEnv.getConfig().getConfiguration().setString("execution.checkpointing.unaligned", "true");
            tEnv.getConfig().getConfiguration().setString("execution.checkpointing.tolerable-failed-checkpoints", "400");
            tEnv.getConfig().getConfiguration().setString("table.dynamic-table-options.enabled", "true");
            tEnv.getConfig().getConfiguration().setString("state.backend", "rocksdb");
            tEnv.getConfig().getConfiguration().setString("state.backend.incremental", "true");
            tEnv.getConfig().getConfiguration().setString("state.checkpoints.dir", "file:///tmp/checkpoints/");
            tEnv.getConfig().getConfiguration().setString("state.savepoints.dir", "file:///tmp/savepoints/");
        }



        // set the statebackend type to "rocksdb", other available options are "filesystem" and "jobmanager"
        // you can also set the full qualified Java class name of the StateBackendFactory to this option
        // e.g. org.apache.flink.contrib.streaming.state.RocksDBStateBackendFactory
        tEnv.getConfig().getConfiguration().setString("taskmanager.network.numberOfBuffers", "20");
        tEnv.getConfig()        // access high-level configuration
                .getConfiguration()   // set low-level key-value options
                .setString("table.exec.resource.default-parallelism", "6");
        // set the checkpoint directory, which is required by the RocksDB statebackend


        String[] sourceTables = {"person", "person_name", "person_address", "patient", "patient_identifier", "patient_identifier_type", "visit", "visit_type", "concept", "concept_name", "concept_reference_map",
                "concept_reference_term", "concept_reference_source", "obs", "encounter", "encounter_type", "location"};
        String[] sinkTables = {"visits", "patients", "concepts", "observations"};
        setupSourceTables(tEnv, sourceTables, openmrsConnectorOptions);
        setupSinkTables(tEnv, sinkTables, postgresConnectorOptions);
        final ObjectMapper objectMapper = new ObjectMapper();
        Job[] jobs = objectMapper.readValue(getResourceFileAsString("jobs.json"), Job[].class);
        StatementSet stmtSet = tEnv.createStatementSet();
            for (Job job : jobs) {
                String queryDSL = "INSERT INTO " + job.getName() + " \n" + getResourceFileAsString(job.getSourceFilePath());
                stmtSet.addInsertSql(queryDSL);
            }

        stmtSet.execute();
    }

    private static void setupSourceTables(TableEnvironment tableEnv, String[] tables, Map<String, String> connectorOptions) {
        TableDSLFactory tableDSLFactory = new TableDSLFactory(connectorOptions);
        for (String tableName : tables) {
            tableEnv.executeSql(tableDSLFactory.getTable(tableName).getDSL());
        }
    }

    private static void setupSinkTables(TableEnvironment tableEnv, String[] tables, Map<String, String> connectorOptions) {
        TableDSLFactory tableDSLFactory = new TableDSLFactory(connectorOptions);
        for (String tableName : tables) {
            tableEnv.executeSql(tableDSLFactory.getTable(tableName).getDSL());
        }
    }

    private static String getResourceFileAsString(String fileName) throws IOException {
        try (InputStream is = StreamingETLJob.class.getResourceAsStream("/" + fileName)) {
            if (is == null) return null;
            try (InputStreamReader isr = new InputStreamReader(is);
                 BufferedReader reader = new BufferedReader(isr)) {
                return reader.lines().collect(Collectors.joining(System.lineSeparator()));
            }
        }
    }

}
