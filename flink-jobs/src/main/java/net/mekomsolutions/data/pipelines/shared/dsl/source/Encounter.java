package net.mekomsolutions.data.pipelines.shared.dsl.source;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * This class represents a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Source table</a>
 * Mapping to OpenMRS Encounter class
 */
public class Encounter implements TableSQLDSL {
    private Map<String, String> connectorOptions;
    public Encounter(Map<String, String> connectorOptions) {
        if(Objects.equals(connectorOptions.get("connector"), "kafka")){
            connectorOptions.put("topic","openmrs.openmrs.encounter");
        }else{
            connectorOptions.put("table-name","encounter");
        }
        this.connectorOptions = connectorOptions;
    }

    @Override
    /**
     * @return encounter source table DSL
     */
    public String getDSL() {
        return "CREATE TABLE `encounter` (\n" +
                "  `encounter_id` int primary key,\n" +
                "  `encounter_type` int,\n" +
                "  `patient_id` int,\n" +
                "  `location_id` int,\n" +
                "  `form_id` int,\n" +
                "  `encounter_datetime` TIMESTAMP,\n" +
                "  `creator` int,\n" +
                "  `date_created` TIMESTAMP,\n" +
                "  `voided` BOOLEAN,\n" +
                "  `voided_by` int,\n" +
                "  `date_voided` TIMESTAMP,\n" +
                "  `void_reason` VARCHAR,\n" +
                "  `changed_by` int,\n" +
                "  `date_changed` TIMESTAMP,\n" +
                "  `visit_id` int,\n" +
                "  `uuid` char)" +
                " WITH (\n" +
                    ConnectorUtils.propertyJoiner(",","=").apply(this.connectorOptions) +
                ")";
    }

}
