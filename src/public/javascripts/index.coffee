# Client-side stuff here
$(".alert").delay(3000).fadeOut(2000)

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

$("button#delete").click () ->
  ids = []
  # Get all of the selected messages
  for element in $(":checkbox:checked")
    ids.push $(element).data('id')
  # Construct a form, add all of the ids as array inputs, and send it
  form = $("<form>").attr({method: 'POST', action: '/message/delete'})
    .css {display: 'none'}
  for id in ids
    form.append $('<input>').attr
      type: 'hidden'
      name: 'ids[]'
      value: id
  form.appendTo('body').submit()
