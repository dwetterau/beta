id_tools = require '../lib/id_tools'
models = require '../models'
notifications = require './notification_controller'

exports.get_preview_message = (req, res) ->
  req.assert('id', 'Invalid message id.').len(3)
  errors = req.validationErrors()
  if errors
    req.flash 'errors', errors
    return res.redirect '/'

  fail = (err) ->
    if err?
      console.log err
    req.flash 'errors', {msg: 'You are not authorized to view this message.'}
    return res.redirect '/'

  id_string = req.params.id
  models.MessageInfo.find({
    where: {MessageId: id_tools.convertStringToId(id_string)}
  }).success (message_info) ->
    if not message_info or message_info.state == 'DELETED' or (req.user and
        message_info.ReceiverId and req.user.id != message_info.ReceiverId)
      return fail()
    res.render 'message_preview', {
      link: '/message/' + id_string + "/view"
      subject: message_info.subject
      user: req.user
      title: 'Read Message'
    }
  .failure fail

exports.get_read_message = (req, res) ->
  req.assert('id', 'Invalid message id.').len(3)
  errors = req.validationErrors()
  if errors
    req.flash 'errors', errors
    return res.redirect '/'

  fail = (err) ->
    if err?
      console.log err
    req.flash 'errors', {msg: 'You are not authorized to view this message.'}
    return res.redirect '/'

  id = id_tools.convertStringToId req.params.id
  models.Message.find({
    where: {id}
    include: [models.MessageInfo]
  }).success (message) ->
    if not message or (message.MessageInfo.ReceiverId and
        req.user.id != message.MessageInfo.ReceiverId)
      return fail()
    # TODO: Make this a transaction or happen on cascade.
    message.destroy().success () ->
      message.MessageInfo.setMessage(null).success () ->
        message.MessageInfo.updateAttributes({state: 'DELETED'}).success () ->
          # TODO: Return the sender for easy reply.

          render_message = (creator_username) ->
            req.flash 'info', {msg: 'This message has been deleted from the server.'}

            if creator_username?
              has_creator = true
              reply_link = '/message/reply?r=' + creator_username

            res.render 'message', {
              subject: message.MessageInfo.subject
              body: message.body
              user: req.user
              title: 'Message'
              has_creator
              reply_link
            }

          if message.MessageInfo.CreatorId
            models.User.find(message.MessageInfo.CreatorId).success (user) ->
              render_message(user.username)
            .failure fail
          else
            render_message()

        .failure fail
      .failure fail
    .failure fail
  .failure fail

exports.post_create_message = (req, res) ->
  req.assert('subject', 'You must provide a public subject for the message.').notEmpty()
  req.assert('body', 'You must provide a private body for the message').notEmpty()
  errors = req.validationErrors()
  if errors
    req.flash 'errors', errors
    return res.redirect '/message/create'

  fail = (msg) ->
    if msg?
      req.flash 'errors', {msg}
    else
      req.flash 'errors', {msg: 'Failed to create message.'}
    return res.redirect '/message/create'

  if req.user
    this_user_id = req.user.id
    other_user_id = req.body.receiver_id

  finish_building_message = (other_user_id) ->
    message_info = models.MessageInfo.build {
      subject: req.body.subject
      state: 'UNREAD'
      CreatorId: this_user_id
      ReceiverId: other_user_id
    }
    message_info.save().success () ->
      message = models.Message.build {
        body: req.body.body
        UserId: this_user_id
        MessageInfoId: message_info.id
      }
      message.save().success () ->
        message_info.MessageId = message.id
        message_info.save().success () ->
          # Send a notification to the recipient
          notifications.new_message other_user_id, id_tools.convertIdToString(message.id)

          req.flash 'success', {msg: 'Message sent!'}
          res.redirect '/message/' + id_tools.convertIdToString(message.id) + '/sent'
        .failure fail
      .failure fail
    .failure fail

  if other_user_id? and other_user_id.length > 0
    models.User.find({where: {username: other_user_id}}).success (user) ->
      finish_building_message(user.id)
    .failure () ->
      fail('Could not find recipient with that username.')
  else
    finish_building_message()

exports.get_create_message = (req, res) ->
  if req.query.r?
    reply = req.query.r

  res.render 'create_message', {
    title: 'Create Message'
    user: req.user
    reply
  }

exports.get_message_sent = (req, res) ->
  # TODO: do this ajax or something
  link = req.protocol + '://' + req.get('host')
  link += '/message/' + req.params.id + '/preview'

  res.render 'message_sent', {
    message_link: link
    user: req.user
    title: "Message Sent"
  }

exports.post_archive_message = (req, res) ->
  ids = req.body.ids
  user_id = req.user.id
  if not ids?
    ids = []
  message_info_ids = (id_tools.convertStringToId(id) for id in ids)
  models.MessageInfo.update(
    {creatorArchived: true}, {where: {id: message_info_ids, CreatorId: user_id}}
  ).success () ->
    return models.MessageInfo.update(
      {receiverArchived: true}, {where: {id: message_info_ids, ReceiverId: user_id}}
    ).success () ->
      if message_info_ids.length == 1
        msg = "Message archived."
      else
        msg = ids.length + " messages archived."
      req.flash "success", {msg}
      res.redirect '/'
  .failure (err) ->
    console.log err
    req.flash "errors", {msg: "Failed to archive messages."}
    res.redirect '/'
