Template.about_modal.rendered = ->
  $('#about-page-modal').modal()


Template.about_modal.events

  'click .close-modal-button': ->
    $('#about-page-modal').modal('hide')

  'click .start-tour-button': ->
    $('#about-page-modal').modal('hide')
    # share.startTour()
