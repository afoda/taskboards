recursiveRemove = (_id) ->
  subgoals = Goals.find {parent: _id}
  (recursiveRemove g._id for g in subgoals)
  Meteor.call "deleteGoal", _id

Template.goal_card.events

  'click .goal-remove-button': ->
    if confirm 'Are you sure you want to delete this goal?'
      recursiveRemove this._id

  'click .subgoal-complete-box': ->
    share.toggleGoalComplete this._id

  'click .goal-complete-button': ->
    share.toggleGoalComplete this._id

  'click .goal-card-active-toggle': ->
    share.toggleActiveGoal this._id

  'click .goal-card-edit-button': (event, template) ->
    share.setEditingCard this._id
    if template.find('input')
      template.find('input').focus()

  'click .goal-card-edit-title-button': ->
    newTitle = prompt 'Enter goal title', this.title
    if newTitle?
      Meteor.call "setGoalTitle", this._id, newTitle

  'click .goal-card-hide-completed-subgoals-toggle': ->
    Meteor.call "toggleHideCompletedSubgoals", this._id

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

  subgoals: -> Goals.find {parent: this._id}
  editing: -> this._id == Session.get 'EditingCard'
  isActive: -> this._id == share.activeGoalId()
  displayGoal: (complete) ->
    hideCompleted = Template.parentData(1).hideCompletedSubgoals
    not hideCompleted || not complete


Template.new_subgoal_box.rendered = ->
  $(@find 'input').focus()


Template.subgoal_row.helpers
  isActive: -> this._id == share.activeGoalId()
