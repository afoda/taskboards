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
      isNewCard = $card.hasClass('new-card-placeholder')
      isDraggingElement = $card.attr('id') == draggingElement.id
      if !isNewCard && !isDraggingElement
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


positionAtPlaceholder = (placeholder) ->
  newParentId = placeholder.closest('.goal-card').attr('id')
  draggedId = draggingElement.id
  nextSubgoalId = placeholder.next('.subgoal-row').attr('id')
  nextSubgoal = Goals.findOne nextSubgoalId
  newIndex = if nextSubgoal? then nextSubgoal.index else null
  Meteor.call "changePosition", draggedId, newParentId, newIndex

positionInSubgoal = (subgoalRow) ->
  newParentId = subgoalRow.attr('id')
  draggedId = draggingElement.id
  dragged = Goals.findOne draggedId
  priorParent = dragged.parentId
  priorIndex = dragged.index
  Meteor.call "changePosition", draggedId, newParentId, null
  share.saveLastNesting draggedId, newParentId, priorParent, priorIndex
  share.showNestingUndo()

positionInCard = ->
  card = $(this)
  hovered = card.find '.dragging-hover'
  if hovered.length
    if hovered.hasClass 'drag-placeholder'
      positionAtPlaceholder hovered
    else
      positionInSubgoal hovered


setPlaceholderPadding = (card) ->
  lastPlaceholder = card.find('.drag-placeholder').last()
  placeholderPosition = lastPlaceholder.offset().top - card.offset().top
  cardBottomPadding = (card.innerHeight() - card.height()) / 2
  placeholderTopPadding = lastPlaceholder.innerHeight()
  remainingSpace = card.outerHeight() - placeholderPosition - cardBottomPadding - placeholderTopPadding
  placeholderBottomPadding = Math.max(remainingSpace, 0)
  lastPlaceholder.find 'td'
      .css
        "padding-bottom": placeholderBottomPadding + "px"


setDragHover = null


posTop     = (el) -> el.offset().top
posLeft    = (el) -> el.offset().left
posRight   = (el) -> (posLeft el) + el.outerWidth()
posBottom  = (el) -> (posTop el) + el.outerHeight()
posBottomC = (el) -> (posBottom el) - parseFloat(el.css('border-bottom-width')) - parseFloat(el.css('padding-bottom'))


setupCardDragging = ->
  card = $(this)
  subgoalTable = card.find('table.goal-card-checklist')
  subgoalRows = card.find('.subgoal-row')

  subgoalTable.addClass 'dragging'

  placeholderHtml = '<tr class="drag-placeholder"><td class="menu-cell"></td><td></td></tr>'
  subgoalRows.before (index) -> placeholderHtml
  card.find('tbody').append placeholderHtml
  setPlaceholderPadding card

  slots = card.find('.drag-placeholder, .subgoal-row')
  lastSlot = slots.last()
  exclude = slots.index($('#' + draggingElement.id)) # Note that this cannot be zero
  excludedSlots = if exclude < 0 then [] else [exclude - 1, exclude, exclude + 1]

  removeDragHover = ->
    subgoalTable.find(".dragging-hover").removeClass("dragging-hover")

  switchDragHover = (slot) ->
    if !slot.hasClass("dragging-hover")
      removeDragHover()
      slot.addClass("dragging-hover")

  setDragHover = (event) ->
    if event.pageX < (posLeft subgoalTable) || event.pageX > (posRight subgoalTable)
      removeDragHover()
    else if (posBottom subgoalTable) < event.pageY <= (posBottomC card)
      switchDragHover lastSlot
    else if (posBottomC card) < event.pageY <= (posBottom card)
      removeDragHover()
    else
      slots.each (index) ->
        slot = $(this)
        if (posTop slot) <= event.pageY <= (posBottom slot)
          if excludedSlots.indexOf(index) == -1
            switchDragHover slot
          else
            removeDragHover()

  card.on 'mousemove', setDragHover
  card.on 'mouseup', positionInCard


tearDownCardDragging = ->
  card = $(this)
  card.off 'mousemove', setDragHover
  card.off 'mouseup', positionInCard
  card.find('.drag-placeholder').remove()
  card.find('.dragging-hover').removeClass 'dragging-hover'
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
