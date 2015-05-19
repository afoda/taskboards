# Session variables.
# ActiveGoal (str): the id of the currently active goal
# ActiveGoalStartTime (date): the time at which the currently active goal was activated
# SecondsSinceActiveGoalStart (number): number of seconds between now and ActiveGoalStartTime (updated every second)

UI.registerHelper 'isActive', (_id) -> _id == share.activeGoalId()

Meteor.setInterval ->
    timeStart = Session.get "ActiveGoalStartTime"
    timeNow = new Date()
    seconds = (timeNow - timeStart) / 1000.0
    Session.setPersistent 'SecondsSinceActiveGoalStart', seconds
  , 1000

share.activeGoalId = ->
  Session.get 'ActiveGoal'

share.deactivateGoal = (_id) ->
  if Session.equals 'ActiveGoal', _id
    Session.clear 'ActiveGoal'
    Session.clear 'ActiveGoalStartTime'
    Session.clear 'SecondsSinceActiveGoalStart'

share.activateGoal = (_id) ->
  Session.setPersistent 'ActiveGoal', _id
  Session.setPersistent 'ActiveGoalStartTime', new Date()
  Session.setPersistent 'SecondsSinceActiveGoalStart', 0.0
  share.signalGoalActivated()

share.toggleActiveGoal = (_id) ->
  if Session.equals 'ActiveGoal', _id
    share.deactivateGoal _id
  else
    share.activateGoal _id

share.secondsSinceActiveGoalStart = ->
  Session.get 'SecondsSinceActiveGoalStart'
