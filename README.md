# bench-tmp
## Overview

This is a temporary repo to hold code for FeatureBase's submission to the clickbench. Information on the clickbench benchmarking project can be found here: https://github.com/ClickHouse/ClickBench 

## Infrastructure

The clickbench has the following default preferences for the benchmark:

ec2 - c6a.4xlarge
disk - gp2 - 500GB
OS - Ubuntu 22.04 or newer

## Scripts

### benchmark.sh 

This is the main script to run the benchmark on a fresh VM; Ubuntu 22.04 or newer should be used by default, or any other system if specified in the comments. The script may not necessarily run in a fully automated manner - it is recommended always to copy-paste the commands one by one and observe the results. For managed databases, if the setup requires clicking in the UI, write a README.md instead.

### run.sh 

A loop for running the queries; every query is run three times; if it's a database with local on-disk storage, the first query should be run after dropping the page cache;

### create.sql 

A CREATE TABLE statement. If it's a NoSQL system, another file like wtf.json can be presented.

### insert.sql

A BULK INSERT statement to load the data

### queries.sql

Contains 43 queries to run. These have been slightly modified for syntax differences between FeatureBase and other databases

### results_stdout.csv

csv/stdout file containing the execution times for all 43 queries of the modified queries in seconds. This file was created with only 28299996 records loaded. the main script will produce results.csv when run, but this is more robust and a snapshot of where we are at.

### benchmark_old_arm_aws.sh 

This is an older version of benchmark.sh that pulls FeatureBase from the public repo releases and uses an aws ec2 image on ARM architecture. It's meant to be here as a reference if we want to run on other hardware.

### queries_original.sql

Contains the original 43 queries to run. These have not been modified for FeatureBase.

## To Do

* Get a full load of the data. The largest amount of data loaded was ~29M of ~100M records. This ran for hours and is a point of optimization as the majority of times posted by databases is under an hour
* Understand why trying to ingest large ints as IDs breaks bulk insert(slows it wayyyyyyy down). Columns(watchid, funiqid, paramprice)
* Figure out why these queries are timing out when running

1. SELECT UserID, COUNT(*) as count FROM hits GROUP BY UserID ORDER BY count DESC LIMIT 10;
2. SELECT UserID, SearchPhrase, COUNT(*) FROM hits GROUP BY UserID, SearchPhrase LIMIT 10;
3. SELECT WatchID, ClientIP, COUNT(*) AS c, SUM(IsRefresh), AVG(ResolutionWidth) FROM hits WHERE SearchPhrase IS NOT NULL GROUP BY WatchID, ClientIP ORDER BY c DESC LIMIT 10;
4. SELECT WatchID, ClientIP, COUNT(*) AS c, SUM(IsRefresh), AVG(ResolutionWidth) FROM hits GROUP BY WatchID, ClientIP ORDER BY c DESC LIMIT 10;

* Create results folder with .json file for each architecture with load time, data size, and execution times. Based on repo entries, this is a json file that is created manually using results.csv and the other info pulled out manually: https://github.com/ClickHouse/ClickBench/blob/main/clickhouse/results/c6a.4xlarge.json 
* Optional: Get remaining queries to work (see null results in results_stdout.csv) and jira ticket
* Create PR and submit results