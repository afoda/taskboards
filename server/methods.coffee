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
    check(title, String)
    check(parentId, Match.Optional(String))
    Goals.insert
      title: title
      createdAt: new Date()
      parent: parentId
      userId: Meteor.userId()

  deleteGoal: (id) ->
    check(id, String)
    validateGoalAccess id
    Goals.remove id

  toggleGoalComplete: (id) ->
    check(id, String)
    validateGoalAccess id
    goal = Goals.findOne(id)
    Goals.update id, $set: complete: !goal.complete

  setGoalTitle: (id, title) ->
    check(id, String)
    check(title, String)
    validateGoalAccess id
    Goals.update id, $set: title: title

  toggleHideCompletedSubgoals: (id) ->
    check(id, String)
    validateGoalAccess id
    goal = Goals.findOne(id)
    Goals.update id, $set: hideCompletedSubgoals: !goal.hideCompletedSubgoals
