#!/bin/sh

./mysql/bin/tap-mysql --config tap.json --properties properties.json | ./postgres/bin/target-postgres --config ta
rget.json