#!/bin/bash

sudo yum update -y

# params for featurebase binary
# FB_VERSION=<FB_VERSION>
# FB_OS=<FB_OS>
# FB_ARCH=<FB_ARCH>

FB_VERSION=3.33.0
FB_OS=linux
FB_ARCH=arm64

# stop featurebase if it's running
# sudo systemctl stop featurebase
JOB=$(ps -ef | grep "featurebase server" | awk '{ print $2 }' | head -1)
sudo kill $JOB

# remove featurebase if it's in /usr/local/bin
sudo rm -f /usr/local/bin/featurebase
sudo rm -rf featurebase-v$FB_VERSION-$FB_OS-$FB_ARCH.tar.gz featurebase-v$FB_VERSION-$FB_OS-$FB_ARCH/ idk-v$FB_VERSION-$FB_OS-$FB_ARCH/

# get featurebase binary and move it
#https://github.com/FeatureBaseDB/featurebase/releases/download/v3.32.0/featurebase-v3.32.0-linux-arm64.tar.gz
sudo wget  https://github.com/FeatureBaseDB/featurebase/releases/download/v$FB_VERSION/featurebase-v$FB_VERSION-$FB_OS-$FB_ARCH.tar.gz
sudo tar -xvf featurebase-v$FB_VERSION-$FB_OS-$FB_ARCH.tar.gz
sudo mv featurebase-v$FB_VERSION-$FB_OS-$FB_ARCH/featurebase /usr/local/bin/.
sudo chmod +x /usr/local/bin/featurebase


# create conf, and service file
sudo touch /etc/featurebase.conf
sudo touch /etc/systemd/system/featurebase.service



# create featurebase user and dirs it owns
sudo id -u featurebase &>/dev/null || sudo useradd featurebase
sudo mkdir -p /var/log/featurebase && sudo chown featurebase:featurebase /var/log/featurebase
sudo mkdir -p /var/lib/featurebase && sudo chown featurebase:featurebase /var/lib/featurebase
sudo mkdir -p /data && sudo sudo chown featurebase:featurebase /data
#sudo chown featurebase:featurebase /usr/local/bin/featurebase
sudo chown featurebase:featurebase /etc/featurebase.conf
sudo chown featurebase:featurebase /etc/systemd/system/featurebase.service
# sudo mkdir -p /var/log/featurebase
# sudo mkdir -p /var/lib/featurebase 

# create log file
# sudo touch /var/log/featurebase/featurebase.log

# write service file below
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

# Get & Load the data

# wget --continue 'https://datasets.clickhouse.com/hits_compatible/hits.tsv.gz'
# gzip -d hits.tsv.gz

wget https://featurebase-public-data.s3.us-east-2.amazonaws.com/hits.csv.0.clean.csv

sudo chown featurebase:featurebase hits.csv.0.clean.csv
sudo mv hits.csv.0.clean.csv /data/hits.csv.0.clean.csv

curl --data-binary "@insert.sql" --location 'http://localhost:10101/sql' --header 'Content-Type: text/plain'

# sudo runuser -l featurebase -c 'curl --data-binary "@insert.sql" --location \'http://localhost:10101/sql\' --header \'Content-Type: text/plain\''

