(function() {
  var amqp;

  amqp = require('amqp');

  module.exports = (function() {

    function exports(config) {
      this.config = config;
      this.q = false;
    }

    exports.prototype.start = function() {
      var conf,
        _this = this;
      conf = this.config;
      delete conf['bind'];
      delete conf['queue'];
      this.cn = amqp.createConnection(conf);
      this.cn.on("ready", function() {
        _this.q = connection.queue(_this.config.queue);
        q.bind(_this.config.bind);
        return q.subscribe(function(msg) {
          return _this.emit(msg);
        });
      });
      this.on.on('error', function(err) {
        return _this.error(err);
      });
      return this.cn.on('close', function() {
        return _this.error("connection closed");
      });
    };

    return exports;

  })();

}).call(this);
