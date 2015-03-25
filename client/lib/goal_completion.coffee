share.toggleGoalComplete = (_id) ->
  goal = Goals.findOne _id
  if !goal.complete
    share.deactivateGoal _id
  Goals.update _id, $set: complete: !goal.complete
