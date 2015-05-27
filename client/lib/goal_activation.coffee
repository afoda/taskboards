# Session variables.
# ActiveGoal (str): the id of the currently active goal
# ActiveGoalStartTime (date): the time at which the currently active goal was activated
# SecondsSinceActiveGoalStart (number): number of seconds between now and ActiveGoalStartTime (updated every second)

UI.registerHelper 'isActive', (_id) -> _id == share.activeGoalId()

Meteor.setInterval ->
    timeStart = Session.get "ActiveGoalStartTime"
    timeNow = new Date()
    seconds = (timeNow - timeStart) / 1000.0
    Session.setAuth 'SecondsSinceActiveGoalStart', seconds
  , 1000

share.activeGoalId = ->
  Session.get 'ActiveGoal'

share.deactivateGoal = (_id) ->
  if Session.equals 'ActiveGoal', _id
    Session.clear 'ActiveGoal'
    Session.clear 'ActiveGoalStartTime'
    Session.clear 'SecondsSinceActiveGoalStart'

share.activateGoal = (_id) ->
  Session.setAuth 'ActiveGoal', _id
  Session.setAuth 'ActiveGoalStartTime', new Date()
  Session.setAuth 'SecondsSinceActiveGoalStart', 0.0
  share.signalGoalActivated()

share.toggleActiveGoal = (_id) ->
  if Session.equals 'ActiveGoal', _id
    share.deactivateGoal _id
  else
    share.activateGoal _id

share.secondsSinceActiveGoalStart = ->
  Session.get 'SecondsSinceActiveGoalStart'
