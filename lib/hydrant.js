(function() {
  var Stream, YAML, fs, inspect, loadFile, zlib, _,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  Stream = require('stream').Stream;

  fs = require('fs');

  inspect = require('util').inspect;

  zlib = require('zlib');

  _ = require('underscore');

  YAML = require('libyaml');

  loadFile = require('./loadfile');

  module.exports = (function(_super) {

    __extends(exports, _super);

    function exports(options) {
      this.uninstall = __bind(this.uninstall, this);
      this.start = __bind(this.start, this);
      this.install = __bind(this.install, this);
      this.error = __bind(this.error, this);
      this.log = __bind(this.log, this);
      this.configure = __bind(this.configure, this);
      var _this = this;
      this.started = false;
      this.streams = {};
      if (_.isString(options)) {
        loadFile(options, function(config) {
          return _this.configure(config);
        });
      } else {
        this.configure(options);
      }
    }

    exports.prototype.configure = function(config) {
      var conf, stream, _ref, _ref2,
        _this = this;
      this.config = config;
      this.encode = function(obj, cb) {
        return cb(void 0, obj);
      };
      if (((_ref = this.config.defaults) != null ? _ref.encoding : void 0) === "yaml") {
        this.log("encoding is yaml");
        switch (this.config.serialize.compress) {
          case "none":
            this.encode = function(obj, cb) {
              return cb(void 0, YAML.stringify(obj));
            };
            break;
          case "deflate":
            this.encode = function(obj, cb) {
              return zlib.deflate(YAML.stringify(obj), cb);
            };
            break;
          case "deflateRaw":
            this.encode = function(obj, cb) {
              return zlib.deflateRaw(YAML.stringify(obj), cb);
            };
            break;
          case "gzip":
          case "gz":
            this.encode = function(obj, cb) {
              return zlib.gzip(YAML.stringify(obj), cb);
            };
        }
      } else if (((_ref2 = this.config.serialize) != null ? _ref2.encoding : void 0) === "json") {
        switch (this.config.serialize.compress) {
          case "none":
            this.encode = function(obj, cb) {
              return cb(void 0, JSON.stringify(obj));
            };
            break;
          case "deflate":
            this.encode = function(obj, cb) {
              return zlib.deflate(JSON.stringify(obj), cb);
            };
            break;
          case "deflateRaw":
            this.encode = function(obj, cb) {
              return zlib.deflateRaw(JSON.stringify(obj), cb);
            };
            break;
          case "gzip":
          case "gz":
            this.encode = function(obj, cb) {
              return zlib.gzip(JSON.stringify(obj), cb);
            };
        }
      }
      this.log("Configuration loaded. Installing plugins:");
      for (stream in config) {
        conf = config[stream];
        if ((stream[0] !== '_') && (stream !== "defaults")) {
          if (_.isString(conf)) {
            this.log("loading config file");
            loadFile(conf, function(err, conf) {
              _this.log("C");
              if (err) {
                return _this.error("" + (inspect(err)));
              } else {
                return _this.install(stream, conf);
              }
            });
          } else {
            this.install(stream, conf);
          }
        }
      }
    };

    exports.prototype.log = function(msg) {
      return console.log("" + msg);
    };

    exports.prototype.error = function(msg) {
      return console.error("" + msg);
    };

    exports.prototype.install = function(name, config) {
      var conf, modulePath, stream, _ref,
        _this = this;
      modulePath = "lib/plugins/none";
      if (((_ref = this.config["default"]) != null ? _ref.module : void 0) != null) {
        this.log("using default module: " + this.config["default"].module);
        modulePath = this.config["default"].module;
      }
      if (config.module != null) {
        this.log("using asked module: " + config.module);
        modulePath = config.module;
      }
      Stream = require(modulePath);
      conf = config;
      delete conf.module;
      stream = new Stream(conf);
      stream.emit = function(data) {
        data.stream = name;
        return _this.encode(data, function(err, data) {
          if (err != null) {
            return _this.error(" - [" + name + "] error when encoding message: " + (inspect(err)));
          } else {
            return _this.emit("input", data);
          }
        });
      };
      stream.error = function(err) {
        return _this.error("ERROR " + name + ": " + err);
      };
      this.streams[name] = stream;
      this.log(" - added " + name + " stream");
      if (this.started) {
        stream.start();
        return this.log(" - started " + name + " stream");
      }
    };

    exports.prototype.start = function() {
      var name, stream, _ref, _results;
      this.started = true;
      _ref = this.streams;
      _results = [];
      for (name in _ref) {
        stream = _ref[name];
        stream.start();
        _results.push(this.log(" - started " + name + " stream"));
      }
      return _results;
    };

    exports.prototype.uninstall = function(name) {
      this.log("uninstall " + name);
      this.streams[name].stop();
      return delete this.streams[name];
    };

    return exports;

  })(Stream);

}).call(this);
