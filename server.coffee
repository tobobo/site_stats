express = require("express")
sys = require("sys")

# routes
index = require('./routes/index.coffee').index

app = express()

app.get "/*", index

app.listen 8888
