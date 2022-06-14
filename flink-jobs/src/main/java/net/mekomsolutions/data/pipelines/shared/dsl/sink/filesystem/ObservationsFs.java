package net.mekomsolutions.data.pipelines.shared.dsl.sink.filesystem;

import net.mekomsolutions.data.pipelines.shared.dsl.TableSQLDSL;
import net.mekomsolutions.data.pipelines.utils.ConnectorUtils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import java.util.Map;
import java.util.Objects;

/**
 * This creates a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/">Sink table</a>
 * For flattening OpenMRS Obs
 */
public class ObservationsFs implements TableSQLDSL {
    private Map<String, String> connectorOptions;
    public ObservationsFs(Map<String, String> connectorOptions) {
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return observations table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE observations_fs (\n" +
                "    obs_id BIGINT PRIMARY KEY,\n" +
                "    person_id BIGINT,\n" +
                "    concept_name VARCHAR,\n" +
                "    concept_id BIGINT,\n" +
                "    obs_group_id BIGINT,\n" +
                "    accession_number VARCHAR,\n" +
                "    form_namespace_and_path VARCHAR,\n" +
                "    value_coded BIGINT,\n" +
                "    value_coded_name VARCHAR,\n" +
                "    value_coded_name_id BIGINT,\n" +
                "    value_drug BIGINT,\n" +
                "    value_datetime TIMESTAMP,\n" +
                "    value_numeric DOUBLE,\n" +
                "    value_modifier VARCHAR,\n" +
                "    value_text VARCHAR,\n" +
                "    value_complex VARCHAR,\n" +
                "    comments VARCHAR,\n" +
                "    creator BIGINT,\n" +
                "    date_created TIMESTAMP,\n" +
                "    obs_voided BOOLEAN,\n" +
                "    obs_void_reason VARCHAR,\n" +
                "    previous_version BIGINT,\n" +
                "    encounter_id BIGINT,\n" +
                "    voided_2 BOOLEAN,\n" +
                "    visit_id BIGINT,\n" +
                "    visit_date_started TIMESTAMP,\n" +
                "    visit_date_stopped TIMESTAMP,\n" +
                "    location_id BIGINT,\n" +
                "    encounter_type_name VARCHAR,\n" +
                "    encounter_type_description VARCHAR,\n" +
                "    encounter_type_retired BOOLEAN,\n" +
                "    encounter_type_uuid VARCHAR,\n" +
                "    visit_type_name VARCHAR,\n" +
                "    visit_type_retired BOOLEAN,\n" +
                "    visit_type_uuid VARCHAR,\n" +
                "    location_name VARCHAR,\n" +
                "    location_address1 VARCHAR,\n" +
                "    location_address2 VARCHAR,\n" +
                "    location_city_village VARCHAR,\n" +
                "    location_state_province VARCHAR,\n" +
                "    location_postal_code VARCHAR,\n" +
                "    location_country VARCHAR,\n" +
                "    location_retired BOOLEAN,\n" +
                "    location_uuid VARCHAR \n" +
                ")" +
                "WITH (\n" +
                ConnectorUtils.propertyJoiner(",", "=").apply(connectorOptions) +
                ")";
    }
}
