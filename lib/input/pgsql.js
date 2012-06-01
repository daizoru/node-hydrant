(function() {
  var Connection;

  Connection = require("pachube-stream").Connection;

  module.exports = (function() {

    function exports(config) {
      this.config = config;
      this.pachube = new Connection(this.config.api_key);
    }

    exports.prototype.start = function() {
      var feed, uri, _i, _len, _ref, _results,
        _this = this;
      this.pachube.on("error", function(err) {
        return _this.error(err);
      });
      _ref = this.config.feeds;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        uri = _ref[_i];
        feed = this.pachube.subscribe(uri);
        feed.on("complete", function(data) {
          return _this.emit(data);
        });
        _results.push(feed.on("data", function(data) {
          return _this.emit(data);
        }));
      }
      return _results;
    };

    return exports;

  })();

}).call(this);
