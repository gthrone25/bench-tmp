#!/bin/bash

# run with a force for installations
# ./benchmark.sh --force-yes

sudo apt-get update
sudo apt install jq

# params for featurebase binary

RELEASE=5.0.3
FB_VERSION=3.40.0
FB_OS=linux
FB_ARCH=amd64
FB_USERNAME=
FB_PASSWORD=


# stop featurebase if it's running
# sudo systemctl stop featurebase
JOB=$(ps -ef | grep "featurebase server" | awk '{ print $2 }' | head -1)
sudo kill $JOB

# remove featurebase if it's in /usr/local/bin
sudo rm -f /usr/local/bin/featurebase
#remove public repo release
#sudo rm -rf featurebase-v$FB_VERSION-$FB_OS-$FB_ARCH.tar.gz featurebase-v$FB_VERSION-$FB_OS-$FB_ARCH/ idk-v$FB_VERSION-$FB_OS-$FB_ARCH/

# get featurebase binary and move it from local repo
#https://github.com/FeatureBaseDB/featurebase/releases/download/v3.32.0/featurebase-v3.32.0-linux-arm64.tar.gz
# sudo wget  https://github.com/FeatureBaseDB/featurebase/releases/download/v$FB_VERSION/featurebase-v$FB_VERSION-$FB_OS-$FB_ARCH.tar.gz
# sudo tar -xvf featurebase-v$FB_VERSION-$FB_OS-$FB_ARCH.tar.gz
# sudo mv featurebase-v$FB_VERSION-$FB_OS-$FB_ARCH/featurebase /usr/local/bin/.
# sudo chmod +x /usr/local/bin/featurebase

# # get featurebase binary from release folder and move it
sudo wget -P /usr/local/bin https://$FB_USERNAME:$FB_PASSWORD@releases.molecula.cloud/molecula-v$RELEASE/featurebase/featurebase-v$FB_VERSION-$FB_OS-$FB_ARCH/featurebase
sudo chmod +x /usr/local/bin/featurebase

# create conf and service file
sudo touch /etc/featurebase.conf
sudo touch /etc/systemd/system/featurebase.service



# create featurebase user and dirs it owns
sudo id -u featurebase &>/dev/null || sudo useradd featurebase
sudo mkdir -p /var/log/featurebase && sudo chown featurebase:featurebase /var/log/featurebase
sudo mkdir -p /var/lib/featurebase && sudo chown featurebase:featurebase /var/lib/featurebase
sudo mkdir -p /data && sudo sudo chown featurebase:featurebase /data
sudo mkdir -p /home/featurebase && sudo chown featurebase:featurebase /home/featurebase
sudo chown featurebase:featurebase /etc/featurebase.conf
sudo chown featurebase:featurebase /etc/systemd/system/featurebase.service


# create log file
# sudo touch /var/log/featurebase/featurebase.log

# write service file below (no longer needed)
# sudo sh -c 'cat > /etc/systemd/system/featurebase.service <<EOL
# [Unit]
#     Description="Service for FeatureBase"

# [Service]
#     RestartSec=30
#     Restart=on-failure
#     User=featurebase
#     ExecStart=/usr/local/bin/featurebase server -c /etc/featurebase.conf

# [Install]
#     WantedBy=multi-user.target
# EOL'

# write conf file below
sudo sh -c 'cat > /etc/featurebase.conf <<EOL
# FEATUREBASE HOST CONFIGURATION

bind = "0.0.0.0:10101"
bind-grpc = "0.0.0.0:20101"

data-dir = "/var/lib/featurebase"
log-path = "/var/log/featurebase/featurebase.log"

[sql]
  endpoint-enabled = true
EOL'

# enable and start featurebase
# sudo systemctl enable --now featurebase.service
# featurebase server -c /etc/featurebase.conf & 
sudo runuser -l featurebase -c 'featurebase server -c /etc/featurebase.conf &'

# wait 10 seconds for featurebase to start
sleep 10s 

# Create Table

curl --data-binary "@create.sql" --location 'http://localhost:10101/sql' --header 'Content-Type: text/plain'

# Get data locally if needed

#get data locally from clickhouse
wget --continue 'https://datasets.clickhouse.com/hits_compatible/hits.csv.gz'
gzip -d hits.csv.gz
sudo chown featurebase:featurebase hits.csv
sudo mv hits.csv /data/hits.csv

#get data locally from our public repo (uncompressed)
# wget https://featurebase-public-data.s3.us-east-2.amazonaws.com/hits.csv
# sudo chown featurebase:featurebase hits.csv
# sudo mv hits.csv /data/hits.csv

# Load data
#think about echoing execution time for ingest later
curl --data-binary "@insert.sql" --location 'http://localhost:10101/sql' --header 'Content-Type: text/plain'

# Execute queries 
sudo chmod +x run.sh
./run.sh

echo All done!