require! <[fs]>

fs.readdir-sync __dirname
|> filter ( .match /\.ls$/)
|> reject ( is \index.ls)
|> map ( .match /(.*)\.ls/ .1)
|> map -> [(it |> camelize), require "./#{it}.ls"]
|> pairs-to-obj
|> (module.exports = )

