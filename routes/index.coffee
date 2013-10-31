async = require("async")
exec = require("child_process").exec

exports.index = (request, response) ->
  site_mpi_root = '/home/tobobo/site_mpi/'
  #site_mpi_root = '../site_mpi/'

  response.setHeader "Content-Type", "application/json"

  app_langs = ["rb", "coffee", "hbs"]
  test_langs = ["rb", "coffee"]

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

  git_pull_command = "sh -c 'cd #{site_mpi_root} && git pull'"
  exec git_pull_command, (error, stdout, stderr) ->

    async.parallel (

      log_lines: (callback) ->
        exec "grep -Fir console.log #{site_mpi_root}app/assets/javascripts | wc -l", (error, stdout, stderr) ->
          callback null, stdout.trim()

      app: (callback) ->
        async.parallel lang_functions.app, (err, results) ->
          callback null, results

      test: (callback) ->
        async.parallel lang_functions.test, (err, results) ->
          callback null, results

    ), (err, results) ->
      response.write JSON.stringify(lines_of_code: results)
      response.end()
