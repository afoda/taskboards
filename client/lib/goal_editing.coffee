share.clearEditingCard = ->
  Session.set 'EditingCard', null

share.setEditingCard = (_id) ->
  Session.set 'EditingCard', _id

share.editingCardId = ->
  Session.get 'EditingCard'
