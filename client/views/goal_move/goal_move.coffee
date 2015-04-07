Template.body.events
  'click .goal-move-button': (event, data, template) ->
    Session.set('movingGoal', data._id)
    $('.goal-move-modal').modal('show')

Template.goal_move_modal.helpers
  movingGoal: -> Goals.findOne Session.get('movingGoal')
  mostRecentGoals: (count) ->
    Goals.find {}, {sort: ["createdAt"], limit: count}

Template.goal_move_modal.rendered = ->
  $('.goal-move-modal').modal('setting', 'closable', false)
  $('.goal-move-modal .ui.dropdown').dropdown()
