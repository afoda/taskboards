draggingActive = false
draggingElement = null # id, title, isTile, priorIndex
draggingPosition = null # over, index


handleDrag = (event) ->
  helper = $('#drag-helper')
  if !draggingActive
    draggingActive = true
    helper.text(draggingElement.title)
    helper.show()
  $('#drag-helper').css
   left:  event.pageX
   top:   event.pageY
  return false

$(window).on 'mouseup', ->
  if draggingActive
    $(window).off 'mousemove', handleDrag
    draggingElement = null
    draggingPosition = null
    draggingActive = false
    $("#drag-helper").hide()


share.setCardDragging = (card) ->
  card = $(card)

  title = card.find('.header a')
  subgoalRows = card.find('.subgoal-row')

  title.on 'mousedown', ->
    draggingElement =
      id: title.attr('id')
      title: title.text()
      isTile: true
      priorIndex: null
    $(window).on 'mousemove', handleDrag

  subgoalRows.each (index, subgoalRow) ->
    subgoalRow = $(subgoalRow)
    subgoalTitle = subgoalRow.find('.subgoal-title')
    subgoalTitle.on 'mousedown', ->
      draggingElement =
        id: subgoalRow.attr('id')
        title: subgoalTitle.text()
        isTile: false
        priorIndex: null
      $(window).on 'mousemove', handleDrag
