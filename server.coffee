express = require("express")
sys = require("sys")
app = express()
routes = 
  site_mpi: require('./routes/site_mpi.coffee').web

# workers
require('./workers/site_mpi.coffee').work()

# routes
app.get "/", (request, response) ->
  console.log('serving index...')
  response.write 'nothing to see here'
  response.end()

console.log routes.site_mpi
app.get "/site_mpi.json", routes.site_mpi

app.listen 8888
