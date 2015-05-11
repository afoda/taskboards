# Session variables.
# ActiveGoal (str): the id of the currently active goal
# ActiveGoalStartTime (date): the time at which the currently active goal was activated
# SecondsSinceActiveGoalStart (number): number of seconds between now and ActiveGoalStartTime (updated every second)

UI.registerHelper 'isActive', (_id) -> _id == share.activeGoalId()

Meteor.setInterval ->
    timeStart = Session.get "ActiveGoalStartTime"
    timeNow = new Date()
    seconds = (timeNow - timeStart) / 1000.0
    Session.set 'SecondsSinceActiveGoalStart', seconds
  , 1000

share.activeGoalId = ->
  Session.get 'ActiveGoal'

share.deactivateGoal = (_id) ->
  if Session.equals 'ActiveGoal', _id
    Session.clear 'ActiveGoal'
    Session.clear 'ActiveGoalStartTime'

share.activateGoal = (_id) ->
  Session.setPersistent 'ActiveGoal', _id
  Session.setPersistent 'ActiveGoalStartTime', new Date()
  sweepDuration = 30 * 60 * 3600
  sweep document.querySelector('#goal-timer'), 'color', '#3AC433', '#FD7478', {direction: -1, duration: sweepDuration}

share.toggleActiveGoal = (_id) ->
  if Session.equals 'ActiveGoal', _id
    share.deactivateGoal _id
  else
    share.activateGoal _id

share.secondsSinceActiveGoalStart = ->
  Session.get 'SecondsSinceActiveGoalStart'
