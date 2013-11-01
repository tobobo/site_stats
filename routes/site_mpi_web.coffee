sys = require("sys")
mongoose = require("mongoose")
SiteStats = require("../utils/schema.coffee").SiteStats

exports.web  = (request, response) ->
  # set headers to json and allow access to all
  response.setHeader "Content-Type", "application/json"
  response.setHeader "Access-Control-Allow-Origin", "*"
  
  # connect to db
  mongoose.connect "mongodb://localhost/site_stats", (callback) ->
    SiteStats.findOne {codebase: 'site_mpi'}, (err, these_site_stats) ->
      response.write(JSON.stringify(these_site_stats))
      response.end()
      mongoose.disconnect()
