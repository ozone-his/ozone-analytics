package net.mekomsolutions.data.pipelines.shared.dsl;

/**
 * A representation  of a Flink <a href="https://ci.apache.org/projects/flink/flink-docs-master/docs/dev/table/sourcessinks/"> Dynamic Source/Sink table</a>
 * Implementers of this interface have to an SQL DSL representation of the desired source our sink table
 */
public interface TableSQLDSL {
    String getDSL();
}
