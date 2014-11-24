constants = require '../common/constants'
id_tools = require '../id_tools'

exports.get_index = (req, res) ->
  if req.user
    # Get all of the user's received messages
    process_messages = (infos, sender_link) ->
      message_infos = []
      for message_info in infos
        deleted = if message_info.state == 'DELETED' then true else false
        console.log deleted
        if sender_link and !deleted
          link = '/message/' + id_tools.convertIdToString(message_info.MessageId) + '/sent'
        else if !deleted
          link = '/message/' + id_tools.convertIdToString(message_info.MessageId) + '/view'
        else
          link = '#'

        message_infos.push {
          subject: message_info.subject
          link
          deleted
        }
      return message_infos.reverse()

    fail = () ->
      req.flash 'errors', {msg: 'Unable to retrieve your messages.'}
      res.redirect '/'

    received_messages = []
    sent_messages = []
    req.user.getReceived().success (received_message_infos) ->
      req.user.getCreated().success (created_message_infos) ->
        received_messages = process_messages(received_message_infos, false)
        sent_messages = process_messages(created_message_infos, true)
        res.render 'index', {
          user: req.user
          title: 'Home'
          received_messages
          sent_messages
        }
      .failure fail
    .failure fail


  else
    res.render 'index', {
      user: req.user
      title: 'Home'
    }
