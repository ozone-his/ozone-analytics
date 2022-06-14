package net.mekomsolutions.data.pipelines.shared.dsl.source;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * This class represents a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Source table</a>
 * Mapping to OpenMRS PersonName class
 */
public class PersonName implements TableSQLDSL {
    private Map<String, String> connectorOptions;
    public PersonName(Map<String, String> connectorOptions) {
        if(Objects.equals(connectorOptions.get("connector"), "kafka")){
            connectorOptions.put("topic","openmrs.openmrs.person_name");
        }else{
            connectorOptions.put("table-name","person_name");
        }
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return person_name source table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE `person_name` (\n" +
                "`person_name_id` int primary key,\n" +
                "`preferred` BOOLEAN,\n" +
                "`person_id` int,\n" +
                "`prefix` VARCHAR,\n" +
                "`given_name` VARCHAR,\n" +
                "`middle_name` VARCHAR,\n" +
                "`family_name_prefix` VARCHAR,\n" +
                "`family_name` VARCHAR,\n" +
                "`family_name2` VARCHAR,\n" +
                "`family_name_suffix` VARCHAR,\n" +
                "`degree` VARCHAR,\n" +
                "`creator` int,\n" +
                "`date_created` TIMESTAMP,\n" +
                "`voided` BOOLEAN,\n" +
                "`voided_by` int,\n" +
                "`date_voided` TIMESTAMP,\n" +
                "`void_reason` VARCHAR,\n" +
                "`changed_by` int,\n" +
                "`date_changed` TIMESTAMP,\n" +
                "`uuid` char\n" +
                ")"+
                " WITH (\n" +
                    ConnectorUtils.propertyJoiner(",","=").apply(this.connectorOptions) +
                ")";
    }

}
