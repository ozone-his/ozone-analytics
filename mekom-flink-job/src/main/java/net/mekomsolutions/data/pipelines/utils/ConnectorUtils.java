package net.mekomsolutions.data.pipelines.utils;

import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

public class ConnectorUtils {
    public  static Function<Map<String, String>, String> propertyJoiner(String entrySeparator, String valueSeparator) {
        return m -> m.entrySet().stream()
                .map(e -> "'" + e.getKey() + "' " + valueSeparator +" '"+ e.getValue()+ "'")
                .collect(Collectors.joining(entrySeparator));
    }
}
