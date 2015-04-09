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
    validateGoalAccess id
    check(id, String)
    Goals.remove id

  toggleGoalComplete: (id) ->
    validateGoalAccess id
    check(id, String)
    goal = Goals.findOne(id)
    Goals.update id, $set: complete: !goal.complete

  setGoalTitle: (id, title) ->
    validateGoalAccess id
    check(id, String)
    check(title, String)
    Goals.update id, $set: title: title

  toggleHideCompletedSubgoals: (id) ->
    validateGoalAccess id
    check(id, String)
    goal = Goals.findOne(id)
    Goals.update id, $set: hideCompletedSubgoals: !goal.hideCompletedSubgoals

  changeParent: (id, newParentId) ->
    check(id, String)
    check(newParentId, String)
    validateGoalAccess id
    validateGoalAccess newParentId
    # Check that the move doesn't introduce a cycle
    ancestor = Goals.findOne newParentId
    throw new Meteor.Error("cycle") if ancestor._id == id
    while ancestor.parent?
      ancestor = Goals.findOne ancestor.parent
      throw new Meteor.Error("cycle") if ancestor._id == id
    Goals.update id, $set: parent: newParentId
