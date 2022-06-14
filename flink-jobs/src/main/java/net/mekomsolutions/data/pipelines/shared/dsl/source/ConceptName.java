package net.mekomsolutions.data.pipelines.shared.dsl.source;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * his class represents a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Source table</a>
 * Mapping to OpenMRS ConceptName class
 */
public class ConceptName implements TableSQLDSL {
    private Map<String, String> connectorOptions;

    public ConceptName(Map<String, String> connectorOptions) {
        if(Objects.equals(connectorOptions.get("connector"), "kafka")){
            connectorOptions.put("topic","openmrs.openmrs.concept_name");
        }else{
            connectorOptions.put("table-name","concept_name");
        }
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return concept_name source table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE `concept_name` (\n" +
                "  `concept_name_id` int primary key,\n" +
                "  `concept_id` int,\n" +
                "  `name` VARCHAR,\n" +
                "  `locale` VARCHAR,\n" +
                "  `locale_preferred` BOOLEAN,\n" +
                "  `creator` int,\n" +
                "  `date_created` TIMESTAMP,\n" +
                "  `concept_name_type` VARCHAR,\n" +
                "  `voided` BOOLEAN,\n" +
                "  `voided_by` int,\n" +
                "  `date_voided` TIMESTAMP,\n" +
                "  `void_reason` VARCHAR,\n" +
                "  `uuid` char,\n" +
                "  `date_changed` TIMESTAMP,\n" +
                "  `changed_by` int\n" +
                ")\n" +
                "  " +
                "WITH (\n" +
                    ConnectorUtils.propertyJoiner(",","=").apply(this.connectorOptions) +
                ")";
    }

}
