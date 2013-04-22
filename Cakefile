{exec} = require 'child_process'

task 'build', 'rebuild the Frenzy DDP client', ->
  exec 'coffee --compile --output lib/ src/', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

