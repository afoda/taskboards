Template.about_modal.rendered = ->
  $('#about-page-modal').modal()


Template.about_modal.events

  'click .close-modal-button': ->
    share.hideIntroModal()

  'click .start-tour-button': ->
    # share.startTour()
    share.hideIntroModal()


share.showIntroModal = ->
  $('#about-page-modal').modal('show')
  Meteor.call('setSeenIntroModal')

share.hideIntroModal = ->
  $('#about-page-modal').modal('hide')

share.seenIntroModal = -> Meteor.user().profile?.seenIntroModal


Accounts.onLogin ->
  Tracker.afterFlush ->
    share.showIntroModal() if not share.seenIntroModal()
