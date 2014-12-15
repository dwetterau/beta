{constants} = require '../lib/common'
api_controller = require './api_controller'

# Long polling state
listeners = {}
messages = []
notify_function = () ->
  closed = {}
  new_messages = []
  for message in messages
    if message.user_id of listeners
      # Respond to the listener
      for res in listeners[message.user_id]
        try
          res.send message.data
        catch
          # Dead listener, just ignore it
      closed[message.user_id] = true
      delete listeners[message.user_id]
    else if message.user_id of closed
      new_messages.push message
  messages = new_messages

listen_loop = undefined
listen_loop_function = () ->
  notify_function()
  listen_loop = setTimeout () ->
    listen_loop_function()
  , constants.NOTIFICATION_LOOP_TIMEOUT

exports.get_notifications = (req, res) ->
  # Put the response object in our listeners map
  if req.user.id of listeners
    listeners[req.user.id].push res
  else
    listeners[req.user.id] = [res]

send_notification = (user_id, data) ->
  messages.push {user_id, data}

  # Kill the old timeout and immediately start it again if the user is listening
  if user_id of listeners
    clearTimeout listen_loop
    listen_loop_function()

exports.new_message = (user_id, message_id) ->
  link = '/message/' + message_id + '/preview'
  msg = 'You have a new message. <a href="' + link + '"">Click here to view</a>!'
  api_controller.render_flash 'info', msg, (err, html) ->
    data = {
      status: 'ok'
      message: html
    }
    send_notification user_id, data

exports.start_listen_loop = () ->
  listen_loop_function()
