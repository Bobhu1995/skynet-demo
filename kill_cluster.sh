#!/bin/sh
./redis/redis-cli -h 127.0.0.1 -p 7777 proxy shutdown

./redis/redis-cli -h 127.0.0.1 -p 7001 shutdown
./redis/redis-cli -h 127.0.0.1 -p 7002 shutdown
./redis/redis-cli -h 127.0.0.1 -p 7003 shutdown
./redis/redis-cli -h 127.0.0.1 -p 7004 shutdown
./redis/redis-cli -h 127.0.0.1 -p 7005 shutdown
./redis/redis-cli -h 127.0.0.1 -p 7006 shutdown
