require! \../services/login-manager.ls

module.exports = ->
  if login-manager.is_logged_in
    console.log "You are already logged in."
  else
    console.log "Not logged in yet."

