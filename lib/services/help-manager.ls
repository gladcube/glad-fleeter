require! <[cli-table]>

module.exports = new class HelpManager
  flags:
    layout:
      key: "-l --layout"
      description: "layout path"
    size:
      key: "-s --size"
      description: "layout size (used when deploy)"
    tag:
      key: "-t --tag"
      description: "tag (if not specified, timestamp is set as a default value)"
    orderby:
      key: "-o --orderby"
      description: "order by it (use it only with 'list-units' command)"
    user:
      key: "-u --user"
      description: "user name for docker login."
    password:
      key: "-p --password"
      description: "password for docker login."
    email:
      key: "-e --email"
      description: "e-mail address for docker login."
  print: (requirements)->
    table = new cli-table head: <[key description]>
    @flags
    |> obj-to-pairs
    |> filter -> if requirements? then it.0 in requirements else true
    |> map ( .1)
    |> each -> table.push [it.key, it.description]
    console.log table.to-string!
    process.exit!
  print_commands: (commands)->
    console.error "Please specify a command (in #{@commands |> join ", "})!!!"
    process.exit!
