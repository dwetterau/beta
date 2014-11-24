models = require '../models'

exports.get_all_contacts = (req, res) ->
  fail = (err) ->
    if err?
      console.log err
    res.send({status: 'failure', msg: 'Could not retrieve contacts.'})

  req.user.getReceived().success (received_messages) ->
    req.user.getCreated().success (sent_messages) ->
      id_map = {}
      for message_info in received_messages
        id_map[message_info.CreatorId] = true
        id_map[message_info.ReceiverId] = true
      for message_info in received_messages
        id_map[message_info.CreatorId] = true
        id_map[message_info.ReceiverId] = true
      ids_to_request = (k for k, v of id_map)
      models.User.findAll({where: {id: ids_to_request}}).success (users) ->
        user_list = []
        for user in users
          user_list.push {
            username: user.username
          }
        res.send {
          status: 'ok'
          user_list
        }
      .failure fail
    .failure fail
  .failure fail

