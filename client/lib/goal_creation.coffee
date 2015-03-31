share.createGoal = (title, parentId) ->
  Goals.insert
    title: title
    createdAt: new Date()
    parent: parentId
