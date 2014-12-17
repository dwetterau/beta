models = require '../models'

retrieve_contacts = (user, fail, success_callback) ->
  user.getReceived().success (received_messages) ->
    user.getCreated().success (sent_messages) ->
      id_map = {}
      for message_info in received_messages
        id_map[message_info.CreatorId] = true
      for message_info in sent_messages
        id_map[message_info.ReceiverId] = true
      ids_to_request = (k for k, v of id_map)
      models.User.findAll({where: {id: ids_to_request}}).success (users) ->
        user_list = []
        for user in users
          user_list.push {
            username: user.username
            reply_link: '/message/reply?r=' + user.username
          }
        success_callback(user_list)
      .failure fail
    .failure fail
  .failure fail

exports.get_contacts = (req, res) ->
  fail = (err) ->
    if err?
      console.log err
    req.flash 'errors', {msg: 'Could not retrieve contacts'}
    res.render 'contacts', {
      contacts: []
      title: 'Contacts'
      user: req.user
    }
  success = (user_list) ->
    res.render 'contacts', {
      contacts: user_list
      title: 'Contacts'
      user: req.user
    }
  retrieve_contacts req.user, fail, success

exports.get_all_contacts = (req, res) ->
  fail = (err) ->
    if err?
      console.log err
    res.send({status: 'failure', msg: 'Could not retrieve contacts.'})

  success = (user_list) ->
    res.send {
      status: 'ok'
      user_list
    }
  retrieve_contacts req.user, fail, success

exports.get_all_users = (req, res) ->
  fail = (err) ->
    res.send {status: 'failure', msg: 'Could not retrieve users.'}
  models.User.findAll().success (users) ->
    user_list = []
    for user in users
      user_list.push {username: user.username}
    res.send {status: 'ok', user_list}
  .failure fail
