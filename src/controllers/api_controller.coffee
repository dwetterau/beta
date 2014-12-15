jade = require 'jade'
path = require 'path'

exports.get_flash = (req, res) ->
  level = req.param('level')
  msg = req.param('msg')

  exports.render_flash level, msg, (err, html) ->
    if err
      console.log err
      res.send {
        status: 'error'
      }
    else
      res.send {
        status: 'ok',
        flash: html
      }

exports.render_flash = (level, msg, callback) ->
  messages = {}
  messages[level] = [{msg}]
  directory = path.join(__dirname, '../views/partials/flash.jade')
  jade.renderFile directory, {messages}, callback
