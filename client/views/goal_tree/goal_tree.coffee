Template.goal_tree.events

  'click .submit-card-button, keypress .new-card-title': (event, template) ->
    if event.type == "click" || event.type == "keypress" && event.which == 13
      titleInput = template.find ".new-card-title"
      goalTitle = $.trim(titleInput.value)
      if goalTitle != ""
        titleInput.blur()
        Meteor.call "createGoal", goalTitle, this.goal?._id, share.setCreatedCardEditing
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
    if @goal?
      Meteor.call "toggleHideCompletedSubgoals", this.goal._id
    else
      share.toggleHomeHideComplete()

  'click #pop-stack-link': (event) ->
    if not $(event.target).closest("#breadcrumb-menu").length
      if this.goal.parentId
        Router.go('goal', {_id: this.goal.parentId}, {hash: this.goal._id})
      else
        Router.go('/')

  'click': (event) ->
    # Hide all message boxes when clicking out of them
    if not $(event).closest(".message-box").length
      share.hideNestingUndo()


Template.goal_tree.helpers

  activeGoal: ->
    id = share.activeGoalId()
    Goals.findOne(id)
  atTopLevel: ->
    !(this.goal?)

  hidingCompleted: ->
    if @goal?
      @goal.hideCompletedSubgoals
    else
      share.homeHideComplete()


UI.registerHelper "filteredSubgoals", ->
  spec = parentId: if @goal? then @goal._id else null
  if @goal? && @goal.hideCompletedSubgoals || !@goal? && share.homeHideComplete()
    spec.complete = $ne: true
  Goals.find spec, sort: index: 1
