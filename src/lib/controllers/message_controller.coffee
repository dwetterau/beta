id_tools = require '../id_tools'
models = require '../models'

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
          req.flash 'info', {msg: 'This message has been deleted from the server.'}
          res.render 'message', {
            subject: message.MessageInfo.subject
            body: message.body
            user: req.user
            title: 'Message'
          }
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
  res.render 'create_message', {
    title: 'Create Message',
    user: req.user
  }

exports.get_message_sent = (req, res) ->
  # TODO: do this ajax or something
  res.render 'message_sent', {
    message_link: '/message/' + req.params.id + '/preview'
    user: req.user
    title: "Message Sent"
  }
