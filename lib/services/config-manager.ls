require! <[yaml-js fs]>
{load, dump} = yaml-js
config_file = "#{process.env.HOME or process.env.USERPROFILE}/.glad-fleeter"
read-yml = fs.read-file-sync >> load
write-yml = dump >> fs.write-file-sync config_file, _

module.exports = new class ConfigManager
  -> @read!
  read: ->
    try
      @config-file = read-yml config_file
    catch e
      @auth = {}
  auth:~
    -> @config-file?.(\docker-auth) or {}
    (auth)->
      unless @config-file |> is-type \Object then @config-file = {}
      @config-file.(\docker-auth) = auth
  save: -> write-yml @config-file

