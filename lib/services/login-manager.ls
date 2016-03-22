require! <[https]>
require! \./config-manager

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
    -> config-manager.auth
    (auth)-> config-manager.auth = auth
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
  save: -> config-manager.save!
  save_of: ({user, password, email})->
    @auth = {user, password, email}
    @save!

