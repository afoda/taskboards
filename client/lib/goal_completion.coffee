share.toggleGoalComplete = (_id) ->
  goal = Goals.findOne _id
  if !goal.complete
    share.deactivateGoal _id
  Meteor.call "toggleGoalComplete", _id
