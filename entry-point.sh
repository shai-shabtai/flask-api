#!/bin/ash
set -eo pipefail
#shopt -s nullglob

attempt_counter=0
max_attempts=15
CONSULADDR=consul:8500
export CONSUL_HTTP_ADDR=$CONSULADDR
until $(curl --output /dev/null --silent --head --fail http://consul:8500); do
    if [ ${attempt_counter} -eq ${max_attempts} ];then
      echo "Max attempts reached"
      exit 1
    fi

    printf '.'
    attempt_counter=$(($attempt_counter+1))
    sleep 5
done
echo "----------------"

echo ADDING NEW KEY/VALUE IN CONSUL REMOTE 
#consul kv put application/secrets/API_USER USERNUMBER1
consul kv put application/BOOKTITLE BOOKTITLE
echo  "----------------"

envconsul -kill-signal=SIGHUP -upcase -sanitize -prefix application -consul $CONSULADDR -log-level debug "$@"
