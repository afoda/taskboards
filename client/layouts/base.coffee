Template.base_layout.helpers
  activeGoal: ->
    id = share.activeGoalId()
    Goals.findOne(id)
