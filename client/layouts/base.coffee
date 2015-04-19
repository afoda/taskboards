Template.base_layout.helpers
  activeGoal: ->
    id = share.activeGoalId()
    Goals.findOne(id)
  activeGoalTime: ->
    seconds = share.secondsSinceActiveGoalStart()
    days    = Math.floor (seconds / (60 * 60 * 24))
    hours   = Math.floor (seconds / (60 * 60))
    minutes = Math.floor (seconds / (60))
    twoDigits = (x) -> if x < 10 then "0" + (Math.round x) else (Math.round x)
    if !hours
      return (twoDigits minutes) + ":" + (twoDigits (seconds % 60))
    if !days
      return (twoDigits hours) + "h " + (twoDigits (minutes % 60)) + "m"
    return days + "d " + (twoDigits (hours % 24)) + "h"

Template.base_layout.events =
  'click': (event) ->
    if not $(event.target).closest('#' + share.editingCardId()).length
      share.clearEditingCard()
