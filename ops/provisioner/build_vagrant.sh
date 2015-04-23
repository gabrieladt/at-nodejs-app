#!/bin/bash
cd /
git clone https://github.com/gabrieladt/at-nodejs-app 
cd at-nodejs-app
git checkout develop 
tag=`git rev-parse  --short HEAD`
branch_name="develop"

#ID=$(sudo docker build -t local/${branch_name} .)
#sudo docker tag $ID local/${branch_name}:${tag}

sudo docker build -t ${branch_name}:${tag} .
sudo docker tag -f ${branch_name}:${tag} ${branch_name}:latest

sudo docker rmi $(sudo docker images | grep "^<none>" | awk "{print $3}") &

git checkout master
tag=`git rev-parse  --short HEAD`
branch_name="master"

#ID=$(sudo docker build -t local/${branch_name} .)
#sudo docker tag $ID local/${branch_name}:${tag}

sudo docker build -t ${branch_name}:${tag} .
sudo docker tag -f ${branch_name}:${tag} ${branch_name}:latest
