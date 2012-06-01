(function() {
  var rest;

  rest = require('restler');

  module.exports = (function() {

    function exports(config) {
      this.config = config;
    }

    exports.prototype.start = function() {
      var query, url, _i, _len, _ref, _results,
        _this = this;
      _ref = this.config.urls;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        url = _ref[_i];
        query = rest.get(url);
        query.on('complete', function(data) {
          return _this.emit(data[0]);
        });
        _results.push(query.on('error', function(err) {
          return _this.error(err);
        }));
      }
      return _results;
    };

    return exports;

  })();

}).call(this);
