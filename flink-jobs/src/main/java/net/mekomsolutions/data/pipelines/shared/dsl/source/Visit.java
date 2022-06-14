package net.mekomsolutions.data.pipelines.shared.dsl.source;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * This class represents a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Source table</a>
 * Mapping to OpenMRS Visit class
 */
public class Visit implements TableSQLDSL {
    private Map<String, String> connectorOptions;
    public Visit(Map<String, String> connectorOptions) {
        if(Objects.equals(connectorOptions.get("connector"), "kafka")){
            connectorOptions.put("topic","openmrs.openmrs.visit");
        }else{
            connectorOptions.put("table-name","visit");
        }
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return visit source table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE `visit` (\n" +
                "  `visit_id` int primary key,\n" +
                "  `patient_id` int,\n" +
                "  `visit_type_id` int,\n" +
                "  `date_started` TIMESTAMP,\n" +
                "  `date_stopped` TIMESTAMP,\n" +
                "  `indication_concept_id` int,\n" +
                "  `location_id` int,\n" +
                "  `creator` int,\n" +
                "  `date_created` TIMESTAMP,\n" +
                "  `changed_by` int,\n" +
                "  `date_changed` TIMESTAMP,\n" +
                "  `voided` BOOLEAN,\n" +
                "  `voided_by` int,\n" +
                "  `date_voided` TIMESTAMP,\n" +
                "  `void_reason` VARCHAR,\n" +
                "  `uuid` VARCHAR\n" +
                ") " +
                "WITH (\n" +
                    ConnectorUtils.propertyJoiner(",","=").apply(this.connectorOptions) +
                ")";
    }

}
