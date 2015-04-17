Template.goal_card.events

  'click .subgoal-complete-box': ->
    share.toggleGoalComplete this._id

  'click .goal-card-edit-button': (event, template) ->
    share.setEditingCard this._id
    if template.find('input')
      template.find('input').focus()

  'click .subgoal-pop-button': ->
    parent = Goals.findOne @parentId
    Meteor.call "changePosition", @_id, parent.parentId, parent._id

  'dblclick .goal-card': (event, template) ->
    if not this.complete
      share.setEditingCard this._id
      if template.find('input')
        template.find('input').focus()

  'dblclick .ui.dropdown': (event) ->
    event.stopPropagation()

  'click #add-subgoal-button, keypress #new-subgoal-title': (event, template) ->
    if event.type == "click" || event.type == "keypress" && event.which == 13
      titleInput = template.find "input#new-subgoal-title"
      Meteor.call "createGoal", titleInput.value, this._id
      titleInput.value = ""


Template.goal_card.helpers

  editing: -> this._id == Session.get 'EditingCard'
  isActive: -> this._id == share.activeGoalId()

  filteredSubgoals: ->
    spec = parentId: @_id
    if @hideCompletedSubgoals
      spec.complete = $ne: true
    Goals.find spec, {sort: index: 1}


Template.new_subgoal_box.rendered = ->
  $(@find 'input').focus()


Template.subgoal_row.helpers
  isActive: -> this._id == share.activeGoalId()
  completedSubgoalCount: ->
    Goals
      .find parentId: this._id, complete: true
      .count()
  subgoalCount: ->
    Goals
      .find parentId: this._id
      .count()

Template.goal_card.rendered = ->
  $(@find '.goal-card-checklist > tbody').sortable
    connectWith: ".goal-card-checklist > tbody"
    placeholder: "checklist-placeholder"
    handle: ".subgoal-title-cell"
    update: (event, ui) ->
      dropped = ui.item.closest('.goal-card').attr('id')
      dragged = ui.item.attr('id')
      prev = ui.item.prev().attr('id')
      Meteor.call "changePosition", dragged, dropped, prev
  $(@find '.goal-card').draggable
    handle: '.header'
    helper: ->
      title = $(this).find('.header').text()
      "<div class='ui card'><div class='content'><div class='header'>" + title + "</div></div></div>"
    appendTo: "body"
    revert: true
    revertDuration: 0
  $(@find '.goal-card').droppable
    over: (event, ui) ->
      if ui.draggable.hasClass('goal-card')
        $(this).addClass('nest-goal-hover')
    out: (event, ui) ->
      $(this).removeClass('nest-goal-hover')
    drop: (event, ui) ->
      $(this).removeClass('nest-goal-hover')
      # drop is called when subgoal is dragged into subgoal list; filter these out.
      if ui.draggable.hasClass('goal-card')
        dropped = $(this).attr('id')
        dragged = ui.draggable.attr('id')
        Meteor.call "changePosition", dragged, dropped, null
