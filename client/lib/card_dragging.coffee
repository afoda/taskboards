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

    $('.goal-card')
      .filter(":not(#" + draggingElement.id + ")")
      .filter(":not(.new-card-placeholder)")
      .each (index, card) ->
        $(card).on "mouseenter", setupCardDragging
        $(card).on "mouseleave", tearDownCardDragging

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


positionInCard = ->
  card = $(this)
  slots = card.find('.subgoal-row, .drag-placeholder')
  dragged = Goals.findOne draggingElement.id
  hovered = card.find('.dragging-hover')
  if hovered.length
    if hovered.hasClass('subgoal-row')
      Meteor.call "changePosition", dragged._id, hovered.attr('id'), null
      share.saveLastNesting dragged._id, hovered.attr('id'), dragged.parentId, dragged.index
      share.showNestingUndo()
    else
      nextSlot = hovered.next()
      if nextSlot.length
        nextGoal = Goals.findOne nextSlot.attr('id')
        Meteor.call "changePosition", dragged._id, card.attr('id'), nextGoal.index
      else
        Meteor.call "changePosition", dragged._id, card.attr('id'), null


posTop     = (el) -> el.offset()?.top
posLeft    = (el) -> el.offset()?.left
posRight   = (el) -> (posLeft el) + el.outerWidth()
posBottom  = (el) -> (posTop el) + el.outerHeight()
posBottomC = (el) -> (posBottom el) - parseFloat(el.css('border-bottom-width')) - parseFloat(el.css('padding-bottom'))


cardDragClasses = 'first-expanded middle-expanded last-expanded'

setDragHover = null

clearDragHover = (card) ->
  card.find('.dragging-hover').removeClass 'dragging-hover'
  card.find('.goal-card-checklist').removeClass cardDragClasses


setupCardDragging = ->
  card = $(this)
  cardId = card.attr("id")

  subgoalTable = card.find('table.goal-card-checklist')
  subgoalTable.addClass 'dragging'
  subgoalRows = subgoalTable.find('.subgoal-row')

  placeholderHtml = '<tr class="drag-placeholder"><td class="menu-cell"></td><td></td></tr>'
  subgoalRows.before placeholderHtml
  subgoalTable.find('tbody').append placeholderHtml

  slots = subgoalTable.find('.subgoal-row, .drag-placeholder')
  exclude = slots.index($('#' + draggingElement.id)) # Note that this cannot be zero
  excludedSlots = if exclude < 0 then [] else [exclude - 1, exclude, exclude + 1]

  stPos =
    top: posTop subgoalTable
    left: posLeft subgoalTable
    right: posRight subgoalTable
    bottom: posBottom subgoalTable

  cPos =
    bottom: posBottom card
    bottomC: posBottomC card

  switchDragHover = (index) ->
    slot = $(slots[index])
    if !slot.hasClass('dragging-hover')
      clearDragHover card
      if excludedSlots.indexOf(index) == -1
        slot.addClass 'dragging-hover'
        switch index
          when 0
            subgoalTable.addClass 'first-expanded'
          when slots.length - 1
            subgoalTable.addClass 'last-expanded'
          else
            subgoalTable.addClass 'middle-expanded'

  setDragHover = (event) ->
    [x, y] = [event.pageX, event.pageY]
    if x < stPos.left || x > stPos.right || y < stPos.top || cPos.bottomC < y <= cPos.bottom
      clearDragHover card
    else if stPos.bottom < y <= cPos.bottomC
      switchDragHover (slots.length - 1)
    else
      slots.each (index) ->
        row = $(this)
        if (posTop row) <= y <= (posBottom row)
          switchDragHover index

  card.on 'mousemove', setDragHover
  card.on 'mouseup', positionInCard


tearDownCardDragging = ->
  card = $(this)
  card.off 'mousemove', setDragHover
  card.off 'mouseup', positionInCard
  clearDragHover card
  card.find('.drag-placeholder').remove()
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
