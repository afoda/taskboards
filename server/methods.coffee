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
    lastInParent = Goals.findOne {parentId: parentId}, {sort: {index: -1}}
    newIndex = if lastInParent? then lastInParent.index + 1 else 0
    Goals.insert
      title: title
      createdAt: new Date()
      parentId: parentId
      userId: Meteor.userId()
      index: newIndex

  recursiveRemove: (_id) ->
    check(_id, String)
    validateGoalAccess _id
    subgoals = Goals.find {parentId: _id}
    subgoals.forEach (g) -> Meteor.call "recursiveRemove", g._id
    Goals.remove _id

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

  changePosition: (id, newParentId, prevId) ->
    check(id, String)
    check(newParentId, String)
    check(prevId, Match.OneOf(String, undefined, null))
    validateGoalAccess id
    validateGoalAccess newParentId
    # Check that the move doesn't introduce a cycle
    ancestor = Goals.findOne newParentId
    throw new Meteor.Error("cycle") if ancestor._id == id
    while ancestor.parentId?
      ancestor = Goals.findOne ancestor.parentId
      throw new Meteor.Error("cycle") if ancestor._id == id
    if prevId?
      prev = Goals.findOne prevId
      Goals.update {parentId: newParentId, index: {$gt: prev.index}}, {$inc: {index: 1}}, {multi: true}
      Goals.update id, $set: {parentId: newParentId, index: prev.index + 1}
    else
      Goals.update {parentId: newParentId}, {$inc: {index: 1}}, {multi: true}
      Goals.update id, $set: {parentId: newParentId, index: 0}
