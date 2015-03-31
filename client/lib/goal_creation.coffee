share.createGoal = (title, parentId) ->
  Goals.insert
    title: title
    parent: parentId
