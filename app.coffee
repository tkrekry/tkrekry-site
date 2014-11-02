if process.env.NODETIME_ACCOUNT_KEY
  require('nodetime').profile(accountKey: process.env.NODETIME_ACCOUNT_KEY, appName: "TKrekry Site (#{process.env.NODE_ENV})")


require('newrelic') if process.env.NODE_ENV == 'production'

express = require('express')
http = require('http')

app = express()
server = http.createServer(app).listen(process.env.PORT || 8080)

app.use(express.static(__dirname + '/out'))
app.use(app.router)

docpadInstanceConfiguration =

  # Give it our express application and http server
  serverExpress: app
  serverHttp: server

  # Tell it not to load the standard middlewares (as we handled that above)
  middlewareStandard: false

require("docpad").createInstance docpadInstanceConfiguration, (err, docpadInstance) ->
  return console.log(err.stack)  if err

  # Tell DocPad to perform a generation, extend our server with its routes, and watch for changes
  docpadInstance.action "server", (err) ->
    console.log("generate error", err) if err
    docpadInstance.action "generate"