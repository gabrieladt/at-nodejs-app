
var express = require('express');
var morgan = require('morgan');
var http = require('http');

var app = express();
var server = http.createServer(app);


// setup request logging
app.use(morgan('combined'));


app.get('/aaaa', function (req, res) {
  res.json({data: 'bbbb'});
});

app.get('/bbbb', function (req, res) {
  res.json({data: 'bbbb'});
});

app.get('/ping', function (req, res) {
  res.json({data: 'pong'});
});
// API routes
app.get('/ping', function (req, res) {
  res.json({data: 'pong'});
});

app.get('/hello/:name', function (req, res) {
  res.json({data: 'Hello, ' + req.params.name});
});

app.get('/gf/:name', function (req, res) {
  res.json({data: 'GF, ' + req.params.name});
});

// On `ready` & `error` handling.
server.on('error', function onError(err) {
  server.errorEmitted = err;
  typeof server.readyCallback === 'function' && server.readyCallback(err);
});
server.on('ready', function onReady() {
  server.readyEmitted = true;
  typeof server.readyCallback === 'function' && server.readyCallback(null);
});

server.ready = function ready(done) {
  if (server.errorEmitted) { return done(server.errorEmitted); }
  if (server.readyEmitted) { return done(null); }
  server.readyCallback = done;
};

server.listen(3000, function () {
  var host = server.address().address;
  var port = server.address().port;
  console.log('Example app listening at http://%s:%s', host, port);

  server.emit('ready');
});

module.exports = server;
