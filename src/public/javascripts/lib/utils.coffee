exports.flash = (level, msg) ->
  $.get '/api/flash', {level, msg}, (data) ->
    $('.alert-container').append($(data.flash))
    $(".alert").delay(3000).fadeOut(2000)
