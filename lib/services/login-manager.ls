require! <[https yaml-js fs]>
{load, dump} = yaml-js
config_file = "#{process.env.HOME or process.env.USERPROFILE}/.glad-fleeter"
read-yml = fs.read-file-sync >> load
write-yml = dump >> fs.write-file-sync config_file, _

module.exports = new class LoginManager
  configs:
    deploy:
      required: yes
    remove:
      required: yes
    list-units:
      required: no
    login:
      required: no
    is-logged-in:
      required: no
  config:~ -> @configs.(command |> camelize)
  need_to_be_logged_in:~ -> @config.required
  is_logged_in:~ -> not Obj.empty @auth
  auth:~
    -> @config-file?.(\docker-auth) or {}
    (auth)->
      unless @config-file |> is-type \Object then @config-file = {}
      @config-file.(\docker-auth) = auth
  read: ->
    try
      @config-file = read-yml config_file
    catch e
      @auth = {}
  check: ->
    unless @need_to_be_logged_in then return
    unless @is_logged_in
      console.error "Prelase login!"
      process.exit!
  test: ({user, password}, cb)->
    login-settings =
      host: \index.docker.io
      path: \/v1/users/
      auth: "#user:#password"
    https
      .get login-settings, (res)->
        console.log \status-code:, res.status-code
        console.log \headers:, res.headers
        cb null, (res.status-code is 200)
      .on \error, ->
        console.error it
        cb it, false
  save: -> write-yml @config-file
  save_of: ({user, password, email})->
    @auth = {user, password, email}
    @save!

