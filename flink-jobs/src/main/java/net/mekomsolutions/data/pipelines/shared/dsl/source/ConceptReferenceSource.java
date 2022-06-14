package net.mekomsolutions.data.pipelines.shared.dsl.source;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * This class represents a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Source table</a>
 * Mapping to OpenMRS ConceptReferenceSource class
 */
public class ConceptReferenceSource implements TableSQLDSL {
    private Map<String, String> connectorOptions;
    public ConceptReferenceSource(Map<String, String> connectorOptions) {
        if(Objects.equals(connectorOptions.get("connector"), "kafka")){
            connectorOptions.put("topic","openmrs.openmrs.concept_reference_source");
        }else{
            connectorOptions.put("table-name","concept_reference_source");
        }
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return concept_reference_source source table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE `concept_reference_source` (\n" +
                "  `concept_source_id` int primary key,\n" +
                "  `name` VARCHAR,\n" +
                "  `description` VARCHAR,\n" +
                "  `hl7_code` VARCHAR,\n" +
                "  `creator` int,\n" +
                "  `date_created` TIMESTAMP,\n" +
                "  `retired` BOOLEAN,\n" +
                "  `retired_by` int,\n" +
                "  `date_retired` TIMESTAMP,\n" +
                "  `retire_reason` VARCHAR,\n" +
                "  `uuid` char,\n" +
                "  `unique_id` VARCHAR,\n" +
                "  `date_changed` TIMESTAMP,\n" +
                "  `changed_by` int\n" +
                ")" +
                " WITH (\n" +
                    ConnectorUtils.propertyJoiner(",","=").apply(this.connectorOptions) +
                ")";
    }

}
