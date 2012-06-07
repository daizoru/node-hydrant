# node-hydrant

*Complex event stream aggregator and broadcaster*

## Warning

  node-hydrant is still in development and not yet available for public use (it is not yet on NPM)

## Description

  node-hydrant is a simple stream aggregator.

  Hydrant read input from various data sources, and emit a single event stream.
  
  For the moment there is not a lot of things that work (Twitter is working, in read-only),
  but in the future tests should be added, more examples, and maybe some output/push/write functions.

  Current status: 

* Twitter:  Read: 80% - Write: 0% - Tests: No - Usable: hell yes!!
* Serialport: Read: 50% - Write: 0% - Tests: No - Usable: No
* Pachube: Read: 50% - Write: 0% - Tests: No - Usable: No
* Arduino (via Firmata): Read: 50% - Write: 0% - Tests: No - Usable: No
* ThingSpeak: Read: 50% - Write: 0% - Tests: No - Usable: No
* IRC Channels:  Read: 50% - Write: 0% - Tests: No - Usable: No
* RSS feeds: Read: 50% - Write: 0% - Tests: No - Usable: No
* DataSift: Read: 50% - Write: 0% - Tests: No - Usable: No
* ØMQ:  Read: 50% - Write: 0% - Tests: No - Usable: No
* Kafka:  Read: 50% - Write: 0% - Tests: No - Usable: No
* AMQP:  Read: 50% - Write: 0% - Tests: No - Usable: No
* STOMP:  Read: 50% - Write: 0% - Tests: No - Usable: No
* Cube:  Read: 50% - Write: 0% - Tests: No - Usable: No
* Graphite: Read: 50% - Write: 0% - Tests: No - Usable: No
* Redis: Read: 50% - Write: 0% - Tests: No - Usable: No
* PostgreSQL: Read: 50% - Write: 0% - Tests: No - Usable: No
* Generic REST APIs:  Read: 50% - Write: 0% - Tests: No - Usable: No

## Use cases

  Hydrant is designed to sip data from heterogeneous streams (web/irc/twitter etc..), in order to detect meaningful events from the "world wild noise" (this is a separate private project, not available on github). 

  However this can be used for a variety of purposes. The "do something with the data" part is left as an exercice to you, "software creator", but if you need ideas: play with Arduino, Twitter stream, create an alert system if people on irc, blogs or tweet "earthquake", "market collaspe", "it's snowing", "raining" or "iPhone 5", if your app is sending alerts over your company message queue..

## Licence

  BSD: [LICENCE.txt](https://github.com/daizoru/hook.io-hydrant/blob/master/LICENCE.txt))
  
## TODO

  Implement 
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

## Using it

### Using JavaScript

``` javascript
#!/usr/bin/env node

var inspect = require('util').inspect;
var Hydrant = require('hydrant');

var hydrant = new Hydrant({
  // DEFAULT SETTINGS
  // you can optionaly convert the event's jsObject to string (JSON or YAML)
  // and compress this string, too
  defaults: {
    encoding: false, // yaml, json, none
    compress: false // deflateRaw, deflate, gzip, or none
  },

  // STREAMS
  // each stream must have it's own unique name (here this is "twitter")
  twitter: {
    module: './input/twitter',
    consumer_key: 'CONSUMER_KEY',
    consumer_secret: 'CONSUMER_SECRET',
    access_token_key: 'ACCESS_TOKEN_KEY',
    access_token_secret: 'ACCES_TOKEN_SECRET',
    endpoint: 'statuses/filter',
    search: {
      track: 'node,javascript,clojure'
    },
    ignores: [
      "data.text.length < 40", (function() {
        return Math.random() > 0.05;
      })
    ]
  }
});

hydrant.on('input', function(msg) {
  return console.log(" >> INPUT " + (inspect(msg)));
});

// start listening to the streams
hydrant.start();
```

### Using CoffeeScript

``` coffeescript 
#!/usr/bin/env coffee

Hydrant = require 'hydrant'
{inspect} = require 'util'
hydrant = new Hydrant
  # DEFAULT SETTINGS
  # you can optionaly convert the event's jsObject to string (JSON or YAML)
  # and compress this string, too
  defaults:
    encoding: no # yaml, json, none
    compress: no # deflateRaw, deflate, gzip, or none

  # STREAMS
  # each stream must have it's own unique name (here this is "twitter")
  twitter:
    module:               './input/twitter'

    consumer_key:         'CONSUMER_KEY'
    consumer_secret:      'CONSUMER_SECRET'
    access_token_key:     'ACCESS_TOKEN_KEY'
    access_token_secret:  'ACCES_TOKEN_SECRET'
  
    endpoint: 'statuses/filter' # or 'statuses/sample' (remove 'search' in this case)
    search:
      track: 'node,javascript,clojure'

    # you can pass conditions to ignore some entries of the flow
    # warning: they are directly executed by Node, so be sure
    # your Hydrant config file come from a trusted source!
    ignores: [
      "data.text.length < 40"   # if you are using json/yml, you can use plain text
      (-> Math.random() > 0.05) # or if you are in a JS/Coffee context, use some real code!
    ]
hydrant.on 'input', (msg) ->
  console.log " >> INPUT #{inspect msg}"

hydrant.start()
```



### Using Config files

  
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

## Playing with data sources / sinks, aka Hydrant Plugins

  You need to install dependencies in your project,
  if you wish to use plugins:

*  "feedsub"           : "0.1.x"
*  "irc"               : "0.0.x"
* # (not used for the moment: "immortal-ntwitter" : "git://github.com/horixon/immortal-ntwitter.git")
*  "ntwitter"          : "0.3.0"
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


