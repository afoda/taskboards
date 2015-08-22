draggingActive = false
draggingElement = null # id, title, isTile
hoverPosition = null


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
  dragged = Goals.findOne draggingElement.id
  switch hoverPosition?.type
    when "first"
      Meteor.call "changePosition", dragged._id, hoverPosition.cardId, 0
    when "last"
      Meteor.call "changePosition", dragged._id, hoverPosition.cardId, null
    when "after"
      Meteor.call "changePosition", dragged._id, hoverPosition.cardId, hoverPosition.index
    when "subgoal"
      Meteor.call "changePosition", dragged._id, hoverPosition.subgoalId, null
      share.saveLastNesting dragged._id, hoverPosition.subgoalId, dragged.parent, dragged.index
      share.showNestingUndo()


setDragHover = null


elementPosition = (el) ->
  t  = el.offset()?.top
  l  = el.offset()?.left
  r  = l + el.outerWidth()
  b  = t + el.outerHeight()
  bc = b - parseFloat(el.css('border-bottom-width')) - parseFloat(el.css('padding-bottom'))
  { top: t, left: l, right: r, bottom: b, bottomC: bc }


clearDragHover = ->
  if hoverPosition?
    card = $("#" + hoverPosition.cardId)
    subgoalTable = card.find('table.goal-card-checklist')
    subgoalRows = subgoalTable.find('.subgoal-row')
    switch hoverPosition?.type
      when "subgoal"
        $(subgoalRows[hoverPosition.index]).removeClass 'dragging-hover'
      when "after"
        $(subgoalRows[hoverPosition.index]).next().remove()
        $(subgoalRows[hoverPosition.index]).removeClass 'compress-lower'
        $(subgoalRows[hoverPosition.index+1]).removeClass 'compress-lower'
      when "first"
        subgoalTable.find('.drag-placeholder').first().removeClass 'dragging-hover'
      when "last"
        subgoalTable.find('.drag-placeholder').last().removeClass 'dragging-hover'
    hoverPosition = null


setupCardDragging = ->
  card = $(this)
  cardId = card.attr("id")

  subgoalTable = card.find('table.goal-card-checklist')
  subgoalTable.addClass 'dragging'
  subgoalRows = subgoalTable.find('.subgoal-row')

  firstRow = subgoalRows.first()
  lastRow  = subgoalRows.last()

  draggedIsFirst = firstRow.attr('id') == draggingElement.id
  draggedIsLast  = lastRow.attr('id')  == draggingElement.id

  placeholderHtml = '<tr class="drag-placeholder"><td class="menu-cell"></td><td></td></tr>'
  card.find('tbody').append placeholderHtml if !subgoalRows.length
  console.log("Setup card dragging")
  firstRow.before placeholderHtml if !draggedIsFirst
  lastRow.after placeholderHtml   if !draggedIsLast

  subgoalRowTops    = subgoalRows.map(-> elementPosition($ this).top   ).get()
  subgoalRowBottoms = subgoalRows.map(-> elementPosition($ this).bottom).get()

  frPos = elementPosition firstRow
  lrPos = elementPosition lastRow
  cPos  = elementPosition card
  stPos = elementPosition subgoalTable

  switchDragHover = (newPosition) ->
    if !_.isEqual(newPosition, hoverPosition)
      clearDragHover()
      hoverPosition = newPosition
      switch newPosition.type
        when "subgoal"
          $(subgoalRows[newPosition.index]).addClass 'dragging-hover'
        when "after"
          $(subgoalRows[newPosition.index]).after placeholderHtml
          $(subgoalRows[newPosition.index]).next().addClass 'dragging-hover'
          $(subgoalRows[newPosition.index]).addClass 'compress-lower'
          $(subgoalRows[newPosition.index+1]).addClass 'compress-lower'
        when "first"
          subgoalTable.find('.drag-placeholder').first().addClass 'dragging-hover'
        when "last"
          subgoalTable.find('.drag-placeholder').last().addClass 'dragging-hover'

  setDragHover = (event) ->
    if !subgoalRows.length
      if (stPos.left <= x <= stPos.right) && (stPos.top <= y <= cPos.bottomC)
        switchDragHover {type: "first", cardId: cardId}
      else
        clearDragHover()
    else
      [x, y] = [event.pageX, event.pageY]
      if x < stPos.left || x > stPos.right || y < stPos.top || cPos.bottomC < y <= cPos.bottom
        clearDragHover()
      else if y < frPos.top
        if draggedIsFirst
          clearDragHover()
        else
          switchDragHover {type: "first", cardId: cardId}
      else if y > lrPos.bottom
        if draggedIsLast
          clearDragHover()
        else
          switchDragHover {type: "last", cardId: cardId}
      else
        subgoalRows.each (index) ->
          top     = subgoalRowTops[index]
          topB    = subgoalRowTops[index] + 10
          bottomB = subgoalRowBottoms[index] - 10
          bottom  = subgoalRowBottoms[index]
          if (index > 0) && (top <= y <= topB)
            switchDragHover {type: "after", cardId: cardId, index: index-1}
          else if topB < y < bottomB
            switchDragHover {type: "subgoal", cardId: cardId, index: index}
          else if (index < subgoalRows.length - 1) && (bottomB <= y <= bottom)
            switchDragHover {type: "after", cardId: cardId, index: index}

  card.on 'mousemove', setDragHover
  card.on 'mouseup', positionInCard


tearDownCardDragging = ->
  card = $(this)
  clearDragHover()
  card.find('.drag-placeholder').remove()
  card.find('.goal-card-checklist').removeClass 'dragging'
  card.off 'mousemove', setDragHover
  card.off 'mouseup', positionInCard


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
