require! \../services/login-manager.ls

module.exports = ->
  console.log "test login start!"
  err, is_valid <- login-manager.test options
  if is_valid
    console.log "test login successful."
    console.log "save to config file."
    login-manager.save_of options
  else
    console.log "test login faild..."

