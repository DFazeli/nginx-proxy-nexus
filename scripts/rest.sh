#!/bin/bash

rm -fr ../certs/ && echo "remove ../certs/ Dir"
rm -fr /opt/certs/ && echo "remove ../certs/ Dir"
docker stop $(docker ps -aq) && docker container prune -f
