#!/bin/sh

HOST="127.0.0.1"
MASTER=(9001 9003 9005)
CLUSTER=(9002 9004 9006)


if [ ${#MASTER[@]} != ${#CLUSTER[@]} ]; then
   echo "WARN: master len != cluster len"
    exit 0
fi

docker compose up -d

docker network inspect redis-cluster_default | grep "IPv4Address" | awk -F\" '{print $4}' | awk -F/ '{print $1 > ".addr.txt"}'

for addr in `cat .addr.txt`
do 
    echo "cluster meet ${addr}:6379"
    ./redis-cli -h ${HOST} -p ${MASTER[0]} cluster meet ${addr} 6379 > /dev/null
done

sleep 1

for ((i=0;i<${#MASTER[@]};i++)) do
    echo "master=${MASTER[i]} cluster=${CLUSTER[i]}"
    ./redis-cli -h ${HOST} -p ${CLUSTER[i]} cluster replicate `redis-cli -h ${HOST} -p ${MASTER[i]} cluster myid` > /dev/null
done;

./redis-cli -h localhost -p ${MASTER[0]} cluster addslots {0..5461}
./redis-cli -h localhost -p ${MASTER[1]} cluster addslots {5462..10922}
./redis-cli -h localhost -p ${MASTER[2]} cluster addslots {10923..16383}

sleep 1

echo "redis cluster info:"
./redis-cli -h ${HOST} -p ${MASTER[0]} cluster nodes

./redis-cli -c -h ${HOST} -p ${MASTER[0]} 
