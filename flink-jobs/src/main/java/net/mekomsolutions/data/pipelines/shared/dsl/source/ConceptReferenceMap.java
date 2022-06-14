package net.mekomsolutions.data.pipelines.shared.dsl.source;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * This class represents a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Source table</a>
 * Mapping to OpenMRS ConceptReferenceMap class
 */
public class ConceptReferenceMap implements TableSQLDSL {
    private Map<String, String> connectorOptions;
    public ConceptReferenceMap(Map<String, String> connectorOptions) {
        if(Objects.equals(connectorOptions.get("connector"), "kafka")){
            connectorOptions.put("topic","openmrs.openmrs.concept_reference_map");
        }else{
            connectorOptions.put("table-name","concept_reference_map");
        }
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return concept_reference_map source table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE `concept_reference_map` (\n" +
                "  `concept_map_id` int primary key,\n" +
                "  `concept_reference_term_id` int,\n" +
                "  `concept_map_type_id` int,\n" +
                "  `creator` int,\n" +
                "  `date_created` TIMESTAMP,\n" +
                "  `concept_id` int,\n" +
                "  `changed_by` int,\n" +
                "  `date_changed` TIMESTAMP ,\n" +
                "  `uuid` char\n" +
                ")" +
                "  " +
                "WITH (\n" +
                    ConnectorUtils.propertyJoiner(",","=").apply(this.connectorOptions) +
                ")";
    }
}
