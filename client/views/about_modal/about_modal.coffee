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
  Session.setPersistent "SeenIntroModal", true

share.hideIntroModal = ->
  $('#about-page-modal').modal('hide')

share.seenIntroModal = ->
  Meteor.user().profile?.seenIntroModal || Session.get "SeenIntroModal"

share.accountIsGuest = ->
  Meteor.user().profile?.guest


Accounts.onLogin ->
  Tracker.afterFlush ->
    if share.accountIsGuest() and not share.seenIntroModal()
      share.showIntroModal()
