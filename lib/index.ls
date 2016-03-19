require! <[gulp moment fs]>
require! \./services/command-manager.ls
require! \./services/login-manager.ls
require! \./services/options-manager.ls
global <<< timestamp: moment!.format "YYYY-MM-DD-HH-mm-ss"

module.exports =
  run: ->
    command-manager.read!
    command-manager.check!
    login-manager.read!
    login-manager.check!
    options-manager.read!
    options-manager.check!
    options-manager.print!
    <- options-manager.confirm!
    command-manager.commands.(command |> camelize)!
