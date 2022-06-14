package net.mekomsolutions.data.pipelines.shared.dsl.sink.jdbc;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * This creates a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Sink table</a>
 * For flattening OpenMRS Concepts
 */
public class Concepts implements TableSQLDSL {
    private Map<String, String> connectorOptions;
    public Concepts(Map<String, String> connectorOptions) {
        if(!Objects.equals(connectorOptions.get("connector"), "filesystem")){
            connectorOptions.put("table-name","concepts");
        }else{
            connectorOptions.put("path","/tmp/analytics/concepts");
        }
        this.connectorOptions = connectorOptions;
    }



    /**
     * @return concepts table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE concepts (\n" +
                "    concept_id BIGINT PRIMARY KEY,\n" +
                "    concept_mapping_source VARCHAR,\n" +
                "    concept_mapping_code VARCHAR,\n" +
                "    concept_mapping_name VARCHAR,\n" +
                "    name VARCHAR,\n" +
                "    locale VARCHAR,\n" +
                "    locale_preferred BOOLEAN,\n" +
                "    retired BOOLEAN,\n" +
                "    uuid VARCHAR\n" +
                ")\n" +
                "WITH (\n" +
                ConnectorUtils.propertyJoiner(",", "=").apply(this.connectorOptions) +
                ")";
    }
}