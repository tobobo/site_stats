express = require("express")
sys = require("sys")
app = express()
mpi_github_stats = require('./routes/site_mpi.coffee')

# workers
mpi_github_stats.worker()

# routes
app.get "/", (request, response) ->
  response.write 'nothing to see here'
  response.end()
  
app.get "/site_mpi.json", require('./routes/site_mpi.coffee').web

app.listen 8888
