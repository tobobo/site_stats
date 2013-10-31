http = require("http")
express = require("express")
async = require("async")
sys = require("sys")
exec = require("child_process").exec
child = undefined
app = express()

site_mpi_root = '/home/tobobo/site_mpi/'

app.get "/*", (request, response) ->

  response.setHeader "Content-Type", "application/json"

  app_langs = ["rb", "coffee", "hbs"]
  test_langs = ["rb", "coffee"]

  lang_functions = {app: {}, test: {}}

  create_lang_function = (folder, language) ->
    (callback) ->
      cmd = "find #{site_mpi_root}#{folder} -type f -name '*.#{language}' -exec awk 'END {print NR}' '{}' + 2>/dev/null | awk '{ total+=$1 }END{print total}'"
      exec cmd, (error, stdout, stderr) ->
        callback null, parseInt(stdout.trim())

  for language in app_langs
    lang_functions.app[language] = create_lang_function 'app', language

  for language in test_langs
    lang_functions.test[language] = create_lang_function 'test', language

  async.parallel (
    app: (callback) ->
      async.parallel lang_functions.app, (err, results) ->
        callback null, results

    test: (callback) ->
      async.parallel lang_functions.test, (err, results) ->
        callback null, results

  ), (err, results) ->
    response.write JSON.stringify(lines_of_code: results)
    response.end()


app.listen 8888
