(function() {
  var redis;

  redis = require("redis");

  module.exports = (function() {

    function exports(config) {
      this.config = config;
    }

    exports.prototype.start = function() {
      this.redis = redis.createClient(this.config.port, this.config.host);
      if (this.config.auth != null) {
        return this.redis.auth(this.config.auth, connected);
      } else {
        return connected();
      }
    };

    exports.prototype.connected = function() {
      var channel, _i, _len, _ref, _results,
        _this = this;
      this.redis.on("error", function(err) {
        return _this.error(err);
      });
      this.redis.on("subscribe", function(channel, count) {
        return log("redis ready");
      });
      this.redis.on("message", function(channel, message) {
        return _this.emit({
          channel: channel,
          message: message
        });
      });
      _ref = this.config.channels;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        channel = _ref[_i];
        _results.push(this.redis.subscribe(channel));
      }
      return _results;
    };

    return exports;

  })();

}).call(this);
