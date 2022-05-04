curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" http://localhost:8083/connectors/ \
        -d '{
         "name": "openmrs-connector",
         "config": {
               "connector.class": "io.debezium.connector.mysql.MySqlConnector",
               "tasks.max": "1",
               "database.hostname": "mysql",
               "database.port": "3306",
               "database.user": "root",
               "database.password": "3cY8Kve4lGey",
               "database.server.id": "2",
               "database.server.name": "openmrs",
               "database.include.list": "openmrs",
               "database.history.kafka.bootstrap.servers": "kafka:9092",
               "database.history.kafka.topic": "dbhistory.openmrs",
               "converters": "timestampConverter",
               "timestampConverter.type": "oryanmoshe.kafka.connect.util.TimestampConverter",
               "timestampConverter.format.time": "HH:mm:ss.SSS",
               "timestampConverter.format.date": "YYYY-MM-dd",
               "timestampConverter.format.datetime": "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",
               "timestampConverter.debug": "true"
     }
}'