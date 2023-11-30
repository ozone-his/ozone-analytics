set -e
echo "Waiting for source database to be ready-----"
/opt/wait-for-it.sh $SOURCE_DB_HOST:3306

echo "Waiting for connect to be ready-----"
/opt/wait-for-it.sh $CONNECT_HOST:8083

echo "Waiting for flink to be ready-----"
url="http://${FLINK_JOBMANAGER_HOST}:8081/jobs/00000000000000000000000000000000"
interval_in_seconds=2
result="RUNNING"
path=".state"
printf "\nPolling '$url' every $interval_in_seconds seconds, until flink is in '$result' state \n"
while true; 
do 
	x=$(curl $url -s | jq -r $path); 
	if [[ "$x" == "$result" ]]; then 
		break; 
	fi; 
	sleep $interval_in_seconds; 
done
curl --fail -i -X PUT -H "Accept:application/json" -H "Content-Type:application/json" http://${CONNECT_HOST}:8083/connectors/openmrs-connector/config/ \
        -d '{
               "connector.class": "io.debezium.connector.mysql.MySqlConnector",
               "tasks.max": "1",
               "database.hostname": "${file:/kafka/config/connect-distributed.properties:mysql.hostname}",
               "database.port": "${file:/kafka/config/connect-distributed.properties:mysql.port}",
               "database.user": "${file:/kafka/config/connect-distributed.properties:mysql.username}",
               "database.password": "${file:/kafka/config/connect-distributed.properties:mysql.password}",
               "database.server.id": "${file:/kafka/config/connect-distributed.properties:mysql.server.id}",
               "database.server.name": "${file:/kafka/config/connect-distributed.properties:mysql.server.name}",
               "database.include.list": "${file:/kafka/config/connect-distributed.properties:mysql.include.list}",
               "table.exclude.list": "${file:/kafka/config/connect-distributed.properties:table.exclude.list}",
               "database.history.kafka.bootstrap.servers": "${file:/kafka/config/connect-distributed.properties:mysql.kafka.bootstrap.servers}",
               "database.history.kafka.topic": "${file:/kafka/config/connect-distributed.properties:mysql.histroy.topic}",
               "converters": "timestampConverter",
               "timestampConverter.type": "oryanmoshe.kafka.connect.util.TimestampConverter",
               "timestampConverter.format.time": "HH:mm:ss",
               "timestampConverter.format.date": "YYYY-MM-dd",
               "timestampConverter.format.datetime": "yyyy-MM-dd HH:mm:ss",
               "timestampConverter.debug": "false",
               "snapshot.mode": "when_needed"
     }'