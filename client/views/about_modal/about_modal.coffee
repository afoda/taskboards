Template.about_modal.rendered = ->
  $('#about-modal').modal()


Template.about_modal.events

  'click .close-modal-button': ->
    share.hideIntroModal()

  'click .start-tour-button': ->
    share.startTour()
    share.hideIntroModal()


share.showIntroModal = ->
  $('#about-modal').modal('show')
  Meteor.call('setSeenIntroModal')
  Session.setPersistent "SeenIntroModal", true

share.hideIntroModal = ->
  $('#about-modal').modal('hide')

share.seenIntroModal = ->
  Meteor.user().profile?.seenIntroModal || Session.get "SeenIntroModal"

share.accountIsGuest = ->
  Meteor.user().profile?.guest


Accounts.onLogin ->
  Tracker.afterFlush ->
    if share.accountIsGuest() and not share.seenIntroModal()
      share.showIntroModal()
