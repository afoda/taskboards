Template.goal_tree.events

  'click #add-goal-button, keypress #new-goal-title': (event, template) ->
    if event.type == "click" || event.type == "keypress" && event.which == 13
      titleInput = template.find "#new-goal-title"
      Meteor.call "createGoal", titleInput.value, this.goal?._id
      titleInput.value = ""

  'click .goal-remove-button': ->
    if confirm 'Are you sure you want to delete this goal?'
      Meteor.call "recursiveRemove", this.goal._id

  'click .goal-complete-button': ->
    share.toggleGoalComplete this.goal._id

  'click .goal-active-toggle': ->
    share.toggleActiveGoal this.goal._id

  'click .edit-goal-title-button': ->
    newTitle = prompt 'Enter goal title', this.goal.title
    if newTitle?
      Meteor.call "setGoalTitle", this.goal._id, newTitle

  'click .goal-hide-completed-subgoals-toggle': ->
    Meteor.call "toggleHideCompletedSubgoals", this.goal._id


Template.breadcrumb.helpers
  isContext: (contextGoalId) -> @_id == contextGoalId


Template.goal_tree.helpers

  atTopLevel: -> !(this.goal?)
  isActive: -> this.goal._id == share.activeGoalId()

  filteredSubgoals: ->
    if this.goal?
      spec = parentId: @goal._id
      if @goal.hideCompletedSubgoals
        spec.complete = $ne: true
      Goals.find spec, sort: index: 1
    else
      Goals.find $or: [{parentId: {$exists: false}}, {parentId: null}]
