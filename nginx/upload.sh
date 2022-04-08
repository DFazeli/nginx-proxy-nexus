#!/usr/bin/env bash
NEXUS=192.168.254.10 #nexus.kryukov.local
SRC_DIR=/root/images
KUBE_VERSION=v1.23.5
cd

for FILE in $( ls $SRC_DIR )
do
    if [ -f $SRC_DIR/$FILE ]; then
        echo "upload $SRC_DIR/$FILE"
        curl -v -u admin:1 --upload-file $SRC_DIR/$FILE http://$NEXUS:8081/repository/files/k8s/$KUBE_VERSION/$FILE
    fi
done
