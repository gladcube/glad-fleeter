require! \../services/login-manager.ls

module.exports = class DockerContainerServiceUnit
  ({@name, @config, @layout, @index})->
  name_with_layout:~ -> "#{@name}__#{@layout.id}"
  id:~ -> "#{@name_with_layout}@#{@index}"
  service_name:~ -> "#{@id}.service"
  representative:~ -> @layout.units |> filter (~> it.index is @index) |> head
  links:~ -> @config.[]links |> map ((name)~> @layout.units |> find ( .name is name))
  volumes_from:~ -> @config.[]volumes_from |> map ((name)~> @layout.units |> find ( .name is name))
  dependencies:~ -> @links ++ @volumes_from |> unique
  options:~ ->
    [
    @option_description
    , @option_timeout_start_sec
    , @option_exec_start_pres
    , @option_exec_start
    , @option_exec_stop
    , @option_restart
    , @option_restart_sec
    , @option_conflicts
    , @option_machine_metadata
    ]
    |> ~> if @ isnt @representative then it ++ @option_machine_of else it
    |> flatten
  option_description:~ -> section: \Unit, name: \Description, value: "#{@id}"
  option_timeout_start_sec:~ -> section: \Service, name: \TimeoutStartSec, value: "0"
  option_exec_start_pres:~ -> [@option_docker_login, @option_docker_pull, @option_docker_remove]
  option_docker_login:~ -> section: \Service, name: \ExecStartPre, value: "/usr/bin/docker login -u #{login-manager.auth.user} -e #{login-manager.auth.email} -p #{login-manager.auth.password}"
  option_docker_pull:~ -> section: \Service, name: \ExecStartPre, value: "/usr/bin/docker pull #{@config.image}"
  option_docker_remove:~ -> section: \Service, name: \ExecStartPre, value: "-/usr/bin/docker rm -f #{@name_with_layout}"
  option_exec_start:~ ->
    section: \Service, name: \ExecStart, value: """
      /usr/bin/docker run \\
        --name #{@name_with_layout} \\
        #{@links |> map (-> "--link #{it.name_with_layout}:#{it.name}") |> join " "} \\
        #{@config.[]ports |> map (-> "-p \"#it\"") |> join " "} \\
        #{@config.[]volumes |> map (-> "-v #it") |> join " "} \\
        #{@volumes_from |> map (-> "--volumes-from #{it.name_with_layout}") |> join " "} \\
        #{@config.{}environment |> obj-to-pairs |> map (([key, val])-> "-e \"#key=#val\"") |> join " "} \\
        --log-driver json-file --log-opt max-size=100m --log-opt max-file=20 \\
        #{@config.image} #{@config.command or ""}
    """
  option_exec_stop:~ -> section: \Service, name: \ExecStop, value: "/usr/bin/docker rm -f #{@name_with_layout}"
  option_restart:~ -> section: \Service, name: \Restart, value: "on-failure"
  option_restart_sec:~ -> section: \Service, name: \RestartSec, value: "2s"
  option_conflicts:~ -> section: \X-Fleet, name: \Conflicts, value: "#{@name_with_layout}@*.service"
  option_machine_of:~ -> section: \X-Fleet, name: \MachineOf, value: "#{@representative.id}.service"
  option_machine_metadata:~ -> section: \X-Fleet, name: \MachineMetadata, value: "cluster=#{@layout.cluster_name}"
