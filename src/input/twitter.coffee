
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
{inspect} = require 'util'
_ = require 'underscore'
ntwitter = require 'ntwitter'

class module.exports
  
  constructor: (@config) ->
    @endpoint = 'statuses/sample'
    if @config.endpoint?
      @endpoint = @config.endpoint

    @search = undefined
    if @config.search?
      @search = @config.search

    @filters = []
    if @config.ignores?
      for ignore in @config.ignores
        @filters.push ignore
      delete @config['ignores']
    @twitter = new ntwitter @config


  start: => 
    # rate limit: 400 keywords, 5,000 follow userids
    @twitter.stream @endpoint, @search, (s) =>

      process = (data) =>
        #console.log "data: #{inspect data}"
        for filter in @filters
          ignore = if _.isString(filter) then eval(filter) else filter(data)
          return if ignore
        #console.log "data.text: #{inspect data.text}"
        @emit text: data.text

      s.on 'error', (err) => 
        if err.text? # ntwitter is buggy - no time to fix it right now
          process err
        else     
          @error "#{inspect err}"
      s.on 'data', (data) => process data

