#!/bin/sh

read -p "enter your local IP(192.168.x.x):" HOST

echo IP=${HOST} > .env
docker compose up -d
rm -rf .env

redis-cli --cluster create ${HOST}:6379 ${HOST}:6002 ${HOST}:6003 ${HOST}:6004 ${HOST}:6005 ${HOST}:6006 --cluster-replicas 1 << END
yes
END
