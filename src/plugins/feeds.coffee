
# Copyright (c) 2011, Julian Bilcke <julian.bilcke@gmail.com>
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

FeedSub   = require 'feedsub'
_         = require 'underscore'
{inspect} = require 'util'

class module.exports
  
  constructor:  (@config) ->
    # TODO check config
    
    @config.feeds.map (feed) ->
      
      randomDelay = (delay,interval) -> delay + Math.round( (Math.random() * interval) )
            
      @subscribe 
        # DEFAULT CONFIG
        # number of minutes to wait between checking the feed for new items
        #
        interval: randomInterval(@config.min_delay,20)
      
        # some feeds contain a `ttl` tag that specifies the
        # number of minutes to cache the feed
        # setting this to true will ignore that
        forceInterval: false
      
        # if true, calls `reader.start()` on instanstiation
        autoStart: false
      
        # emits items on the very first request
        # after which, it should consider those items read
        emitOnStart: false
      
        # keeps track of last date of the feed
        lastDate: null
      
        # keeps track of last items read from the feed
        history: []
      
        # maximum size of `history` array
        maxHistory: 50
      
        # some feeds have a `skipHours` tag with a list of
        # hours in which the feed should not be read.
        # if this is set to true and the feed has that tag, it obeys that rule
        skipHours: true
        # same as `skipHours`, but with days
        skipDays: true
        # options object passed to the http(s).get function
        requestOpts: {}
        
        # url
        url: feed
    
  start: -> 
    @readers.map (reader) ->
      reader.start()
       
  subscribe_many: (feeds) ->
    feeds.map (feed) => @subscribe feed
 
  subscribe: (feed) ->
    reader = new FeedSub feed.url, feed
    reader.on 'item', (item) =>
      data =
        source: @id
        name: feed.name
        #foo: "bar"
        #date: "foo"
        text: item
      @emit data  
     reader.on 'error', (err) =>
       @error err
    @readers.push reader
      
  flush: ->
    @readers.map (reader) ->
      reader.stop()
    @readers = []