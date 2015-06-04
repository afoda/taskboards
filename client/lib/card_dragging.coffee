draggingActive = false
draggingElement = null # id, title, isTile


preventDefault = (event) -> event.preventDefault()

enableDragging = (event) ->
  if !draggingActive
    $(window).one 'mouseup', finishDragging
    $(window).on 'mousemove', updateDragHelper

    helperHtml = "<div id='drag-helper'>#{draggingElement.title}</div>"
    $('body').append(helperHtml)
    updateDragHelper(event)

    $('.goal-card').each (index, card) ->
      $card = $ card
      if $card.attr('id') != draggingElement.id
        $card.on "mouseenter", setupCardDragging
        $card.on "mouseleave", tearDownCardDragging

    if not draggingElement.isTile
      card = $('#' + draggingElement.id).closest('.goal-card')
      setupCardDragging.bind(card)()

    $(window).on 'mousemove', preventDefault
    draggingActive = true


finishDragging = ->
  $(window).off 'mousemove', updateDragHelper
  $(window).off 'mousemove', preventDefault

  $('.goal-card').each (index, card) ->
    $(card).off "mouseenter", setupCardDragging
    $(card).off "mouseleave", tearDownCardDragging

  $('.goal-card').each tearDownCardDragging

  draggingActive = false
  $("#drag-helper").remove()


updateDragHelper = (event) ->
  $('#drag-helper').css
   left:  event.pageX
   top:   event.pageY
  return false


addDraggingHover = -> $(this).addClass 'dragging-hover'
removeDraggingHover = -> $(this).removeClass 'dragging-hover'


positionAtPlaceholder = ->
  placeholder = $(this)
  newParentId = placeholder.closest('.goal-card').attr('id')
  draggedId = draggingElement.id
  nextSubgoalId = placeholder.next('.subgoal-row').attr('id')
  nextSubgoal = Goals.findOne nextSubgoalId
  newIndex = if nextSubgoal? then nextSubgoal.index else null
  Meteor.call "changePosition", draggedId, newParentId, newIndex
  (tearDownCardDragging.bind $(@).closest '.goal-card')()

positionInSubgoal = ->
  newParentId = $(this).attr('id')
  draggedId = draggingElement.id
  dragged = Goals.findOne draggedId
  priorParent = dragged.parentId
  priorIndex = dragged.index
  Meteor.call "changePosition", draggedId, newParentId, null
  (tearDownCardDragging.bind $(@).closest '.goal-card')()
  share.saveLastNesting draggedId, newParentId, priorParent, priorIndex
  share.showNestingUndo()


setupCardDragging = ->
  card = $(this)
  subgoalRows = card.find('.subgoal-row')
  card.find('table.goal-card-checklist').addClass 'dragging'

  placeholderHtml = '<tr class="drag-placeholder"><td class="menu-cell"></td><td></td></tr>'
  subgoalRows.before (index) -> placeholderHtml
  card.find('tbody').append placeholderHtml

  card.find('.drag-placeholder, .subgoal-row').on 'mouseenter', addDraggingHover
  card.find('.drag-placeholder, .subgoal-row').on 'mouseleave', removeDraggingHover

  card.find('.drag-placeholder').on 'mouseup', positionAtPlaceholder
  card.find('.subgoal-row').on 'mouseup', positionInSubgoal

  # Disable drag interactions around the dragged element

  disableDragging = (el) ->
    $(el).off 'mouseenter', addDraggingHover
    $(el).off 'mouseup', positionInSubgoal
    $(el).off 'mouseup', positionAtPlaceholder

  disableDragging card.find('#' + draggingElement.id)
  disableDragging card.find('#' + draggingElement.id).next()
  disableDragging card.find('#' + draggingElement.id).prev()


tearDownCardDragging = ->
  card = $(this)
  card.find('.drag-placeholder').remove()
  card.find('.dragging-hover').removeClass 'dragging-hover'
  card.find('.subgoal-row').off 'mouseenter', addDraggingHover
  card.find('.subgoal-row').off 'mouseleave', removeDraggingHover
  card.find('.subgoal-row').off 'mouseup', positionInSubgoal
  card.find('table.goal-card-checklist').removeClass 'dragging'


share.setCardDragging = (card) ->
  title = card.find('.header a')
  title.on 'mousedown', ->
    draggingElement =
      id: card.attr('id')
      title: title.text()
      isTile: true
    $(window).one 'mousemove', enableDragging
    disableTitleClick = -> title.one 'click', preventDefault
    $(window).one 'mousemove', disableTitleClick
    $(window).one 'mouseup', -> $(window).off 'mousemove', enableDragging
    $(window).one 'mouseup', -> $(window).off 'mousemove', disableTitleClick

share.setSubgoalRowDragging = (subgoalRow) ->
  title = subgoalRow.find('.subgoal-title')
  title.on 'mousedown', ->
    draggingElement =
      id: subgoalRow.attr('id')
      title: title.text()
      isTile: false
    $(window).one 'mousemove', enableDragging
    disableTitleClick = -> title.one 'click', preventDefault
    $(window).one 'mousemove', disableTitleClick
    $(window).one 'mouseup', -> $(window).off 'mousemove', enableDragging
    $(window).one 'mouseup', -> $(window).off 'mousemove', disableTitleClick


# Disable default drag and drop in firefox
$(document).on "dragstart", -> false
