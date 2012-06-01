(function() {
  var SerialPort, parsers, _ref;

  _ref = require("serialport"), SerialPort = _ref.SerialPort, parsers = _ref.parsers;

  module.exports = (function() {

    function exports(config) {
      var conf;
      this.config = config;
      conf = this.config;
      delete conf.path;
      conf.parser = parsers.raw;
      this.serial = new SerialPort(this.config.path, conf);
    }

    exports.prototype.start = function() {
      var _this = this;
      this.serial.on("error", function(err) {
        return _this.error(err);
      });
      return this.serial.on("data", function(data) {
        return _this.emit({
          buffer: data
        });
      });
    };

    return exports;

  })();

}).call(this);
