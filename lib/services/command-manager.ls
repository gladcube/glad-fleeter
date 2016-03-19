require! <[fs]>
commands = require \../commands/index.ls

module.exports = new class CommandManager
  commands: commands
  read: ->
    global <<< command: (process.argv.2 or "" |> camelize)
  check: -> if command not in (@commands |> keys) then @print_error!; process.exit!
  print_error: ->
    console.error "Please specify a command (in #{@commands |> keys |> map dasherize |> join ", "})!!!"
