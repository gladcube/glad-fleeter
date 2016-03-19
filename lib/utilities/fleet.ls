require! <[http]>

module.exports = (endpoint)->
  get_machines: (cb)->
    res <- http.get "#endpoint/fleet/v1/machines"
    data = new Buffer ""
    res.on \data, (data += )
    res.on \end, -> data |> JSON.parse |> ( .machines) |> cb
  get_states: (cb)->
    res <- http.get "#endpoint/fleet/v1/state"
    data = new Buffer ""
    res.on \data, (data += )
    res.on \end, -> data |> JSON.parse |> ( .states) |> cb
