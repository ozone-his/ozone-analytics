package net.mekomsolutions.data.pipelines.shared.dsl.source;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * This class represents a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Source table</a>
 * Mapping to OpenMRS VisitType class
 */
public class VisitType implements TableSQLDSL {
    private Map<String, String> connectorOptions;
    public VisitType(Map<String, String> connectorOptions) {

        if(Objects.equals(connectorOptions.get("connector"), "kafka")){
            connectorOptions.put("topic","openmrs.openmrs.visit_type");
        }else{
            connectorOptions.put("table-name","visit_type");
        }
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return visit_type source table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE `visit_type` (\n" +
                "  `visit_type_id` int primary key,\n" +
                "  `name` VARCHAR,\n" +
                "  `description` VARCHAR,\n" +
                "  `creator` int,\n" +
                "  `date_created` TIMESTAMP,\n" +
                "  `changed_by` int,\n" +
                "  `date_changed` TIMESTAMP,\n" +
                "  `retired` BOOLEAN,\n" +
                "  `retired_by` int,\n" +
                "  `date_retired` TIMESTAMP,\n" +
                "  `retire_reason` VARCHAR,\n" +
                "  `uuid` VARCHAR\n" +
                ")"+
                " WITH (\n" +
                    ConnectorUtils.propertyJoiner(",","=").apply(connectorOptions) +
                ")";
    }
}
