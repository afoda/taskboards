validateHasUserId = ->
  if !Meteor.userId()
    throw new Meteor.Error("not-authorized")

validateGoalAccess = (id) ->
  validateHasUserId()
  goal = Goals.findOne(id)
  if !goal.userId? || goal.userId != Meteor.userId()
    throw new Meteor.Error("not-authorized")

Meteor.methods
  createGoal: (title, parentId) ->
    validateHasUserId()
    Goals.insert
      title: title
      createdAt: new Date()
      parent: parentId
      userId: Meteor.userId()

  deleteGoal: (id) ->
    validateGoalAccess id
    Goals.remove id

  toggleGoalComplete: (id) ->
    validateGoalAccess id
    goal = Goals.findOne(id)
    Goals.update id, $set: complete: !goal.complete

  setGoalTitle: (id, title) ->
    validateGoalAccess id
    Goals.update id, $set: title: title
