Template.goal_tree.events

  'click #add-goal-button, keypress #new-goal-title': (event, template) ->
    if event.type == "click" || event.type == "keypress" && event.which == 13
      titleInput = template.find "#new-goal-title"
      Goals.insert
        title: titleInput.value
        parent: this.goal._id
      titleInput.value = ""


Template.registerHelper "isContext", (parentContext) -> this._id == parentContext.goal._id


Template.goal_tree.helpers

  chainLengthGte: (n) -> this.breadcrumb.length >= n

  toplevel: -> if this.breadcrumb.length >= 3 then this.breadcrumb[0] else null
  parent: -> if this.breadcrumb.length >= 2 then this.breadcrumb[this.breadcrumb.length - 2] else null
  context: -> this.breadcrumb[this.breadcrumb.length - 1]
