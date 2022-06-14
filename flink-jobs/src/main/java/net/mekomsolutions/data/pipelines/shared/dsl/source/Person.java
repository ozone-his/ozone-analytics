package net.mekomsolutions.data.pipelines.shared.dsl.source;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * This class represents a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Source table</a>
 * Mapping to OpenMRS Person class
 */
public class Person implements TableSQLDSL {
    private Map<String, String> connectorOptions;
    public Person(Map<String, String> connectorOptions) {
        if(Objects.equals(connectorOptions.get("connector"), "kafka")){
            connectorOptions.put("topic","openmrs.openmrs.person");
        }else{
            connectorOptions.put("table-name","person");
        }
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return person source table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE `person` (\n" +
                "  `person_id` int primary key,\n" +
                "  `gender` VARCHAR,\n" +
                "  `birthdate` DATE ,\n" +
                "  `birthdate_estimated` BOOLEAN,\n" +
                "  `dead` BOOLEAN,\n" +
                "  `death_date` TIMESTAMP,\n" +
                "  `cause_of_death` BIGINT,\n" +
                "  `creator` int,\n" +
                "  `date_created` TIMESTAMP,\n" +
                "  `changed_by` int,\n" +
                "  `date_changed` TIMESTAMP,\n" +
                "  `voided` BOOLEAN,\n" +
                "  `voided_by` int,\n" +
                "  `date_voided` TIMESTAMP,\n" +
                "  `void_reason` VARCHAR,\n" +
                "  `uuid` char,\n" +
                "  `deathdate_estimated` BOOLEAN,\n" +
                "  `birthtime` time,\n" +
                "  `cause_of_death_non_coded` VARCHAR\n" +
                ")"+
                " WITH (\n" +
                    ConnectorUtils.propertyJoiner(",","=").apply(this.connectorOptions) +
                ")";
    }

}
