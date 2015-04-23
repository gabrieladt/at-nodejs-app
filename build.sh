#!/bin/bash

tag=`git rev-parse  --short HEAD`
#branch_name=`git ls-remote --heads origin | grep $(git rev-parse HEAD) | cut -d / -f 3 | head -n1`
branch_name=$1

#ID=$(sudo docker build -t local/${branch_name} .)
#sudo docker tag $ID local/${branch_name}:${tag}

sudo docker build -t ${branch_name}:${tag} .
sudo docker tag -f ${branch_name}:${tag} ${branch_name}:latest

sudo docker rmi $(sudo docker images | grep "^<none>" | awk "{print $3}") &

