recursiveRemove = (_id) ->
  subgoals = Goals.find {parent: _id}
  (recursiveRemove g._id for g in subgoals)
  Goals.remove _id

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
      Goals.update this._id, $set: title: newTitle

  'dblclick .goal-card': (event, template) ->
    share.setEditingCard this._id
    if template.find('input')
      template.find('input').focus()

  'click #add-subgoal-button, keypress #new-subgoal-title': (event, template) ->
    if event.type == "click" || event.type == "keypress" && event.which == 13
      titleInput = template.find "input#new-subgoal-title"
      Goals.insert
        title: titleInput.value
        parent: this._id
      titleInput.value = ""


Template.goal_card.helpers

  subgoals: -> Goals.find {parent: this._id}
  editing: -> this._id == Session.get 'EditingCard'
  isActive: -> this._id == share.activeGoalId()


Template.new_subgoal_box.rendered = ->
  $(@find 'input').focus()
