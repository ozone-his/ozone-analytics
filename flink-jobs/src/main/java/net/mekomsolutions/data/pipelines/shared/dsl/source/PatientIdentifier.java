package net.mekomsolutions.data.pipelines.shared.dsl.source;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * This class represents a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Source table</a>
 * Mapping to OpenMRS PatientIdentifier class
 */
public class PatientIdentifier implements TableSQLDSL {
    private Map<String, String> connectorOptions;
    public PatientIdentifier(Map<String, String> connectorOptions) {
        if(Objects.equals(connectorOptions.get("connector"), "kafka")){
            connectorOptions.put("topic","openmrs.openmrs.patient_identifier");
        }else{
            connectorOptions.put("table-name","patient_identifier");
        }
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return patient_identifier source table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE `patient_identifier` (\n" +
                "`patient_identifier_id` int primary key,\n" +
                "`patient_id` int,\n" +
                "`identifier` VARCHAR,\n" +
                "`identifier_type` int,\n" +
                "`preferred` BOOLEAN,\n" +
                "`location_id` int,\n" +
                "`creator` int,\n" +
                "`date_created` TIMESTAMP,\n" +
                "`voided` BOOLEAN,\n" +
                "`voided_by` int ,\n" +
                "`date_voided` TIMESTAMP ,\n" +
                "`void_reason` VARCHAR ,\n" +
                "`uuid` char,\n" +
                "`date_changed` TIMESTAMP,\n" +
                "`changed_by` int\n" +
                ")"+
                " WITH (\n" +
                    ConnectorUtils.propertyJoiner(",","=").apply(this.connectorOptions) +
                ")";
    }

}
