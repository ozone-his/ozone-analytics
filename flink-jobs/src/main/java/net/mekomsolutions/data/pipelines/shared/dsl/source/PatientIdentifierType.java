package net.mekomsolutions.data.pipelines.shared.dsl.source;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * This class represents a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Source table</a>
 * Mapping to OpenMRS PatientIdentifierType class
 */
public class PatientIdentifierType implements TableSQLDSL {
    private Map<String, String> connectorOptions;
    public PatientIdentifierType(Map<String, String> connectorOptions) {
        if(Objects.equals(connectorOptions.get("connector"), "kafka")){
            connectorOptions.put("topic","openmrs.openmrs.patient_identifier_type");
        }else{
            connectorOptions.put("table-name","patient_identifier_type");
        }
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return patient_identifier_type source table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE `patient_identifier_type` (\n" +
                "`patient_identifier_type_id` int primary key,\n" +
                "`name` VARCHAR,\n" +
                "`description` VARCHAR,\n" +
                "`format` VARCHAR,\n" +
                "`check_digit` BOOLEAN,\n" +
                "`creator` int,\n" +
                "`date_created` TIMESTAMP,\n" +
                "`required` BOOLEAN,\n" +
                "`format_description` VARCHAR,\n" +
                "`validator` VARCHAR,\n" +
                "`retired` BOOLEAN,\n" +
                "`retired_by` int,\n" +
                "`date_retired` TIMESTAMP,\n" +
                "`retire_reason` VARCHAR,\n" +
                "`uuid` char,\n" +
                "`location_behavior` VARCHAR,\n" +
                "`uniqueness_behavior` VARCHAR,\n" +
                "`date_changed` TIMESTAMP,\n" +
                "`changed_by` int\n" +
                ")" +
                " WITH (\n" +
                    ConnectorUtils.propertyJoiner(",","=").apply(this.connectorOptions) +
                ")";
    }

}
