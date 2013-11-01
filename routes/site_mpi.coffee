sys = require("sys")
async = require("async")
mongoose = require("mongoose")
exec = require("child_process").exec
SiteStats = require("../utils/schema.coffee").SiteStats

exports.web  = (request, response) ->
  # set headers to json and allow access to all
  response.setHeader "Content-Type", "application/json"
  response.setHeader "Access-Control-Allow-Origin", "*"
  
  # connect to db
  sys.puts('connecting to db...')
  mongoose.connect "mongodb://localhost/site_stats", (callback) ->
    sys.puts('connected to db. finding record...')
    async.parallel (

      # get site stats from db
      site_stats: (callback) ->
        SiteStats.findOne {codebase: 'site_mpi'}, (err, these_site_stats) ->
          sys.puts('found record. serving.')
          mongoose.disconnect()
          callback(null, these_site_stats)

      # get last 3 github events from github
      github_events: (callback) ->
        exec "curl -u tobias@myproject.is:#{process.env.GITHUB_TOKEN} https://api.github.com/repos/scoutai/site_mpi/events", (error, stdout, stderr) ->
          callback null, JSON.parse(stdout).slice(0, 3)

      # get in-progress sprint.ly stories
      sprintly_stories: (callback) ->
        exec "curl -u tobias@Myproject.is:#{process.env.SPRINTLY_TOKEN} 'https://sprint.ly/api/products/15543/items.json?status=in-progress'", (error, stdout, stderr) ->
          data = JSON.parse(stdout)
          data = data.map (s) ->
            status: s.status
            assigned_to: 
              name: s.assigned_to.first_name
              email: s.assigned_to.email
            type: s.type
          callback null, data

    # pack it up and send it back
    ), (err, results) ->
      response.write(JSON.stringify(results))
      response.end()

