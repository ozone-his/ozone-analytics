package net.mekomsolutions.data.pipelines.shared.dsl.source;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * This class represents a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Source table</a>
 * Mapping to OpenMRS Obs class
 */
public class Obs implements TableSQLDSL {
    private Map<String, String> connectorOptions;

    public Obs(Map<String, String> connectorOptions) {
        if(Objects.equals(connectorOptions.get("connector"), "kafka")){
            connectorOptions.put("topic","openmrs.openmrs.obs");
        }else{
            connectorOptions.put("table-name","obs");
        }
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return obs source table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE obs (\n" +
                "  obs_id int primary key,\n" +
                "  person_id int,\n" +
                "  concept_id int,\n" +
                "  encounter_id int,\n" +
                "  order_id int,\n" +
                "  obs_datetime TIMESTAMP,\n" +
                "  location_id int,\n" +
                "  obs_group_id int,\n" +
                "  accession_number VARCHAR,\n" +
                "  value_group_id int,\n" +
                "  value_coded int,\n" +
                "  value_coded_name_id int,\n" +
                "  value_drug int,\n" +
                "  value_datetime TIMESTAMP,\n" +
                "  value_numeric double,\n" +
                "  value_modifier VARCHAR,\n" +
                "  value_text VARCHAR,\n" +
                "  value_complex VARCHAR,\n" +
                "  comments VARCHAR,\n" +
                "  creator int,\n" +
                "  date_created TIMESTAMP,\n" +
                "  voided BOOLEAN,\n" +
                "  voided_by int,\n" +
                "  date_voided TIMESTAMP,\n" +
                "  void_reason VARCHAR,\n" +
                "  uuid VARCHAR,\n" +
                "  previous_version int,\n" +
                "  form_namespace_and_path VARCHAR,\n" +
                "  status VARCHAR,\n" +
                "  interpretation VARCHAR" +
                ")" +
                " WITH (\n" +
                ConnectorUtils.propertyJoiner(",","=").apply(this.connectorOptions) +
                ")";
    }
}
