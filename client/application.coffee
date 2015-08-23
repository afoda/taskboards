Meteor.subscribe "Goals"

Meteor.startup ->
  share.clearActiveGoal()
