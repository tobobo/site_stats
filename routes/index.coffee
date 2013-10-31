async = require("async")
sys = require("sys")
exec = require("child_process").exec

exports.index = (request, response) ->
  # specify the root of the site_mpi repo - probably shouldn't be a repo you actually use
  #site_mpi_root = '/home/tobobo/site_mpi/'
  site_mpi_root = './site_mpi/'

  # set headers to json and allow access to all
  response.setHeader "Content-Type", "application/json"
  response.setHeader "Access-Control-Allow-Origin", "*"
  
  # extensions to look for in the app directory
  app_langs = ["rb", "coffee", "hbs"]
  test_langs = ["rb", "coffee"]

  # create functions with callbacks that find number of files of a given language
  lang_functions = {app: {}, test: {}}

  create_lang_function = (folder, language) ->
    (callback) ->
      find_command = "find #{site_mpi_root}#{folder} -type f -name '*.#{language}' -exec awk 'END {print NR}' '{}' + 2>/dev/null | awk '{ total+=$1 }END{print total}'"
      exec find_command, (error, stdout, stderr) ->
        callback null, parseInt(stdout.trim())

  for language in app_langs
    lang_functions.app[language] = create_lang_function 'app', language

  for language in test_langs
    lang_functions.test[language] = create_lang_function 'test', language

  # fetch and pull before doing anything
  git_pull_command = "sh -c 'cd #{site_mpi_root} && git fetch --all && git remote prune `git remote` && git pull '"
  exec git_pull_command, (error, stdout, stderr) ->

    # run the rest of the commands simultaneously
    async.parallel (

      # get unmerged branches
      unmerged_branches: (callback) ->
        exec "sh -c 'cd #{site_mpi_root} && git branch -r --no-merged origin/master'", (error, stdout, stderr) ->
          sys.puts stdout
          branches = stdout.split('\n').map((s) -> s.trim()).filter((s) -> s != "").map (branch_ref) ->
            branch_ref_parts = branch_ref.split('/')

            remote: branch_ref_parts[0]
            branch: branch_ref_parts[1]
              
          callback null, branches

      # get number of log lines 
      js_log_lines: (callback) ->
        exec "grep -r console.log #{site_mpi_root}app/assets/javascripts | wc -l", (error, stdout, stderr) ->
          callback null, parseInt(stdout.trim())

      # get lines of code for different languages. how exciting nesting can be!
      total_lines_of_code: (callback) ->
        async.parallel (

          app: (callback) ->
            async.parallel lang_functions.app, (err, results) ->
              callback null, results

          test: (callback) ->
            async.parallel lang_functions.test, (err, results) ->
              callback null, results

        ), (err, results) ->
          callback(null, results)

    ), (err, results) ->
      response.write JSON.stringify(results)
      response.end()
