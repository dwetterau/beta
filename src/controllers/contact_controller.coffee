models = require '../models'

retrieve_contacts = (user, fail, success_callback) ->
  added_contacts = []
  received_messages = []
  sent_messages = []
  user.getContacts().then (contacts) ->
    added_contacts = contacts
    return user.getReceived()
  .then (messages) ->
    received_messages = messages
    return user.getCreated()
  .then (sent_messages) ->
    id_map = {}
    for contact in added_contacts
      id_map[contact.user_id] = true
    for message_info in received_messages
      id_map[message_info.CreatorId] = true
    for message_info in sent_messages
      id_map[message_info.ReceiverId] = true
    ids_to_request = (k for k, v of id_map)
    return models.User.findAll({where: {id: ids_to_request}})
  .then (users) ->
    user_list = []
    for user in users
      user_list.push {
        username: user.username
        reply_link: '/message/reply?r=' + user.username
      }
    success_callback user_list
  .catch fail

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

exports.post_create_contact = (req, res) ->
  fail = (err) ->
    console.log "Failed to create contact", err
    req.flash 'errors', {msg: 'Could not add contact'}
    res.redirect '/contacts'
  target_username = req.param 'username'
  target_user = null
  models.User.find({where: {username: target_username}}).then (user) ->
    if not user?
      throw new Error("Could not find user to add")

    target_user = user
    return req.user.getContacts()
  .then (existing_contacts) ->
    # Don't add a contact we have already
    this_id = target_user.id
    for contact in existing_contacts
      if contact.user_id == this_id
        throw new Error("Already have user as contact")

    return models.Contact.build({
      user_id: target_user.id
      UserId: req.user.id
    }).save()
  .then () ->
    req.flash 'success', {msg: 'Added contact successfully!'}
    return res.redirect '/contacts'
  .catch fail
