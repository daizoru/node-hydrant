assert = require 'assert'
lib = ''
       
require('vows')
  .describe('hydrant')
  .addBatch
    'module':
      topic: -> '../lib/hydrant'
      'is require-able': (topic) ->
        assert.doesNotThrow -> lib = require topic

  .export module