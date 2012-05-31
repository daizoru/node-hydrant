# hook.io-hydrant

*Complex event stream aggregator and broadcaster*

## Description

  WARNING: Hydrant is still in heavy development, and might be subject to drastic changes from one commit to another
  
  WARNING2: Most of the sources are buggy / untested / not working yet. But it is easy to fix. Give me some time, and I'll do it!
  
  Hydrant read input from various data sources, and emit a single event stream.
  
  Planned support: Serialport, Pachube, Firmata (Arduino), ThingSpeak, IRC Channels, RSS feeds, Twitter, DataSift, ØMQ, Kafka, AMQP, STOMP, Cube, Graphite, Redis, PostgreSQL, with also support for generic REST APIs.
  
  For the moment most of these protocols are not fully functional with Hydrant.
 
  You cannot send or write data easily, as Hydrant is a read-only system
  designed for the lost art of hydromancy.

  But feel free to fork and add write functions (hook messages) if you need them. My goal on this project is to have a minimalist read-only streams, so I cut out everything that is not needed.

## Use cases, or how could you use it
  
  Some ideas, in random order: ambient colored lighting to show the current world mood, quake alerting systems, chatroom bots,
  text-to-speech or personal assistant systems, hacker devices, art installations..


## TODO

  * Make it work
  * open-source it for real (tests + NPM package + announce on the internets)
  * Implement push / writes / emits / send / set (that it - output!)
  * Separate Hook.io wrapper from Hydrant core (to make it work on Vert.x, Meteor..)
  * More test! More plugins!

## Licence

  BSD: Do what you want. Control your own life. I'm not responsible if you get damaged in the process (see [LICENCE.txt](https://github.com/daizoru/hook.io-hydrant/blob/master/LICENCE.txt) for details).
  
## Installation

### Global install:

  This way:
  
``` bash
  npm install hook.io-hydrant -g
```

  You need to have [npm](http://npmjs.org) installed.

### Local project install:

  Open your package.json and add this to dependencies:

``` yaml
  "hook.io-hydrant": "0.0.0"
```

  Bind to the system. May need sudo depending on your NPM config:
  
    $ npm link

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
  
  
### Optional native modules and optimizations

You can install all the optional dependencies
  
#### Redis Plugin

  For the redis plugin, ou can optionally install node-hiredis. To quote the node-redis README:
  
  "Pieter Noordhuis has provided a binding to the official hiredis C library, which is non-blocking and fast. To use hiredis, do:

  npm install hiredis
  If hiredis is installed, node_redis will use it by default. Otherwise, a pure JavaScript parser will be used.

   If you use hiredis, be sure to rebuild it whenever you upgrade your version of node. There are mysterious failures that can happen between node and native code modules after a node upgrade."

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

