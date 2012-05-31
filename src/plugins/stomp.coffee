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

sys = require "util"
stomp = require "stomp"

class module.exports
  
  constructor: (@config) ->
    conf =
      port: 61613
      host: "localhost"
      debug: no
      login: "guest"
      passcode: "guest"
      prefetchSize: 10
      queue: '/queue/test_stomp'

    for k, v of @config
      conf[k] = v
    @config = conf  
    @client = new stomp.Stomp conf

    @headers =
      destination: conf.queue
      ack: "client"
      "activemq.prefetchSize": conf.prefetchSize

  start: ->
    @messages = 0
    @client.connect()
    @client.on "connected", ->
      @client.subscribe @headers
      @emit "Connected"

    @client.on "message", (message) ->
      @emit "Got message: #{@message.headers['message-id']}"
      @client.ack @message.headers["message-id"]
      @messages++

    @client.on "error", (error_frame) ->
      @error error_frame.body
      @client.disconnect()

    process.on "SIGINT", ->
      @console.log "\nConsumed " + @messages + " messages"
      @client.disconnect()

