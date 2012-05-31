
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

Client = require('irc').Client
{log,error} = require "daizoru-toolbox"
{inspect} = require 'util'

class module.exports
  
  constructor: (@config) ->
    
  start: -> 
    # hack for irc library
    params = @config
    delete params.botname
    delete params.config
    # /hack
    @api = new Client @config.network, @config.botname, params

    @api.addListener 'error', (msg) ->
      @error "#{msg.command}: #{msg.args.join(' ')}"

    # TODO add a listener for each chanel
    #@bot.addListener 'message#{conf.channel}', (from, msg) ->
    #  console.log '<%s> %s', from, msg

    # cross-channel message listener
    @bot.addListener 'message', (from, to, msg) ->
      console.log '%s => %s: %s', from, to, msg
     # channel message
      if to.match /^[#&]/
        if msg.match /hello/i
          send 2000, bot.say to, 'Hello'
        if msg.match /hydrant/
          send 2000, bot.say to, "Hello, #{from}."
        else  
          @emit
            source: @id
            foo: "bar"
            date: "foo"
            text: msg
  
      else
        # private message
        console.log "received private msg:" + msg
        # quietly ignore
    
    # private message here, too?
    @bot.addListener 'pm', (nick, msg) ->
      console.log 'Got private message from %s: %s', nick, msg
      # quietly ignore

    @bot.addListener 'join', (channel, who) ->
      console.log '%s has joined %s', who, channel

    @bot.addListener 'part', (channel, who, reason) ->
      console.log '%s has left %s: %s', who, channel, reason

    @bot.addListener 'kick', (channel, kicked, kicker, reason) ->
      console.log '%s was kicked from %s by %s: %s', kicked, channel, kicker, reason
      # log error if WE are kicked