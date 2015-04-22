FROM ubuntu:14.04

# make sure apt is up to date
RUN apt-get update

# install nodejs and npm
RUN apt-get install -y nodejs npm git git-core

RUN mkdir /src
ADD . /src
# Install app dependencies
RUN cd /src; npm install

EXPOSE  3000
CMD ["nodejs", "/src/server.js"]

