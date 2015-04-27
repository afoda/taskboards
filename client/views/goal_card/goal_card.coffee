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

  'click .add-subgoal-button, keypress .new-subgoal-title': (event, template) ->
    if event.type == "click" || event.type == "keypress" && event.which == 13
      titleInput = template.find "input.new-subgoal-title"
      Meteor.call "createGoal", titleInput.value, this.goal._id
      titleInput.value = ""


Template.goal_card.helpers

  editing: -> this.goal._id == Session.get 'EditingCard'

  filteredSubgoals: ->
    spec = parentId: @goal._id
    if @goal.hideCompletedSubgoals
      spec.complete = $ne: true
    Goals.find spec, {sort: index: 1}


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

Template.goal_card.rendered = ->

  goalId = this.data.goal._id

  $(@findAll '.subgoal-row').draggable
    helper: 'clone'
  $(@findAll '.subgoal-row').droppable
    accept: "#" + this.data.goal._id + " .subgoal-row"
    hoverClass: 'nest-goal-hover'
    greedy: true
    drop: (event, ui) ->
      dropped = $(this).attr('id')
      dragged = ui.draggable.attr('id')
      Meteor.call "changePosition", dragged, dropped, null

  $(@find '.goal-card').draggable
    handle: '.header'
    helper: ->
      title = $(this).find('.header').text()
      "<div class='card-drag-placeholder'>" + title + "</div>"
    revert: true
    revertDuration: 0
  $(@find '.goal-card').droppable
    hoverClass: 'nest-goal-hover'
    accept: (draggable) ->
      not draggable.closest("#" + goalId).length
    drop: (event, ui) ->
      dropped = $(this).attr('id')
      dragged = ui.draggable.attr('id')
      Meteor.call "changePosition", dragged, dropped, null
