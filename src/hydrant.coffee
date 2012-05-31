
# Copyright (c) 2011, Julian Bilcke <julian.bilcke@daizoru.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of Julian Bilcke, Daizoru nor the
#      names of its contributors may be used to endorse or promote products
#      derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL JULIAN BILCKE OR DAIZORU BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Node.js API built-ins
events = require 'events'
fs = require 'fs'
{inspect} = require 'util'
zlib = require 'zlib'

# dependencies
_ = require 'underscore'
YAML = require 'libyaml'

# project components
loadFile = require './loadfile'

class module.exports extends events.EventEmitter
  constructor: (options) ->  

    @streams = []
    
    if _.isString options
      loadFile options, (config) =>
        @configure config
    else
      @configure options
 
  configure: (config) =>
    @config = config

    @encode = (obj, cb) -> cb undefined, obj
    
    # maybe too much optimized for performance
    if @config.defaults?.encoding is "yaml"
      @log "encoding is yaml"
      switch @config.serialize.compress
        when "none"
          @encode = (obj, cb) -> cb undefined, YAML.stringify(obj)
        when "deflate"
          @encode = (obj, cb) -> zlib.deflate YAML.stringify(obj), cb
        when "deflateRaw"
          @encode = (obj, cb) -> zlib.deflateRaw YAML.stringify(obj), cb
        when "gzip", "gz"
          @encode = (obj, cb) -> zlib.gzip YAML.stringify(obj), cb
    else if @config.serialize?.encoding is "json"   
      switch @config.serialize.compress
        when "none"
          @encode = (obj, cb) -> cb undefined, JSON.stringify(obj)
        when "deflate"
          @encode = (obj, cb) -> zlib.deflate JSON.stringify(obj), cb
        when "deflateRaw"
          @encode = (obj, cb) -> zlib.deflateRaw JSON.stringify(obj), cb
        when "gzip", "gz"
          @encode = (obj, cb) -> zlib.gzip JSON.stringify(obj), cb

    @log "Configuration loaded. Installing plugins:"
    for stream, conf of config
      if stream[0] isnt '_' and stream isnt "defaults"
        if _.isString conf
          loadFile conf, (err, conf) => 
            if err
              @error "#{inspect err}"
            else
              @install stream, conf
        else
          @install stream, conf
    
  log: (msg) =>
    console.log "#{msg}"
  error: (msg) =>
    console.error "#{msg}"

  onAny: (msg, cb) ->

  # install a new service
  install: (name, config) ->
    modulePath = "lib/plugins/rest"
    if @config.default?
      modulePath ?= @config.default.module
    modulePath ?= config.module
    Stream = require modulePath
    conf = config
    delete conf.module
    stream = new Stream conf
    stream.emit = (data) =>
      @encode data, (err,data) =>
        if err?
          @error " - [#{name}] error when encoding message: #{inspect err}"  
        else
          @log " - [#{name}] event: #{inspect data}"
          @emit "#{name}", data
    stream.error = (err) => 
      @error " - [#{name}]: #{inspect err}" 
    @streams.push stream
    @log " - installed #{name}"
    stream.start()

  uninstall: (name) ->
    @log "uninstall #{name}"
    @streams[name].stop()
    delete @streams[name]
