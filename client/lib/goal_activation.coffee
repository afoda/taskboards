share.activeGoalId = ->
  Session.get 'ActiveGoal'

share.deactivateGoal = (_id) ->
  if Session.equals 'ActiveGoal', _id
    Session.clear 'ActiveGoal'

share.toggleActiveGoal = (_id) ->
  if Session.equals 'ActiveGoal', _id
    Session.clear 'ActiveGoal'
  else
    Session.setPersistent 'ActiveGoal', _id
