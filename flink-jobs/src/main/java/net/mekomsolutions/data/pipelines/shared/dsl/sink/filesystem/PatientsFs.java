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
 * For flattening OpenMRS Patients
 */
public class PatientsFs implements TableSQLDSL {
    private Map<String, String> connectorOptions;
    public PatientsFs(Map<String, String> connectorOptions) {
        this.connectorOptions = connectorOptions;
    }

    /**
     * @return visits table DSL
     */
    @Override
    public String getDSL() {
        return "CREATE TABLE `patients_fs` (\n" +
                  "patient_id BIGINT PRIMARY KEY,\n" +
                  "given_name VARCHAR,\n" +
                  "middle_name VARCHAR,\n" +
                  "family_name VARCHAR,\n" +
                  "identifier VARCHAR,\n" +
                  "gender VARCHAR,\n" +
                  "birthdate DATE,\n" +
                  "birthdate_estimated BOOLEAN,\n" +
                  "city VARCHAR,\n" +
                  "dead BOOLEAN,\n" +
                  "death_date TIMESTAMP,\n" +
                  "cause_of_death BIGINT,\n" +
                  "creator BIGINT,\n" +
                  "date_created TIMESTAMP,\n" +
                  "person_voided BOOLEAN,\n" +
                  "person_void_reason VARCHAR\n" +
                ")\n" +
                "WITH (\n" +
                    ConnectorUtils.propertyJoiner(",","=").apply(this.connectorOptions) +
                ")";
    }


}
