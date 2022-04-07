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

#        ------------- Create /etc/docker/certs.d/private.repo.com/ on cluster node if continerd is docker -------------------
#  ssh david@m1 sudo mkdir -p /etc/docker/certs.d/private.repo.com/ && scp david@192.168.254.10:/opt/certs/ca.crt /etc/docker/certs.d/private.repo.com/




#openssl req -x509 -out ../certs/cert.crt -keyout ../certs/cert.key -newkey rsa:2048 -nodes -sha256 -subj '/CN=private.repo.com' -extensions EXT -config <( \
#printf "[dn]\nCN=private.repo.com\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:private.repo.com\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")



cat << EOF >> ../certs/openssl.conf

[req]
req_extensions = v3_req
 distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
 basicConstraints = CA:FALSE
 keyUsage = nonRepudiation, digitalSignature, keyEncipherment
 subjectAltName = @alt_names
[ ssl_client ]
  extendedKeyUsage = clientAuth, serverAuth
  basicConstraints = CA:FALSE
  subjectKeyIdentifier=hash
  authorityKeyIdentifier=keyid,issuer
  subjectAltName = @alt_names
[ v3_ca ]
  basicConstraints = CA:TRUE
  keyUsage = nonRepudiation, digitalSignature, keyEncipherment
  subjectAltName = @alt_names
  authorityKeyIdentifier=keyid:always,issuer
  certificatePolicies = 192.168.254.10
[alt_names]
  DNS.1 = localhost
  DNS.2 = nexus-repo
  DNS.3 = docker-hub.kian.digital
  IP.1 = 192.168.254.10
  IP.2 = 127.0.0.1
  IP.3 = 172.17.0.0/16
  IP.4 = 172.18.0.0/16
EOF

#CONFIG=`echo ../certs//openssl.conf`

#openssl genrsa -out ../certs/rootCA.key 2048
#openssl req -subj "/CN=docker-hub.kian.digital"  -x509 -new -nodes -key ../certs/rootCA.key -days 10000  -out ../certs/rootCA.pem


#openssl genrsa -out ../certs/nexus3-key.pem 2048 
#openssl req    -subj "/CN=docker-hub.kian.digital" -new -key ../certs/nexus3-key.pem -out ../certs/nexus3.csr -config ${CONFIG}
#openssl x509   -req -in ../certs/nexus3.csr -CA ../certs/rootCA.pem -CAkey ../certs/rootCA.key -CAcreateserial -out ../certs/nexus3.cert -days 3650 -extensions ssl_client -extfile ${CONFIG}




# Generate Root Key rootCA.key with 2048
#openssl genrsa -passout pass:"$1" -des3 -out ../certs/rootCA.key 2048

# Generate Root PEM (rootCA.pem) with 1024 days validity.
#openssl req -passin pass:"$1" -subj "/C=IR/ST=Tehran/L=Tehran/O=Global Security/OU=Devops Department/CN=Local Certificate"  -x509 -new -nodes -key ../certs/rootCA.key -sha256 -days 2024  -out ../certs/rootCA.pem
#openssl req -passin pass:"$1"  -config ../certs/req.conf -extensions 'v3_req' -x509 -new -nodes -key ../certs/rootCA.key -sha256 -days 2048  -out ../certs/rootCA.pem

# Generate nexus Cert
#openssl req -subj "/C=IR/ST=Tehran/L=Tehran/O=Global Security/OU=Devops Department/CN=localhost"  -new -sha256 -nodes -out ../certs/nexus.csr -newkey rsa:2048 -keyout ../certs/nexuskey.pem
#openssl x509 -req -passin pass:"$1" -in ../certs/nexus.csr -CA ../certs/rootCA.pem -CAkey ../certs/rootCA.key -CAcreateserial -out ../certs/nexuscert.crt -days 2024 -sha256 -extfile <(printf "subjectAltName=DNS:localhost,DNS:nexus-repo")
#openssl x509 -req -passin pass:"$1" -config ../certs/req.conf -in ../certs/nexus.csr -CA ../certs/rootCA.pem -CAkey ../certs/rootCA.key -CAcreateserial -out ../certs/nexuscert.crt -days 2028 -sha256 

## Add root cert as trusted cert
#if [[ "$OSTYPE" == "linux-gnu"* ]]; then
#        # Linux
#        yum -y install ca-certificates
#        update-ca-trust force-enable
#        cp ../certs/rootCA.pem /etc/pki/ca-trust/source/anchors/
#        update-ca-trust
#elif [[ "$OSTYPE" == "darwin"* ]]; then
#        # Mac OSX
#        security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ../certs/rootCA.pem
#else
#        # Unknown.
#        echo "Couldn't find desired Operating System. Exiting Now ......"
#        exit 1
#fi
#

# Docker build nginx image
