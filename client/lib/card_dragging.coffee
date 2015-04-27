share.setCardDragging = (_id) ->
  card = $("#" + _id)

  card.draggable
    handle: '.header'
    helper: ->
      title = $(this).find('.header').text()
      "<div class='card-drag-placeholder'>" + title + "</div>"
    revert: true
    revertDuration: 0
  card.droppable
    hoverClass: 'nest-goal-hover'
    accept: (draggable) ->
      not draggable.closest("#" + _id).length
    drop: (event, ui) ->
      dropped = $(this).attr('id')
      dragged = ui.draggable.attr('id')
      Meteor.call "changePosition", dragged, dropped, null

  card.find('.subgoal-row').draggable
    helper: 'clone'
  card.find('.subgoal-row').droppable
    accept: "#" + _id + " .subgoal-row"
    hoverClass: 'nest-goal-hover'
    drop: (event, ui) ->
      dropped = $(this).attr('id')
      dragged = ui.draggable.attr('id')
      Meteor.call "changePosition", dragged, dropped, null
