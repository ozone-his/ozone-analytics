#!/usr/bin/env bash
#
# Process all environment variables that start with 'ANALYTICS_'
#
touch $FLINK_HOME/usrlib/test.properties
env | while read -r VAR;
do
    env_var=`echo "$VAR" | sed -r "s/([^=]*)=.*/\1/g"`
    if [[ $env_var =~ ^ANALYTICS_ ]]; then
        prop_name=`echo "$VAR" | sed -r "s/^ANALYTICS_([^=]*)=.*/\1/g" | tr '[:upper:]' '[:lower:]' | tr _ .`
        prop_value=`echo "$VAR" | sed -r "s/^ANALYTICS_[^=]*=(.*)/\1/g"`
    if egrep -q "(^|^#)$prop_name=" $FLINK_HOME/usrlib/test.properties; then
        #note that no config names or values may contain an '@' char
        sed -r -i "s@(^|^#)($prop_name)=(.*)@\2=${prop_value}@g" $FLINK_HOME/usrlib/test.properties
    else
        # echo "Adding property $prop_name=${prop_value}"
        echo "$prop_name=${prop_value}" >> $FLINK_HOME/usrlib/test.properties
    fi
        if [[ "$SENSITIVE_PROPERTIES" = *"$env_var"* ]]; then
            echo "--- Setting property from $env_var: $prop_name=[hidden]"
        else
            echo "--- Setting property from $env_var: $prop_name=${prop_value}"
        fi
    fi
done
