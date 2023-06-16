#!/bin/bash

TRIES=3
QUERY_NUM=1
touch result.csv
# wiple last run
truncate -s0 result.csv

#Loop through all queries in the file and run 3 times
cat queries.sql | while read query; do
    sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null

    echo -n "["
    echo $query
    for i in $(seq 1 $TRIES); do

        # Run queries using curl (use double quotes to avoid single quote conflict)
        # RESULT=$(eval "curl -s --data '$query' --location 'http://localhost:10101/sql' --header 'Content-Type: text/plain'")
        RESULT=$(eval 'curl -s --data "$query" --location "http://localhost:10101/sql" --header "Content-Type: text/plain"')
          
        # print error if troubleshooting
        #echo $RESULT | jq '.error'

        ERROR=$(echo "$RESULT" | jq '.error')
        TIME=$(echo "$RESULT" | jq '."execution-time"')
        # if no errors, put execution time in seconds with 3 decimal places
        [[ $ERROR == "null" ]] && TIME=$(eval jq -n ${TIME}.000/1000000) && TIME=$(eval printf "%.3f" ${TIME})
        
        # Otherwise put null as execution time
        [[ $ERROR == "null" ]] && echo -n "${TIME}" || echo -n "null"
        
        # Build resulting time if not null
        RES=$([[ $ERROR == "null" ]] && echo -n "${TIME}" || echo -n "null")

        # Put results into a file
        [[ "$i" != $TRIES ]] && echo -n ", "
        echo "${QUERY_NUM},${i},${RES}" >> result.csv
    done
    echo "],"

    QUERY_NUM=$((QUERY_NUM + 1))
done