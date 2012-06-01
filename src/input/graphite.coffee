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

rest = require 'restler'

class module.exports
  
  constructor: (@config) ->
    @host = @config.host
  start: ->
    for name, metric of @config.metrics
       url = @host + "/render?format=raw"
       url += "?target=alias(#{metric.expression},'')"
       url += "&from=#{metric.start}"
       url += "&until=#{metric.stop}"
      query = rest.get url
      query.on 'complete', (data) =>
        for value in data
          @emit data.value
      query.on 'error', (err) => @error err

graphiteFormatDate = (time) ->
  Math.floor time / 1000

graphiteParse = (text) ->
  i = text.indexOf("|")
  meta = text.substring(0, i)
  c = meta.lastIndexOf(",")
  b = meta.lastIndexOf(",", c - 1)
  a = meta.lastIndexOf(",", b - 1)
  start = meta.substring(a + 1, b) * 1000
  step = meta.substring(c + 1) * 1000
  text.substring(i + 1).split(",").slice(1).map (d) -> +d

### Shamelessly forked from cubism.js
cubism_contextPrototype.graphite = (host) ->
  host = ""  unless arguments.length
  source = {}
  context = this
  source.metric = (expression) ->
    context.metric ((start, stop, step, callback) ->
      d3.text host + "/render?format=raw" + "&target=" + encodeURIComponent("alias(" + expression + ",'')") + "&from=" + cubism_graphiteFormatDate(start - 2 * step) + "&until=" + cubism_graphiteFormatDate(stop - 1000), (text) ->
        return callback(new Error("unable to load data"))  unless text
        callback null, cubism_graphiteParse(text)
    ), expression += ""

  source.find = (pattern, callback) ->
    d3.json host + "/metrics/find?format=completer" + "&query=" + encodeURIComponent(pattern), (result) ->
      return callback(new Error("unable to find metrics"))  unless result
      callback null, result.metrics.map((d) ->
        d.path
      )

  source.toString = ->
    host

  source 

###
