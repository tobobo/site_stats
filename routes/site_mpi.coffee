sys = require("sys")
async = require("async")
mongoose = require("mongoose")
exec = require("child_process").exec
SiteStats = require("../utils/schema.coffee").SiteStats

exports.web  = (request, response) ->
  console.log('very first thing!!')
  # set headers to json and allow access to all
  response.setHeader "Content-Type", "application/json"
  response.setHeader "Access-Control-Allow-Origin", "*"
  
  # connect to db
  console.log('connecting to db...')
  mongoose.connect "mongodb://localhost/site_stats", (callback) ->
    console.log('connected to db. finding record...')
    async.parallel (

      # get build status
      build_status: (callback) ->
        codeship_status_image = 'https://www.codeship.io/projects/af505270-2251-0131-ff05-721bb8e4003d/status'
        exec "curl -I #{codeship_status_image}", (error, stdout, stderr) ->
          if stdout.indexOf('status_success') > 0
            callback null, 'success'
          else if stdout.indexOf('status_testing') > 0
            callback null, 'test'
          else
            callback null, 'fail'

      # get site stats from db
      site_stats: (callback) ->
        SiteStats.findOne {codebase: 'site_mpi'}, (err, these_site_stats) ->
          console.log('found record. serving.')
          mongoose.disconnect()
          callback(null, these_site_stats)

      # get last 3 github events from github
      github_events: (callback) ->
        cmd = "curl -u tobias@myproject.is:#{process.env.GITHUB_TOKEN} https://api.github.com/repos/scoutai/site_mpi/events"
        console.log 'github command', cmd
        exec cmd, (error, stdout, stderr) ->
          callback null, JSON.parse(stdout).slice(0, 3)

      # get in-progress sprint.ly stories
      sprintly_stories: (callback) ->
        cmd = "curl -u tobias@Myproject.is:#{process.env.SPRINTLY_TOKEN} 'https://sprint.ly/api/products/15543/items.json?status=in-progress'"
        console.log 'sprintly command', cmd
        exec cmd, (error, stdout, stderr) ->
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

