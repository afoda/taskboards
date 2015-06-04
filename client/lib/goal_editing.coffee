share.clearEditingCard = ->
  Session.set 'EditingCard', null

share.setEditingCard = (_id) ->
  Session.set 'EditingCard', _id

share.editingCardId = ->
  Session.get 'EditingCard'

share.setCreatedCardEditing = (err, _id) ->
  if not err
    share.setEditingCard _id
