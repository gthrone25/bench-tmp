#!/bin/bash

TRIES=3
QUERY_NUM=1
touch result.csv
truncate -s0 result.csv

cat queries.sql | while read query; do
    sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null

    echo -n "["
    echo $query
    for i in $(seq 1 $TRIES); do
    #     RES=$(./clickhouse local --time --format Null --multiquery --progress 0 --query="$(cat create.sql); $query" 2>&1 | tail -n1)
          
          # RESULT=$(eval "curl -w '%{http_code}\n' --data '$query' --location 'http://localhost:10101/sql' --header 'Content-Type: text/plain'")
          RESULT=$(eval "curl -s --data '$query' --location 'http://localhost:10101/sql' --header 'Content-Type: text/plain'")
          #echo $RESULT
          #echo $RESULT | jq '.error'
          ERROR=$(echo "$RESULT" | jq '.error')
          TIME=$(echo "$RESULT" | jq '."execution-time"')
          # if no errors, put execution time in seconds with 3 decimal places
          [[ $ERROR == "null" ]] && TIME=$(eval jq -n ${TIME}.000/1000000) && TIME=$(eval printf "%.3f" ${TIME})
          # echo $ERROR

          [[ $ERROR == "null" ]] && echo -n "${TIME}" || echo -n "null"
          RES=$([[ $ERROR == "null" ]] && echo -n "${TIME}" || echo -n "null")
    #     [[ "$?" == "0" ]] && echo -n "${RES}" || echo -n "null"
        [[ "$i" != $TRIES ]] && echo -n ", "

        echo "${QUERY_NUM},${i},${RES}" >> result.csv
    done
    echo "],"

    QUERY_NUM=$((QUERY_NUM + 1))
done