#!/usr/bin/env coffee
fs = require 'fs'
xml2js = require 'xml2js'

opml2array = (path, cb) ->
  p = new xml2js.Parser()
  fs.readFile path, (err, data) -> 
    p.parseString data, (err, result) ->
      cb (entry['@'].xmlUrl for entry in result.body.outline)

opml2array __dirname + '/../feeds.xml', (feeds) ->
  console.dir feeds
