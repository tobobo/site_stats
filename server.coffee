express = require("express")
sys = require("sys")
app = express()

# workers
require('./workers/site_mpi.coffee').work()

# routes
app.get "/", (request, response) ->
  console.log('serving index...')
  response.write 'nothing to see here'
  response.end()

app.get "/site_mpi.json", require('./routes/site_mpi.coffee').web

app.listen 8888
