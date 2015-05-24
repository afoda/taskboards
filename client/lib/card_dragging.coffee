draggingActive = false
draggingElement = null # id, title, isTile, priorIndex
draggingPosition = null # over, index


moveInsideCardHandlers = {}


enableDragging = ->
  if !draggingActive
    console.log("dragging enabled")
    draggingActive = true
    helper = $('#drag-helper')
    helper.text(draggingElement.title)
    helper.show()
    $(window).on 'mousemove', updateDragHelper
    $('.goal-card').each (index, card) ->
      card = $(card)
      cardId = card.attr('id')
      moveInsideCardHandlers[cardId] = moveInsideCardHandlerFactory card
      card.on "mousemove", moveInsideCardHandlers[cardId]

finishDragging = ->
  console.log("finish dragging called")
  if draggingActive
    $(window).off 'mousemove', updateDragHelper
    draggingElement = null
    draggingPosition = null
    draggingActive = false
    $("#drag-helper").hide()

updateDragHelper = (event) ->
  $('#drag-helper').css
   left:  event.pageX
   top:   event.pageY
  return false

$(window).on 'mouseup', finishDragging


moveInsideCardHandlerFactory = (card) ->
  # TODO : Make sure this is set up each time dragging is started.
  subgoals = $(card.find ".subgoal-row")

  getCurrentPosition = (mouseY) ->
    # TODO : Test whether drop is possible
    canDrop = (taskId, into) ->
      taskId != $(into).attr('id')
    # TODO : Adjust math for when placeholder is present
    insertWidth = 10

    placeholder = $(card.find '#drag-placeholder')
    if placeholder.length > 0
      pTop = placeholder.offset().top
      pBottom = pTop + placeholder.height()
      if pTop <= mouseY <= pBottom
        return draggingPosition

    index = 0
    while index < subgoals.length
      subgoal = $(subgoals[index])

      subgoalTop = subgoal.offset().top
      insertTop = subgoalTop - insertWidth / 2
      insertBottom = subgoalTop + insertWidth / 2
      if insertTop <= mouseY <= insertBottom
        return {} =
          over: card.attr 'id'
          index: index

      subgoalBottom = subgoalTop + subgoal.height()
      lowerInsertTop = subgoalBottom - insertWidth / 2
      lowerInsertBottom = subgoalBottom + insertWidth / 2
      if lowerInsertTop <= mouseY <= lowerInsertBottom
        return {} =
          over: card.attr 'id'
          index: index + 1

      if subgoalTop <= mouseY <= subgoalBottom
        return {} =
          over: subgoal.attr 'id'
          index: null

      index++

  removePlaceholders = ->
    $('#drag-placeholder').remove()
    $('.nesting-hover').removeClass('nesting-hover')

  (event) ->
    if draggingActive
      mouseY = event.pageY
      newPosition = getCurrentPosition mouseY
      if not newPosition?
        removePlaceholders()
      else
        if not _.isEqual newPosition, draggingPosition
          console.log(newPosition)
          removePlaceholders()
          draggingPosition = newPosition
          newParent = $('#' + draggingPosition.over)
          if newParent.hasClass('goal-card')
            placeholder = '<tr id="drag-placeholder"><td class="menu-cell"></td><td>Placeholder title</td></tr>'
            if draggingPosition.index > 0
              rowBefore = $(newParent.find('.subgoal-row')[draggingPosition.index - 1])
              rowBefore.after(placeholder)
            else
              newParent.find('tbody').prepend(placeholder)
          else
            newParent.addClass('nesting-hover')


share.setCardDragging = (card) ->
  card = $(card)

  title = card.find('.header a')
  subgoalRows = card.find('.subgoal-row')

  moveInsideCardHandler = moveInsideCardHandlerFactory card

  title.on 'mousedown', ->
    draggingElement =
      id: title.attr('id')
      title: title.text()
      isTile: true
      priorIndex: null
    $(window).on 'mousemove', enableDragging

  subgoalRows.each (index, subgoalRow) ->
    subgoalRow = $(subgoalRow)
    subgoalTitle = subgoalRow.find('.subgoal-title')
    subgoalTitle.on 'mousedown', ->
      draggingElement =
        id: subgoalRow.attr('id')
        title: subgoalTitle.text()
        isTile: false
        priorIndex: null
      $(window).on 'mousemove', enableDragging
