utils = require ('./lib/utils.coffee')

$.material.init()

if $("input#receiver_id").length
  # Populate the contact list and enable the typeahead
  $.get '/contacts/all', (result) ->
    if result.status == 'ok'
      users = new Bloodhound({
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value')
        queryTokenizer: Bloodhound.tokenizers.whitespace
        local: $.map(result.user_list, (user) -> return {value: user.username})
      })
      users.initialize()
      $("input#receiver_id").typeahead {
        hint: true
        highlight: true
        minLength: 1
      }, {
        name: 'users',
        displayKey: 'value',
        source: users.ttAdapter()
      }
    else
      console.error('Unable to retrieve contacts')

$(".clickable").click () ->
  window.location = $(this).data('href')

$(".clickable input").click (e) ->
  e.stopPropagation()

$("button.message-action").click () ->
  url = $(this).data('url')
  ids = []
  # Get all of the selected messages
  for element in $(":checkbox:checked")
    ids.push $(element).data('id')

  if ids.length == 0
    utils.flash('info', 'No messages selected.')
    return

  # Construct a form, add all of the ids as array inputs, and send it
  form = $("<form>").attr({method: 'POST', action: url})
    .css {display: 'none'}
  for id in ids
    form.append $('<input>').attr
      type: 'hidden'
      name: 'ids[]'
      value: id
  form.appendTo('body').submit()

if $('#create_message').length
  # Create the Quill editor
  editor = new Quill '#editor', {
    modules:
      'toolbar': {container: '#toolbar'}
      'link-tooltip': true
    theme: 'snow'
  }

  $('#create_message').submit () ->
    $('#body').val editor.getHTML()
