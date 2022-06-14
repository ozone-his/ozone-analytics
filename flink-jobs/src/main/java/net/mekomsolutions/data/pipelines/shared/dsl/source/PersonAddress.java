package net.mekomsolutions.data.pipelines.shared.dsl.source;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * This class represents a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Source table</a>
 * Mapping to OpenMRS PersonAddress class
 */
public class PersonAddress implements TableSQLDSL {
    private Map<String, String> connectorOptions;
    public PersonAddress(Map<String, String> connectorOptions) {
        if(Objects.equals(connectorOptions.get("connector"), "kafka")){
            connectorOptions.put("topic","openmrs.openmrs.person_address");
        }else{
            connectorOptions.put("table-name","person_address");
        }
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return person_address source table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE `person_address` (\n" +
                "`person_address_id` int primary key,\n" +
                "`person_id` int,\n" +
                "`preferred` BOOLEAN,\n" +
                "`address1` VARCHAR,\n" +
                "`address2` VARCHAR,\n" +
                "`city_village` VARCHAR,\n" +
                "`state_province` VARCHAR,\n" +
                "`postal_code` VARCHAR,\n" +
                "`country` VARCHAR,\n" +
                "`latitude` VARCHAR,\n" +
                "`longitude` VARCHAR,\n" +
                "`creator` int,\n" +
                "`date_created` TIMESTAMP,\n" +
                "`voided` BOOLEAN,\n" +
                "`voided_by` int,\n" +
                "`date_voided` TIMESTAMP,\n" +
                "`void_reason` VARCHAR,\n" +
                "`county_district` VARCHAR,\n" +
                "`address3` VARCHAR,\n" +
                "`address6` VARCHAR,\n" +
                "`address5` VARCHAR,\n" +
                "`address4` VARCHAR,\n" +
                "`uuid` char,\n" +
                "`date_changed` TIMESTAMP,\n" +
                "`changed_by` int,\n" +
                "`start_date` TIMESTAMP,\n" +
                "`end_date` TIMESTAMP,\n" +
                "`address7` VARCHAR,\n" +
                "`address8` VARCHAR,\n" +
                "`address9` VARCHAR,\n" +
                "`address10` VARCHAR,\n" +
                "`address11` VARCHAR,\n" +
                "`address12` VARCHAR,\n" +
                "`address13` VARCHAR,\n" +
                "`address14` VARCHAR,\n" +
                "`address15` VARCHAR\n" +
                ")"+
                " WITH (\n" +
                    ConnectorUtils.propertyJoiner(",","=").apply(this.connectorOptions) +
                ")";
    }

}
