Template.goal_list.events

  'click #add-goal-button': (event, template) ->
    event.preventDefault()
    titleInput = template.find "#new-goal-title"
    Goals.insert title: titleInput.value
    titleInput.value = ""
