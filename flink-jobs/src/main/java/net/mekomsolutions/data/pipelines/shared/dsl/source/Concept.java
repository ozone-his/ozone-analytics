package net.mekomsolutions.data.pipelines.shared.dsl.source;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * This class represents a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Source table</a>
 * Mapping to OpenMRS Concept class
 * @return
 */
public class Concept implements TableSQLDSL {
    private Map<String, String> connectorOptions;

    public Concept(Map<String, String> connectorOptions) {

        if(Objects.equals(connectorOptions.get("connector"), "kafka")){
            connectorOptions.put("topic","openmrs.openmrs.concept");
        }else{
            connectorOptions.put("table-name","concept");
        }
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return concept source table DSL
     */
    @Override
    public String getDSL() {

        return "CREATE TABLE `concept` (\n" +
                "  `concept_id` int primary key,\n" +
                "  `retired` BOOLEAN,\n" +
                "  `short_name` VARCHAR,\n" +
                "  `description` VARCHAR,\n" +
                "  `form_text` VARCHAR,\n" +
                "  `datatype_id` int,\n" +
                "  `class_id` int,\n" +
                "  `is_set` BOOLEAN,\n" +
                "  `creator` int,\n" +
                "  `date_created` TIMESTAMP,\n" +
                "  `version` VARCHAR,\n" +
                "  `changed_by` int,\n" +
                "  `date_changed` TIMESTAMP,\n" +
                "  `retired_by` int,\n" +
                "  `date_retired` TIMESTAMP,\n" +
                "  `retire_reason` VARCHAR,\n" +
                "  `uuid` char\n" +
                ")" +
                " WITH (\n" +
                    ConnectorUtils.propertyJoiner(",","=").apply(this.connectorOptions) +
                ")";
    }
}
