add_rendered_notification = (notification) ->
  for child in $(notification).children()
    $('.alert-container').append(child)

exports.flash = (level, msg) ->
  $.get '/api/flash', {level, msg}, (data) ->
    add_rendered_notification(data.flash)

notifications = 0
exports.add_notification = (message) ->
  $('.alert-container').append(message)
  notifications += 1
  set_title_to_notifications()

set_title_to_notifications = () ->
  title = document.title
  index = title.indexOf(')')
  if index != -1
    title = title.substring(index + 2)
  if notifications == 0
    document.title = title
  else
    document.title = '(' + notifications + ') ' + title

# When the tab gets focus, clear the notifications
$(window).focus () ->
  notifications = 0
  set_title_to_notifications()

# When a notification is removed, clear the notifications
$('.alert-container').on 'DOMNodeRemoved', () ->
  notifications = 0
  set_title_to_notifications()