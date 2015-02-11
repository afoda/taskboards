Template.goal_tree.events

  'click #add-subgoal-button, keypress #new-subgoal-title': (event, template) ->
    if event.type == "click" || event.type == "keypress" && event.which == 13
      titleInput = template.find "#new-subgoal-title"
      Goals.insert
        title: titleInput.value
        parent: this.goal._id
      titleInput.value = ""


Template.registerHelper "isParent", (parentContext) -> this._id == parentContext?.parent?._id
Template.registerHelper "isContext", (parentContext) -> this._id == parentContext.goal._id
Template.registerHelper "isParentOrContext", (parentContext) -> this._id == parentContext.goal._id || this._id == parentContext?.parent?._id


recursiveRemove = (_id) ->
  goal = Goals.find _id
  subgoals = Goals.find {parent: _id}
  (recursiveRemove g._id  for g in subgoals)
  Goals.remove _id


Template.goal_row.events

  'click .goal-remove-button': (event) ->
    event.preventDefault()
    recursiveRemove this._id
  'click .goal-complete-box': (event) ->
    event.preventDefault()
    Goals.update this._id, $set: complete: !this.complete
