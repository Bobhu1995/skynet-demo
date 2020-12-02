#!/bin/sh
export ROOT=$(cd `dirname $0`; pwd)

cd redis 
./redis-server redis1.conf > /dev/null & 
./redis-server redis2.conf > /dev/null &
./redis-server redis3.conf > /dev/null &

