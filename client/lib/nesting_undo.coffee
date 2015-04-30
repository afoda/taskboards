# Saving of nesting actions for undo

share.saveLastNesting = (dragged, dropped, previousParent, previousIndex) ->
  Session.set "LastDragged", dragged
  Session.set "LastDropped", dropped
  Session.set "LastDraggedPreviousParent", previousParent
  Session.set "LastDraggedPreviousIndex", previousIndex

share.lastDraggedPreviousParent = -> Session.get "LastDraggedPreviousParent"
share.lastDraggedPreviousIndex = -> Session.get "LastDraggedPreviousIndex"
share.lastDragged = -> Session.get "LastDragged"
share.lastDropped = -> Session.get "LastDropped"


# Showing and hiding undo message

share.nestingUndoVisible = -> Session.get "NestingUndoVisible"
share.showNestingUndo = -> Session.set "NestingUndoVisible", true
share.hideNestingUndo = -> Session.set "NestingUndoVisible", false


# Undoing the last nesting

share.undoLastNesting = ->
  lastDragged = share.lastDragged()
  previousParent = share.lastDraggedPreviousParent()
  previousIndex = share.lastDraggedPreviousIndex()
  # previousIndex cannot straightforwardly be used to restore element to its original position
  Meteor.call "changePosition", lastDragged, previousParent, null
