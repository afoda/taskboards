# Sorting mode state

Session.setDefault "SortingMode", false

share.inSortingMode = -> Session.get "SortingMode"

UI.registerHelper "inSortingMode", -> share.inSortingMode()


# Switching in and out of sorting mode

share.toggleSortingMode = ->
  if share.inSortingMode()
    share.stopSortingMode()
  else
    share.startSortingMode()

share.startSortingMode = ->
  Session.set "SortingMode", true
  share.removeAllDragging()
  share.setAllSorting()

share.stopSortingMode = ->
  Session.set "SortingMode", false
  share.removeAllSorting()
  share.setAllDragging()


# Setting and removing dragging constructs

share.setAllDragging = ->
  $('.goal-card').not('.new-card-placeholder').each share.setCardDragging
  $('.subgoal-row').each share.setRowDragging

share.removeAllDragging = ->
  cards = $('.goal-card').not('.new-card-placeholder')
  cards.draggable "destroy"
  cards.droppable "destroy"
  subgoals = $('.subgoal-row')
  subgoals.draggable "destroy"
  subgoals.droppable "destroy"

share.setCardDragging = (index, card) ->
  card = $(card)
  card.draggable
    handle: '.header'
    helper: ->
      title = $(this).find('.header').text()
      "<div class='card-drag-placeholder'>" + title + "</div>"
    revert: true
    revertDuration: 0
  card.droppable
    hoverClass: 'nest-goal-hover'
    tolerance: 'pointer'
    accept: (draggable) ->
      (not draggable.closest("#" + card.attr('id')).length)
    drop: (event, ui) ->
      dropped = $(this).attr('id')
      dragged = ui.draggable.attr('id')
      Meteor.call "changePosition", dragged, dropped, null

share.setRowDragging = (index, row) ->
  row = $(row)
  row.draggable
    helper: 'clone'
  row.droppable
    accept: "#" + row.closest('.goal-card').attr('id') + " .subgoal-row"
    hoverClass: 'nest-goal-hover'
    tolerance: 'pointer'
    drop: (event, ui) ->
      dropped = $(this).attr('id')
      dragged = ui.draggable.attr('id')
      draggedGoal = Goals.findOne dragged
      share.saveLastNesting dragged, dropped, draggedGoal.parentId, draggedGoal.index
      share.showNestingUndo()
      Meteor.call "changePosition", dragged, dropped, null


# Setting and removing sorting constructs

share.setAllSorting = ->
  $('.goal-card').each share.setCardSorting

share.removeAllSorting = ->
  $('.goal-card tbody').sortable "destroy"

share.setCardSorting = (index, card) ->
  card = $(card)
  card.find('tbody').sortable
    placeholder: "checklist-placeholder"
    handle: ".subgoal-title"
    update: (event, ui) ->
      dropped = ui.item.closest('.goal-card').attr('id')
      dragged = ui.item.attr('id')
      prev = ui.item.prev().attr('id')
      Meteor.call "changePosition", dragged, dropped, prev
