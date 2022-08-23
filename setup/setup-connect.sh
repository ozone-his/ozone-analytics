curl -i -X PUT -H "Accept:application/json" -H "Content-Type:application/json" http://${CONNECT_HOST}:8083/connectors/openmrs-connector/config/ \
        -d ' {
               "connector.class": "io.debezium.connector.mysql.MySqlConnector",
               "tasks.max": "1",
               "database.hostname": "${file:/kafka/config/connect-distributed.properties:mysql.hostname}",
               "database.port": "${file:/kafka/config/connect-distributed.properties:mysql.port}",
               "database.user": "${file:/kafka/config/connect-distributed.properties:mysql.username}",
               "database.password": "${file:/kafka/config/connect-distributed.properties:mysql.password}",
               "database.server.id": "${file:/kafka/config/connect-distributed.properties:mysql.server.id}",
               "database.server.name": "${file:/kafka/config/connect-distributed.properties:mysql.server.name}",
               "database.include.list": "${file:/kafka/config/connect-distributed.properties:mysql.include.list}",
               "database.history.kafka.bootstrap.servers": "${file:/kafka/config/connect-distributed.properties:mysql.kafka.bootstrap.servers}",
               "database.history.kafka.topic": "${file:/kafka/config/connect-distributed.properties:mysql.histroy.topic}",
               "converters": "timestampConverter",
               "timestampConverter.type": "oryanmoshe.kafka.connect.util.TimestampConverter",
               "timestampConverter.format.time": "HH:mm:ss",
               "timestampConverter.format.date": "YYYY-MM-dd",
               "timestampConverter.format.datetime": "yyyy-MM-dd HH:mm:ss",
               "timestampConverter.debug": "false"
     }'