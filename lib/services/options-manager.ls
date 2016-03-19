require! <[minimist readline-sync moment]>
require! \./help-manager.ls
require! \./login-manager.ls
args = process.argv |> drop 2 |> minimist

module.exports = new class OptionsManager
  configs:
    deploy:
      confirmable: yes
      requirements: <[layout size tag]>
      relevants: <[layout size tag]>
    remove:
      confirmable: yes
      requirements: <[layout tag]>
      relevants: <[layout tag]>
    list-units:
      confirmable: no
      requirements: <[layout]>
      relevants: <[layout orderby]>
    login:
      confirmable: yes
      requirements: <[user password email]>
      relevants: <[user password email]>
    is-logged-in:
      confirmable: no
      requirements: []
      relevants: []
  config:~ -> @configs.(command |> camelize)
  needs_to_confirm:~ -> @config.confirmable
  read: ->
    global.{}options <<<
      help: args.h or args.help
      endpoint: args.e or args.endpoint
      layout: args.l or args.layout
      size: (args.s or args.size) |> parse-int |> ( or 0)
      tag: args.t or args.tag
      orderby: args.o or args.orderby
      user: args.u or args.user
      password: args.p or args.password
      email: args.e or args.email
    if command is \deploy then options.tag ?= timestamp
  check: -> <[help]> ++ @config.requirements |> each ~> @.("check_#it")!
  check_help: -> if options.help then help-manager.print @config.relevants
  check_layout: -> if not (options.layout? and options.layout.length > 0) then console.error "Please set layout path!!!"; help-manager.print @config.requirements
  check_tag: -> if not options.tag? then console.error "Please set tag!!!"; help-manager.print @config.requirements
  check_size: -> if not options.size > 0 then console.error "Please set size as a number greater than zero!!!"; help-manager.print @config.requirements
  check_user: -> if not options.user? then console.error "Place set user!!!"; help-manager.print @config.requirements
  check_password: -> if not options.password? then console.error "Place set password!!!"; help-manager.print @config.requirements
  check_email: -> if not options.email? then console.error "Place set email!!!"; help-manager.print @config.requirements
  confirm: (cb)->
    if not @config.confirmable then cb!; return
    switch readline-sync.question "ok? (yes or no):  "
    | \yes => cb!
    | \no => process.exit!
    | _ => @confirm cb
  print: ->
    @config.relevants |> each -> console.log "#{it}: #{options.(it)}"

