#!/bin/bash

tag=`git rev-parse  --short HEAD`
branch_name=`git ls-remote --heads origin | grep $(git rev-parse HEAD) | cut -d / -f 3`

ID=$(sudo docker build -t local/${branch_name} .)
sudo docker tag $ID local/${branch_name}:${tag}
