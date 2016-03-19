require! \../services/layout-manager.ls

module.exports = ->
  layout-manager.create path: options.layout, size: options.size, tag: options.tag
  |> ( .destroy!)

