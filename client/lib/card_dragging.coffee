share.setCardDragging = (card) ->
  card = $(card)
  card.draggable
    handle: '.header'
    helper: ->
      title = $(this).find('.header').text()
      "<div class='card-drag-placeholder'>" + title + "</div>"
    revert: true
    revertDuration: 0
    connectToSortable: '.goal-card tbody'
  card.find('tbody').sortable
    placeholder: "checklist-placeholder"
    handle: ".subgoal-title"
    update: (event, ui) ->
      dropped = ui.item.closest('.goal-card').attr('id')
      dragged = ui.item.attr('id')
      prev = ui.item.prev().attr('id')
      Meteor.call "changePosition", dragged, dropped, prev
    connectWith: '.goal-card tbody'
