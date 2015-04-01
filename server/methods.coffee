Meteor.methods
  createGoal: (title, parentId) ->
    Goals.insert
      title: title
      createdAt: new Date()
      parent: parentId
      userId: Meteor.userId()

  deleteGoal: (id) ->
    Goals.remove id

  toggleGoalComplete: (id) ->
    goal = Goals.findOne(id)
    Goals.update id, $set: complete: !goal.complete

  setGoalTitle: (id, title) ->
    Goals.update id, $set: title: title
