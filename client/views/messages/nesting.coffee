Template.nesting_message.helpers
  lastDraggedTitle: ->
    goal = Goals.findOne share.lastDragged()
    goal?.title
  lastDroppedTitle: ->
    goal = Goals.findOne share.lastDropped()
    goal?.title
  messageShown: -> share.nestingUndoVisible()


Template.nesting_message.events
  'click .hide-message-button': ->
    share.hideNestingUndo()
  'click .nesting-undo-button': ->
    share.undoLastNesting()
    share.hideNestingUndo()
