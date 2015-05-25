draggingActive = false
draggingElement = null # id, title, isTile, priorIndex


enableDragging = ->
  if !draggingActive
    console.log("dragging enabled")
    $(window).one 'mouseup', finishDragging
    $(window).on 'mousemove', updateDragHelper

    helper = $('#drag-helper')
    helper.text(draggingElement.title)
    helper.show()

    $('.goal-card').each (index, card) ->
      $card = $ card
      if $card.attr('id') != draggingElement.id
        $card.on "mouseenter", setupCardDragging
        $card.on "mouseleave", tearDownCardDragging

    draggingActive = true

finishDragging = ->
  console.log("finish dragging called")
  $(window).off 'mousemove', updateDragHelper

  $('.goal-card').each (index, card) ->
    $(card).off "mouseenter", setupCardDragging
    $(card).off "mouseleave", tearDownCardDragging

  draggingActive = false
  $("#drag-helper").hide()


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
  nextSubgoalId = placeholder.next('.subgoal-row').attr('id')
  draggedId = draggingElement.id
  Meteor.call "changePosition", draggedId, newParentId, nextSubgoalId
  (tearDownCardDragging.bind $(@).closest '.goal-card')()

positionInSubgoal = ->
  newParentId = $(this).attr('id')
  draggedId = draggingElement.id
  Meteor.call "changePosition", draggedId, newParentId, null
  (tearDownCardDragging.bind $(@).closest '.goal-card')()


setupCardDragging = ->
  card = $(this)
  console.log("setupCardDragging called")
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
  console.log("tearDownCardDragging called")
  card = $(this)
  card.find('.drag-placeholder').remove()
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
      priorIndex: null
    $(window).one 'mousemove', enableDragging

share.setSubgoalRowDragging = (subgoalRow) ->
  title = subgoalRow.find('.subgoal-title')
  title.on 'mousedown', ->
    draggingElement =
      id: subgoalRow.attr('id')
      title: title.text()
      isTile: false
      priorIndex: null
    $(window).one 'mousemove', enableDragging


Router.onBeforeAction ->
  $(window).off 'mousemove', enableDragging
  draggingElement = null
  this.next()
