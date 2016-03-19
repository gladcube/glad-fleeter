require! <[yaml-js fs]>
require! \../classes/Layout.ls
{load} = yaml-js
root_dir = "#__dirname/../.."
layouts_dir = "#root_dir/layouts/"
read-yml = fs.read-file-sync >> load

module.exports = new class LayoutManager
  create: ({path, size, tag})->
#    fs.readdir-sync layouts_dir
#    |> map ( .replace /\.yml/, "")
#    |> find ( is name)
#    |> -> if not it? then console.error "Give me a collect name of the layout!!"; process.exit!; else it
    read-yml "#{process.cwd!}/#{path}"
    |> ->
      new Layout do
        name: it.name
        size: size
        tag: tag
        endpoint: it.endpoint
        containers: it.containers
        cluster_name: it.cluster_name
