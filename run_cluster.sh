#!/bin/sh
export ROOT=$(cd `dirname $0`; pwd)

cd redis 
./redis-server ./7001/redis.conf 
./redis-server ./7002/redis.conf 
./redis-server ./7003/redis.conf 
./redis-server ./7004/redis.conf 
./redis-server ./7005/redis.conf 
./redis-server ./7006/redis.conf 
cd -

cd redis-proxy
./redis-cluster-proxy -c ./proxy.conf
