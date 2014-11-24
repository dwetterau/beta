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
