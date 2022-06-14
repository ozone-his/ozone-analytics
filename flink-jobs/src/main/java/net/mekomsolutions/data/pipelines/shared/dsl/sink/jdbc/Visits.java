package net.mekomsolutions.data.pipelines.shared.dsl.sink.jdbc;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.util.Map;
import java.util.Objects;

/**
 * This creates a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Sink table</a>
 * For flattening OpenMRS Visits
 */
public class Visits  implements TableSQLDSL {
    private Map<String, String> connectorOptions;
    public Visits(Map<String, String> connectorOptions) {
        if(!Objects.equals(connectorOptions.get("connector"), "filesystem")){
            connectorOptions.put("table-name","visits");
        }else{
            connectorOptions.put("path","/tmp/analytics/visits");
        }
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return visits table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE `visits` (\n" +
                "  visit_id BIGINT PRIMARY KEY,\n" +
                "  patient_id BIGINT,\n" +
                "  visit_type_uuid VARCHAR,\n" +
                "  visit_type VARCHAR,\n" +
                "  date_started TIMESTAMP,\n" +
                "  date_stopped TIMESTAMP,\n" +
                "  indication_concept_id BIGINT,\n" +
                "  location_id BIGINT,\n" +
                "  visit_voided BOOLEAN,\n" +
                "  visit_uuid VARCHAR,\n" +
                "  person_id BIGINT,\n" +
//                "  number_occurences BIGINT,\n" +
                "  gender VARCHAR,\n" +
                "  birthdate DATE,\n" +
                "  birthdate_estimated BOOLEAN,\n" +
                "  age_at_visit_group_profile_1 VARCHAR,\n" +
                "  age_at_visit BIGINT,\n" +
                "  dead BOOLEAN,\n" +
                "  death_date TIMESTAMP,\n" +
                "  cause_of_death BIGINT,\n" +
                "  person_voided BOOLEAN,\n" +
                "  person_uuid VARCHAR\n" +
                ")\n" +
                "WITH (\n" +
                    ConnectorUtils.propertyJoiner(",","=").apply(this.connectorOptions) +
                ")";
    }


}
