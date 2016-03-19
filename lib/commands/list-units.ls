require! <[node-fleet-api cli-table]>
require! \../services/layout-manager.ls

module.exports = ->
  layout = layout-manager.create path: options.layout
  heads = <[Name Layout Tag Index ActiveState SubState MachineIP]>
  table = new cli-table (
    head: heads
    chars: <[top top-mid top-left top-right bottom bottom-mid bottom-left bottom-right left left-mid mid mid-mid right right-mid middle]> |> map (-> [it, ""]) |> pairs-to-obj
    style: padding-left: 0, padding-right: 0
  )
  machines <~ layout.get_machines
  states <~ layout.get_states
  units <~ layout.get_units
  units
  |> each (unit)-> unit <<< machine: (machines |> find ( .id is unit.machine-ID)), state: (states |> find ( .name is unit.name))
  |> map (unit)-> unit.name.match /^(.+)__(.+)--(.+)@(\d+).+$/ |> drop 1 |> ~> it.concat [unit.state?.systemd-active-state, unit.state?.systemd-sub-state, unit.machine?.primary-IP or ""]
  |> (if options.orderby? and (heads |> elem-index (options.orderby |> camelize |> capitalize))? then sort-by ( .(that)) else id)
  |> each -> table.push it
  console.log table.to-string!


