(function() {
  var FeedSub, inspect, _;

  FeedSub = require('feedsub');

  _ = require('underscore');

  inspect = require('util').inspect;

  module.exports = (function() {

    function exports(config) {
      this.config = config;
      this.config.feeds.map(function(feed) {
        var randomDelay;
        randomDelay = function(delay, interval) {
          return delay + Math.round(Math.random() * interval);
        };
        return this.subscribe({
          interval: randomInterval(this.config.min_delay, 20),
          forceInterval: false,
          autoStart: false,
          emitOnStart: false,
          lastDate: null,
          history: [],
          maxHistory: 50,
          skipHours: true,
          skipDays: true,
          requestOpts: {},
          url: feed
        });
      });
    }

    exports.prototype.start = function() {
      return this.readers.map(function(reader) {
        return reader.start();
      });
    };

    exports.prototype.subscribe_many = function(feeds) {
      var _this = this;
      return feeds.map(function(feed) {
        return _this.subscribe(feed);
      });
    };

    exports.prototype.subscribe = function(feed) {
      var reader,
        _this = this;
      reader = new FeedSub(feed.url, feed);
      reader.on('item', function(item) {
        var data;
        data = {
          source: _this.id,
          name: feed.name,
          text: item
        };
        return _this.emit(data);
      });
      reader.on('error', function(err) {
        return _this.error(err);
      });
      return this.readers.push(reader);
    };

    exports.prototype.flush = function() {
      this.readers.map(function(reader) {
        return reader.stop();
      });
      return this.readers = [];
    };

    return exports;

  })();

}).call(this);
