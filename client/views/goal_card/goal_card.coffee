Template.goal_card.events

  'click .subgoal-complete-box': ->
    share.toggleGoalComplete this.goal._id

  'click .goal-card-edit-button': (event, template) ->
    share.setEditingCard this.goal._id
    if template.find('input')
      template.find('input').focus()

  'dblclick .goal-card': (event, template) ->
    if not this.goal.complete
      share.setEditingCard this.goal._id
      if template.find('input')
        template.find('input').focus()

  'dblclick .ui.dropdown': (event) ->
    event.stopPropagation()

  'blur .new-subgoal-title': ->
    share.clearEditingCard()

  'keypress .new-subgoal-title': (event, template) ->
    if event.which == 13
      titleInput = template.find "input.new-subgoal-title"
      goalTitle = $.trim(titleInput.value)
      if goalTitle != ""
        Meteor.call "createGoal", goalTitle, this.goal._id
        titleInput.value = ""

  'click .sorting-mode-toggle': (event, template) ->
    share.toggleSortingMode()


Template.goal_card.helpers
  editing: -> this.goal._id == Session.get 'EditingCard'


Template.new_subgoal_row.rendered = ->
  $(@find 'input').focus()


Template.subgoal_row.events
  'click .subgoal-pop-button': ->
    parent = Goals.findOne @goal.parentId
    Meteor.call "changePosition", @goal._id, parent.parentId, parent._id


Template.subgoal_row.helpers
  completedSubgoalCount: ->
    Goals
      .find parentId: this.goal._id, complete: true
      .count()
  subgoalCount: ->
    Goals
      .find parentId: this.goal._id
      .count()


Template.subgoal_row.rendered = ->
  if not share.inSortingMode()
    share.setRowDragging 0, this.firstNode

Template.goal_card.rendered = ->
  if share.inSortingMode()
    share.setCardSorting 0, this.firstNode
  else
    share.setCardDragging 0, this.firstNode
