express = require("express")
sys = require("sys")
app = express()

# workers
require('./routes/site_mpi_worker.coffee').work()

# routes
app.get "/", (request, response) ->
  response.write 'nothing to see here'
  response.end()

app.get "/site_mpi.json", require('./routes/site_mpi_web.coffee').web

app.listen 8888
