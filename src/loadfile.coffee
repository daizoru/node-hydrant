

exports.loadFile = loadFile = (path, cb) ->
  switch path.split(".")[-1..].toLowerCase()
    when "js", "json"
      fs.readFile path, (err, raw) =>
        if err?
          cb err, {}
        else
          cb no, JSON.parse(raw)
    when "yml", "yaml" 
      YAML.readFile path, (err, obj) => 
        if err?
          cb err, {}
        else
          cb no, obj[0]
    else
      fs.readFile path, (err, raw) =>
        if err?
          cb err, {}
        else
          cb no, "#{raw}".split "\n"
