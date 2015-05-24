draggingActive = false
draggingElement = null # id, title, isTile, priorIndex
draggingPosition = null # over, index


enableDragging = ->
  if !draggingActive
    console.log("dragging enabled")
    $(window).on 'mousemove', updateDragHelper

    helper = $('#drag-helper')
    helper.text(draggingElement.title)
    helper.show()

    $('.goal-card').each (index, card) ->
      $(card).on "mouseenter", setupCardDragging
      $(card).on "mouseleave", tearDownCardDragging

    draggingActive = true

finishDragging = ->
  console.log("finish dragging called")
  if draggingActive
    $(window).off 'mousemove', updateDragHelper

    $('.goal-card').each (index, card) ->
      $(card).off "mouseenter", setupCardDragging
      $(card).off "mouseleave", tearDownCardDragging

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


addDraggingHover = -> $(this).addClass 'dragging-hover'
removeDraggingHover = -> $(this).removeClass 'dragging-hover'

setupCardDragging = ->
  card = $(this)
  console.log("setupCardDragging called")
  subgoalRows = card.find('.subgoal-row')
  card.find('tbody').addClass 'dragging'

  subgoalRows.before (index) ->
    '<tr class="drag-placeholder" data-index=#{index}><td class="menu-cell"></td><td></td></tr>'
  card.find('tbody').append ->
    '<tr class="drag-placeholder" data-index=#{subgoalRows.length}><td class="menu-cell"></td><td></td></tr>'

  card.find('.drag-placeholder, .subgoal-row').on 'mouseenter', addDraggingHover
  card.find('.drag-placeholder, .subgoal-row').on 'mouseleave', removeDraggingHover



tearDownCardDragging = ->
  console.log("tearDownCardDragging called")
  card = $(this)
  card.find('.drag-placeholder').remove()
  card.find('.subgoal-row').off 'mouseenter', addDraggingHover
  card.find('.subgoal-row').off 'mouseleave', removeDraggingHover
  card.find('tbody').removeClass 'dragging'


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
