Template.base_layout.helpers
  activeGoal: ->
    id = share.activeGoalId()
    Goals.findOne(id)
  noActiveGoal: ->
    not share.activeGoalId()?

Template.base_layout.events =
  'click': (event) ->
    if not $(event.target).closest('#' + share.editingCardId()).length
      share.clearEditingCard()
