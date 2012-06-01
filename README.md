# node-hydrant

*Complex event stream aggregator and broadcaster*

## Warning

  node-hydrant is still in development and not yet available for public use (it is not yet on NPM)

## Description

  node-hydrant is a simple stream aggregator.

  Hydrant read input from various data sources, and emit a single event stream.
  
  Current status: 

* Serialport: Read: 50% - Write: 0% - Tests: No - Usable: No
* Pachube: Read: 50% - Write: 0% - Tests: No - Usable: No
* Arduino (via Firmata): Read: 50% - Write: 0% - Tests: No - Usable: No
* ThingSpeak: Read: 50% - Write: 0% - Tests: No - Usable: No
* IRC Channels:  Read: 50% - Write: 0% - Tests: No - Usable: No
* RSS feeds: Read: 50% - Write: 0% - Tests: No - Usable: No
* Twitter:  70% (not tested yet)
* DataSift:  50% (not tested yet)
* ØMQ:  50% (not tested yet)
* Kafka:  50% (not tested yet)
* AMQP:  50% (not tested yet)
* STOMP:  50% (not tested yet)
* Cube:  50% (not tested yet)
* Graphite: 50% (not tested yet)
* Redis: 50% (not tested yet)
* PostgreSQL: 50% (not tested yet)
* Generic REST APIs:  50% (not tested yet)

## What it can be used for

  Some ideas, in random order: ambient colored lighting to show the current world mood, quake alerting systems, chatroom bots,
  text-to-speech or personal assistant systems, hacker devices, art installations..

## Licence

  BSD: [LICENCE.txt](https://github.com/daizoru/hook.io-hydrant/blob/master/LICENCE.txt))
  
## Installation

### Global install:

  For the moment this is not possible, but once it will be on NPM, you will be able to run:
  
``` bash
  npm install node-hydrant -g
```

  You need to have [npm](http://npmjs.org) installed.

### Local project install:

  Open your package.json and add this to dependencies:

``` yaml
  "node-hydrant": "0.0.0"
```

  Bind to the system. May need sudo depending on your NPM config:
  
    $ npm link

## Using plugins

  You need to install dependencies in your project,
  if you wish to use a plugin

*  "feedsub"           : "0.1.x"
*  "irc"               : "0.0.x"
*  "immortal-ntwitter" : "git://github.com/horixon/immortal-ntwitter.git"
*  "pachube-stream"    : "0.0.x"
*  "serialport"        : "0.7.x"
*  "zmq"               : "2.0.x"
*  "amqp"              : ">0.1.2"
*  "redis"             : "0.7.x"
*  "kafka"             : ">0.2.1"
*  "datasift"          : "0.2.x"
*  "stomp"              : "git://github.com/benjaminws/stomp-js.git"
  
## Creating a new Plugin

  Hydrant sources need to implement some kind of interface.
  Actually the syntax is really simple:
  
``` javascript 
  
  // here config come from the config file
  var Foo = function Foo(config) {
      this.config = config;
  };

  // Currently, there is only a start method.
  // on the future, maybe functions for stop, pause, update config, or debug?
  Foo.prototype.start = function() {
  
     // call emit when you catch an event
     this.emit({some: "data", foo: 45});
     this.emit("look, ma! nothing else to do!");
     
     // call error when something is wrong
     this.error("I failed");
  };
  
  module.exports = Foo;
``` 


  Using CoffeeScript:
  
``` coffeescript 
class module.exports

  constructor: (@config) -> 
    # default constructor. note that @config is saved.
    
  start: ->
    # we can access to @config from here, then
    @emit some: "data", foo: @config.bar
    @emit "look, ma! nothing else to do!"
    
    # ouch
    @error "I failed"
``` 

  Done.

  Want to see a real example? here is the Pachube plugin:
  
``` coffeescript 
{Connection} = require "pachube-stream"

class module.exports
  
  constructor: (@config) ->
    @pachube = new Connection @config.api_key

  start: -> 
    @pachube.on "error", (err) =>  @error err
    for uri in @config.feeds
      feed = @pachube.subscribe uri
      feed.on "complete", (data) => @emit data
      feed.on "data", (data) => @emit data
``` 


## Using Hydrant

  You need to setup your config file. 
  For the moment, hydrant will look for a "config.yml" file in the current dir.
  Yes I know, it sucks. I'll add optimist of other argv reader soon.
  
  That said, you can hack the code right now, and change this variable.
  
  I know you guys like YAML with mustaches, I mean, JSON.
  I find it a bit uneasy for config files (you can't put comments in it)
  but Hydrant can read them, to.

  
  
``` yaml

# some default settings
defaults:
  encoding: none # yaml, json, none
  compress: none # deflateRaw, deflate, gzip, or none 
  
  # default module for channels
  module: lib/plugins/rest
  
# unique channel name
test1:
  # syntax is the same than Node's require()
  module: lib/plugins/awesomeplugin

  # your plugin-specific config
  foo: bar
  bar: foo
  some_parameter: 42
``` 

  That's all!

## Running Instructions

  Change config.example.yml to config.yml, then run:
  
    $ ./bin/hydrant
  
  Or, if you have made changes in the source:
  
    $ npm run-script start

## Development Instructions

  Install development dependencies (can be quite slow if you are on a vintage telegraph):

    $ npm install --dev


  Run the tests (should compile CoffeeScript down to JavaScript):
  
    $ npm test
 
 
  Manual compile to JS:
  
    $ npm run-script build
  
    
  Watch for changes in the CoffeeScript sources, and automatically compile to JS:
  
    $ npm run-script watch
        
  
  Bind to the system. May need sudo depending on your NPM config:
  
    $ npm link

## Invocation from another Hook

  Feasible, but for the moment a bit funky, since Hydrant can't load hook.io-style config files yet

## Unreadable, machine-generated API

  Not yet

