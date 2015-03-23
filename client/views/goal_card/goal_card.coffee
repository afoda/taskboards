recursiveRemove = (_id) ->
  subgoals = Goals.find {parent: _id}
  (recursiveRemove g._id for g in subgoals)
  Goals.remove _id

toggleEditingCard = (_id, template) ->
  if _id == Session.get 'EditingCard'
    Session.set 'EditingCard', null
  else
    Session.set 'EditingCard', _id

Template.goal_card.events

  'click .goal-remove-button': ->
    if confirm 'Are you sure you want to delete this goal?'
      recursiveRemove this._id

  'click .subgoal-complete-box': ->
    Goals.update this._id, $set: complete: !this.complete

  'click .goal-complete-button': ->
    Goals.update this._id, $set: complete: !this.complete

  'click .goal-card-edit-button': (event, template) ->
    toggleEditingCard this._id

  'dblclick .goal-card': (event, template) ->
    toggleEditingCard this._id

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
