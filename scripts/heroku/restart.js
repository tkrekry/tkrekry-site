var heroku = require("heroku");
var client = new heroku.Heroku({key: process.env.HEROKU_TOKEN});

client.post_ps_restart(process.env.HEROKU_APP, {'ps': 'web.1'}, function(err, result) {
  console.log("RESTART - Error:", err, "Result:",result);
});