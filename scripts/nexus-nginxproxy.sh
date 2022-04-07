#!/bin/bash

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#    http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ............................... DISCLAIMER ............................ #
#
#These scripts come without warranty of any kind. Use them at your own risk.
#I assume no liability for the accuracy, correctness, completeness, or usefulness
#of any information provided by this script nor for any sort of damages using
#these scripts may cause.
# ....................................................................... #

# Create certs directory
CERT_PATH=/opt/certs
USR=david

mkdir -p $CERT_PATH


openssl req  -subj "/C=IR/ST=Tehran/L=Tehran/O=IT/OU=Devops/CN=private.repo.com" -newkey rsa:4096 -nodes -sha256 -keyout $CERT_PATH/registry-key.key -x509 -days 1825 -out $CERT_PATH/ca.crt  -extfile <(printf "subjectAltName = DNS:private.repo.com")

cd ../nginx/
echo $PWD

cp $CERT_PATH/ca.crt            ca.crt
cp $CERT_PATH/registry-key.key  registry-key.key

scp $CERT_PATH/ca.crt $USR@m1:/tmp/ && ssh david@m1 sudo mv /tmp/ca.crt /usr/local/share/ca-certificates/ && ssh $USR@m1  sudo update-ca-certificates
scp $CERT_PATH/ca.crt $USR@m2:/tmp/ && ssh david@m2 sudo mv /tmp/ca.crt /usr/local/share/ca-certificates/ && ssh $USR@m2  sudo update-ca-certificates
scp $CERT_PATH/ca.crt $USR@w1:/tmp/ && ssh david@w1 sudo mv /tmp/ca.crt /usr/local/share/ca-certificates/ && ssh $USR@w1  sudo update-ca-certificates
scp $CERT_PATH/ca.crt $USR@w2:/tmp/ && ssh david@w2 sudo mv /tmp/ca.crt /usr/local/share/ca-certificates/ && ssh $USR@w2  sudo update-ca-certificates
scp $CERT_PATH/ca.crt $USR@w3:/tmp/ && ssh david@w3 sudo mv /tmp/ca.crt /usr/local/share/ca-certificates/ && ssh $USR@w3  sudo update-ca-certificates



docker build --no-cache -t nginx-nexus-proxy .

cd ../
echo $PWD

# Run nginx and nexus containers
docker-compose up -d

#        ------------- Create /etc/docker/certs.d/private.repo.com/ on cluster node if container runtime is docker -------------------
#  ssh david@m1 sudo mkdir -p /etc/docker/certs.d/private.repo.com/ && scp david@192.168.254.10:/opt/certs/ca.crt /etc/docker/certs.d/private.repo.com/




