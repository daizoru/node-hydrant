#!/usr/bin/env coffee

Hydrant = require 'hydrant'
{inspect} = require 'util'
hydrant = new Hydrant
  defaults:
    encoding: no # yaml, json, none
    compress: no # deflateRaw, deflate, gzip, or none

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