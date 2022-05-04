package net.mekomsolutions.data.pipelines.utils;

import net.mekomsolutions.data.pipelines.shared.dsl.TableDSLFactory;
import org.apache.flink.table.api.TableEnvironment;

import java.util.Map;

public  class CommonUtils {
    public static void setupTables(TableEnvironment tableEnv, String[] tables, Map<String, String> connectorOptions) {

        TableDSLFactory tableDSLFactory = new TableDSLFactory(connectorOptions);
        for (String tableName : tables) {
            tableEnv.executeSql(tableDSLFactory.getTable(tableName).getDSL());
        }
    }
}
