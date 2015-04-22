#!/bin/bash

tag=`git describe --abbrev=0 --tags`
branch_name=$(git symbolic-ref -q HEAD)
branch_name=${branch_name##refs/heads/}
branch_name=${branch_name:-HEAD}

ID=$(sudo docker build -t local/${branch_name} .)
sudo docker tag $ID local/${branch_name}:${tag}
