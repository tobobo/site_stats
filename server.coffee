express = require("express")
sys = require("sys")

app = express()

# routes
app.get "/*", require('./routes/index.coffee').index

app.listen 8888
