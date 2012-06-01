(function() {
  var inspect, ntwitter, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  inspect = require('util').inspect;

  _ = require('underscore');

  ntwitter = require('ntwitter');

  module.exports = (function() {

    function exports(config) {
      var ignore, _i, _len, _ref;
      this.config = config;
      this.start = __bind(this.start, this);
      this.filters = [];
      if (this.config.ignores != null) {
        _ref = this.config.ignores;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          ignore = _ref[_i];
          this.filters.push(ignore);
        }
        delete this.config['ignores'];
      }
      this.twitter = new ntwitter(this.config);
    }

    exports.prototype.start = function() {
      var _this = this;
      return this.twitter.stream('statuses/sample', void 0, function(s) {
        var process;
        process = function(data) {
          var filter, ignore, _i, _len, _ref;
          _ref = _this.filters;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            filter = _ref[_i];
            ignore = _.isString(filter) ? eval(filter) : filter(data);
            if (ignore) return;
          }
          return _this.emit({
            text: data.text
          });
        };
        s.on('error', function(err) {
          if (err.text != null) {
            return process(err);
          } else {
            return _this.error("" + (inspect(err)));
          }
        });
        return s.on('data', function(data) {
          return process(data);
        });
      });
    };

    return exports;

  })();

}).call(this);
