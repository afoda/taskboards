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


Template.goal_card.helpers
  editing: -> Session.equals 'EditingCard', @goal._id


Template.goal_card.rendered = ->
  share.setCardDragging @firstNode


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
