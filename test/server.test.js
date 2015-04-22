var expect = require('chai').expect;
var request = require('supertest');
var server = require('../server');

describe('server', function () {

  before(function(done) {
    server.ready(done);
  });

  it('should respond with `pong`', function(done) {
    request(server)
      .get('/ping')
      .expect(200)
      .end(function(err, res) {
        if (err) { return done(err); }

        expect(res.body).to.exist;
        expect(res.body.data).to.exist;
        expect(res.body.data).to.equal('pong');
        done(null);
      });
  });

  it('should respond with `Hello, world`', function(done) {
    request(server)
      .get('/hello/world')
      .expect(200)
      .end(function(err, res) {
        if (err) { return done(err); }

        expect(res.body).to.exist;
        expect(res.body.data).to.exist;
        expect(res.body.data).to.equal('Hello, world');
        done(null);
      });
  });
});
