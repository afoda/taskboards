Template.goal_menu.helpers
  subgoals: ->
    Goals.find {parentId: this.goal._id}, {sort: index: 1}

Template.goal_menu.events
  'click .zoom-menu-item': ->
    if not $(event.target).closest("#zoom-menu-item-submenu").length
      Router.go 'goal', {_id: this.goal.parentId}, {hash: this.goal._id}
