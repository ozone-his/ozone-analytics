package net.mekomsolutions.data.pipelines.shared.dsl.source;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * This class represents a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Source table</a>
 * Mapping to OpenMRS Patient class
 */
public class Patient implements TableSQLDSL {
    private Map<String, String> connectorOptions;
    public Patient(Map<String, String> connectorOptions) {
        if(Objects.equals(connectorOptions.get("connector"), "kafka")){
            connectorOptions.put("topic","openmrs.openmrs.patient");
        }else{
            connectorOptions.put("table-name","patient");
        }
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return patient source table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE `patient` (\n" +
                "`patient_id` int primary key,\n" +
                "`creator` int,\n" +
                "`date_created` TIMESTAMP,\n" +
                "`changed_by` int,\n" +
                "`date_changed` TIMESTAMP,\n" +
                "`voided` BOOLEAN,\n" +
                "`voided_by` int,\n" +
                "`date_voided` TIMESTAMP,\n" +
                "`void_reason` VARCHAR,\n" +
                "`allergy_status` VARCHAR\n" +
                ")" +
                " WITH (\n" +
                    ConnectorUtils.propertyJoiner(",","=").apply(this.connectorOptions) +
                ")";
    }

}
