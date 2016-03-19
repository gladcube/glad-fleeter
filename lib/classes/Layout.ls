require! <[node-fleet-api async]>
require! \./Unit.ls
require! \../utilities/fleet.ls
{wait} = require \../utilities/others.ls

module.exports = class Layout
  ({@name, @tag, @size, @containers, @endpoint, @cluster_name})->
  api:~ -> @_api ?= (node-fleet-api @endpoint) <<< (fleet @endpoint)
  units:~ -> @_units ?=
    @containers |> obj-to-pairs |> map ([container_name, container_config])~>
      [0 til @size] |> map (index)~>
        new Unit name: container_name, config: container_config, layout: @, index: index
    |> flatten
  id:~ -> "#{@name}--#{@tag}"
#  deploy_and_clear: (cb)->
#    <~ @deploy
#    <~ @wait_for_layout
#    <~ @clear_old_units
#    cb?!
  deploy: (cb)->
    <~ @submit
    <~ @start
    cb?!
#  wait_for_layout: (cb)->
#    console.log "waiting for layout #{(duration = DURATION_TO_WAIT_FOR_LAYOUT) / 1000 |> round}s ..."
#    wait duration, cb
  destroy: (cb)->
    units <~ @get_units_with_same_tag
    <~ async.parallel (
      units |> map (unit)~>
        fn = (cb)~>
          err <- @api.destroy-unit unit.name
          if err? then console.error err; fn cb; return
          console.log "removed #{unit.name}"; cb?!
    )
    cb?!
  submit: (cb)->
    <~ async.parallel (
      @units |> map (unit)~>
        fn = (cb)~>
          _, err <- @api.new-unit unit.service_name, (desired-state: \inactive, options: unit.options)
          if err? and err.length > 0 then console.error err; set-timeout (-> fn cb), 100; return
          console.log "submitted #{unit.id}"; cb?!
    )
    cb?!
  start: (cb)->
    <~ async.parallel (
      @units |> map (unit)~>
        fn = (cb)~>
          _, err <- @api.start-unit unit.service_name
          if err? and err.length > 0 then console.error err; set-timeout (-> fn cb), 100; return
          console.log "started #{unit.id}"; cb?!
    )
    cb?!
  get_units: (fn, cb)->
    if not cb? then cb = fn; fn = -> yes
    err, {units = []} <~ @api.get-all-units
    units
    |> map -> it.name.match /^.+__(.+)--(.+)@(\d+).+$/ |> ~> name: it.0, layout_name: it.1, tag: it.2, index: it.3
    |> filter (~> it.layout_name is @name)
    |> filter fn
    |> cb?
  get_units_with_same_tag: (cb)-> @get_units (~> it.tag is @tag), cb
  get_units_without_same_tag: (cb)-> @get_units (~> it.tag isnt @tag), cb
  get_machines:~ -> @api.get_machines
  get_states:~ -> @api.get_states
#  clear_old_units: (cb)->
#    old_units <~ @get_units_without_same_tag
#    <~ async.series (
#      (indices = old_units |> map ( .index) |> unique)
#      |> map (index)~>
#        (cb)~>
#          <~ async.parallel (
#            old_units
#            |> filter ( .index is index)
#            |> map (unit)->
#              fn = (cb)->
#                err <- destroy-unit unit.name
#                if err? then console.error err; fn cb; return
#                console.log "destroyed #{unit.name}"; cb!
#          )
#          if index is (indices |> last) then cb!; return
#          console.log "waiting #{INTERVAL_TO_CLEAR / 1000 |> round}s ..."
#          wait constants.INTERVAL_TO_CLEAR, cb
#    )
#    cb?!

