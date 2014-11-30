constants = require '../lib/common/constants'
id_tools = require '../lib/id_tools'
models = require '../models'

exports.get_index = (req, res) ->
  if req.user
    # Get all of the user's received messages
    process_messages = (infos, sender_link, user_map) ->
      message_infos = []
      for message_info in infos
        deleted = if message_info.state == 'DELETED' then true else false
        id = id_tools.convertIdToString(message_info.MessageId)
        info_id = id_tools.convertIdToString(message_info.id)
        if sender_link and !deleted
          link = '/message/' + id + '/sent'
        else if !deleted
          link = '/message/' + id + '/preview'
        else
          link = '#'
        if sender_link
          if message_info.ReceiverId
            user = user_map[message_info.ReceiverId]
          else
            user = "anonymous"
        else
          if message_info.CreatorId
            user = user_map[message_info.CreatorId]
          else
            user = "anonymous"
        message_infos.push {
          subject: message_info.subject
          link
          deleted
          user
          id: info_id
        }
      return message_infos.reverse()

    fail = () ->
      req.flash 'errors', {msg: 'Unable to retrieve your messages.'}
      res.redirect '/'

    received_messages = []
    sent_messages = []
    req.user.getReceived().success (received_message_infos) ->
      req.user.getCreated().success (created_message_infos) ->
        id_map = {}
        id_map[req.user.id] = true
        for message_info in received_message_infos
          id_map[message_info.CreatorId] = true
        for message_info in created_message_infos
          id_map[message_info.ReceiverId] = true
        ids_to_request = (k for k, v of id_map when k != 'null')
        models.User.findAll({where: {id: ids_to_request}}).success (users) ->
          for user in users
            id_map[user.id] = user.username

          received_messages = process_messages(received_message_infos, false, id_map)
          sent_messages = process_messages(created_message_infos, true, id_map)
          res.render 'index', {
            user: req.user
            title: 'Home'
            received_messages
            sent_messages
          }
        .failure fail
      .failure fail
    .failure fail


  else
    res.render 'index', {
      user: req.user
      title: 'Home'
    }
