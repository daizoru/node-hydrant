(function() {
  var kafka;

  kafka = require('kafka');

  module.exports = (function() {

    function exports(config) {
      var conf;
      this.config = config;
      conf = {
        host: 'localhost',
        port: 9092,
        pollInterval: 2000,
        maxSize: 1048576
      };
      if (conf.host == null) conf.host = this.config.host;
      if (conf.port == null) conf.port = this.config.port;
      if (conf.pollInterval == null) conf.pollInterval = this.config.pollInterval;
      if (conf.maxSize == null) conf.maxSize = this.config.maxSize;
      this.topics = {};
      if (this.topics == null) this.topics = this.config.topics;
      this.consumer = new kafka.Consumer(conf);
    }

    exports.prototype.start = function() {
      var _this = this;
      this.consumer.connect(function() {
        var partition, topic, _ref, _results;
        _ref = _this.topics;
        _results = [];
        for (topic in _ref) {
          partition = _ref[topic];
          _results.push(_this.consumer.subscribeTopic({
            name: topic,
            partition: partition
          }));
        }
        return _results;
      });
      this.consumer.on("error", function(err) {
        return _this.error(err);
      });
      return this.consumemr.on("message", function(topic, message) {
        return _this.emit({
          topic: topic,
          msg: message
        });
      });
    };

    return exports;

  })();

}).call(this);
