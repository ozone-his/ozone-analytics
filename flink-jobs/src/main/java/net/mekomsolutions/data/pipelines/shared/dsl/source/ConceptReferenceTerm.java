package net.mekomsolutions.data.pipelines.shared.dsl.source;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * This class represents a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Source table</a>
 * Mapping to OpenMRS ConceptReferenceTerm class
 */
public class ConceptReferenceTerm implements TableSQLDSL {
    private Map<String, String> connectorOptions;
    public ConceptReferenceTerm(Map<String, String> connectorOptions) {
        if(Objects.equals(connectorOptions.get("connector"), "kafka")){
            connectorOptions.put("topic","openmrs.openmrs.concept_reference_term");
        }else{
            connectorOptions.put("table-name","concept_reference_term");
        }
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return concept_reference_term source table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE `concept_reference_term` (\n" +
                "  `concept_reference_term_id` int primary key,\n" +
                "  `concept_source_id` int,\n" +
                "  `name` VARCHAR,\n" +
                "  `code` VARCHAR,\n" +
                "  `version` VARCHAR,\n" +
                "  `description` VARCHAR,\n" +
                "  `creator` int,\n" +
                "  `date_created` TIMESTAMP,\n" +
                "  `date_changed` TIMESTAMP,\n" +
                "  `changed_by` int,\n" +
                "  `retired` BOOLEAN,\n" +
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
