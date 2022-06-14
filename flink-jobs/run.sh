#!/bin/bash
#
# Process all environment variables that start with 'FLINK_JOB_'
#
touch $FLINK_HOME/job.properties
env | while read -r VAR;
do
    env_var=`echo "$VAR" | sed -r "s/([^=]*)=.*/\1/g"`
    if [[ $env_var =~ ^FLINK_JOB_ ]]; then
        prop_name=`echo "$VAR" | sed -r "s/^FLINK_JOB_([^=]*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
        prop_value=`echo "$VAR" | sed -r "s/^FLINK_JOB_[^=]*=(.*)/\1/g"`
        if egrep -q "(^|^#)$prop_name=" $FLINK_HOME/job.properties; then
            #note that no config names or values may contain an '@' char
            sed -r -i "s@(^|^#)($prop_name)=(.*)@\2=${prop_value}@g" $FLINK_HOME/job.properties
        else
            # echo "Adding property $prop_name=${prop_value}"
            echo "$prop_name=${prop_value}" >> $FLINK_HOME/job.properties
        fi
    fi
done