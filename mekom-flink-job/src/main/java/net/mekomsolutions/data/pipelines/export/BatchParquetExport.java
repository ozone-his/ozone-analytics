package net.mekomsolutions.data.pipelines.export;

import net.mekomsolutions.data.pipelines.shared.dsl.TableDSLFactory;
import net.mekomsolutions.data.pipelines.utils.CommonUtils;
import org.apache.flink.api.java.utils.ParameterTool;
import org.apache.flink.table.api.EnvironmentSettings;
import org.apache.flink.table.api.TableEnvironment;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class BatchParquetExport {
    public static void main(String[] args) throws Exception {
        EnvironmentSettings settings = EnvironmentSettings
                .newInstance()
                .inBatchMode()
                .build();
        TableEnvironment tEnv = TableEnvironment.create(settings);
        final ParameterTool parameterTool = ParameterTool.fromArgs(args);
        Map<String, String> postgresConnectorOptions = Stream.of(new String[][]{
                {"connector", "jdbc"},
                {"url", parameterTool.get("jdbc-url", "")},
                {"username", parameterTool.get("jdbc-username", "")},
                {"password", parameterTool.get("jdbc-password", "")},
                {"sink.buffer-flush.max-rows", "1000"},
                {"sink.buffer-flush.interval", "1s"}
        }).collect(Collectors.toMap(data -> data[0], data -> data[1]));

        final Map<String, String> fileSystemConnectorOptions = Stream.of(new String[][]{
                {"connector", "filesystem"},
                {"format", "parquet"},
                {"path", parameterTool.get("output-dir", "/tmp/")},
        }).collect(Collectors.toMap(data -> data[0], data -> data[1]));

        String[] sourceTables =  {"visits", "patients", "concepts", "observations"};

        CommonUtils.setupTables(tEnv, sourceTables, postgresConnectorOptions);


        String outPutPath = parameterTool.get("output-dir", "/tmp/")
                                            .replaceAll("([^/])$","$1/");
        String locationTag = parameterTool.get("location-tag", "");
        String date = DateTimeFormatter.ISO_LOCAL_DATE_TIME.format(LocalDateTime.now());

        fileSystemConnectorOptions.put("path",outPutPath+"/observations/"+locationTag+"/"+date);
        TableDSLFactory tableDSLFactorySink = new TableDSLFactory(fileSystemConnectorOptions);
        tEnv.executeSql(tableDSLFactorySink.getTable("observations_fs").getDSL());

        fileSystemConnectorOptions.put("path",outPutPath+"/patients/"+locationTag+"/"+date);
        TableDSLFactory tableDSLFactorySinkPatients = new TableDSLFactory(fileSystemConnectorOptions);
        tEnv.executeSql(tableDSLFactorySinkPatients.getTable("patients_fs").getDSL());

        fileSystemConnectorOptions.put("path",outPutPath+"/concepts/"+locationTag+"/"+date);
        TableDSLFactory tableDSLFactorySinkConcepts = new TableDSLFactory(fileSystemConnectorOptions);
        tEnv.executeSql(tableDSLFactorySinkConcepts.getTable("concepts_fs").getDSL());

        fileSystemConnectorOptions.put("path",outPutPath+"/visits/"+locationTag+"/"+date);
        TableDSLFactory tableDSLFactorySinkVisits = new TableDSLFactory(fileSystemConnectorOptions);
        tEnv.executeSql(tableDSLFactorySinkVisits.getTable("visits_fs").getDSL());

        tEnv.executeSql("INSERT into observations_fs SELECT o.*  from observations o");
        tEnv.executeSql("INSERT into concepts_fs SELECT c.*  from concepts c");
        tEnv.executeSql("INSERT into patients_fs SELECT p.* from patients p");
        tEnv.executeSql("INSERT into visits_fs SELECT v.*  from visits v");
    }
}
