Template.goal_tree.events

  'click .submit-card-button, keypress .new-card-title': (event, template) ->
    if event.type == "click" || event.type == "keypress" && event.which == 13
      titleInput = template.find ".new-card-title"
      goalTitle = $.trim(titleInput.value)
      if goalTitle != ""
        Meteor.call "createGoal", goalTitle, this.goal?._id
        titleInput.value = ""

  'click .submit-card-button': (event, template) ->
      template.find(".new-card-title").focus()

  'click .add-card-button': (event, template) ->
      template.find(".new-card-title").focus()

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

  'click #pop-stack-link': ->
    if not $(event.target).closest("#breadcrumb-menu").length
      if this.goal.parentId
        Router.go('goal', {_id: this.goal.parentId}, {hash: this.goal._id})
      else
        Router.go('/')


Template.goal_tree.helpers

  filteredSubgoals: ->
    if this.goal?
      spec = parentId: @goal._id
      if @goal.hideCompletedSubgoals
        spec.complete = $ne: true
      Goals.find spec, sort: index: 1
    else
      Goals.find $or: [{parentId: {$exists: false}}, {parentId: null}]
  activeGoal: ->
    id = share.activeGoalId()
    Goals.findOne(id)
  atTopLevel: ->
    !(this.goal?)
