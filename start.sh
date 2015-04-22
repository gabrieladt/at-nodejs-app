cd /tmp

# try to remove the repo if it already exists
rm -rf at-nodejs-app; true

git clone https://github.com/gabrieladt/at-nodejs-app

cd at-nodejs-app

npm install

nodejs .
