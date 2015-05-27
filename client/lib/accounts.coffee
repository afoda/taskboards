lastUserId = null


Meteor.startup ->
  Tracker.autorun ->
    userId = Meteor.userId()
    if userId != lastUserId
      seenIntroModal = Session.get "SeenIntroModal"
      Session.clear()
      Session.setPersistent "SeenIntroModal", seenIntroModal
    lastUserId = userId
