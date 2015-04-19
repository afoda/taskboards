Router.route '/', ->
  this.layout 'base_layout', data: {}
  this.render 'goal_tree', data: {}


Router.route '/goal/:_id', ->
    goal = Goals.findOne {_id: @params._id}
    if !goal
      this.redirect '/'
      return

    data = goal: goal
    if goal.parentId?
      data.parent = Goals.findOne {_id: goal.parentId}
    data.breadcrumb = [Goals.findOne {_id: @params._id}]
    while data.breadcrumb[0].parentId?
      data.breadcrumb.unshift Goals.findOne {_id: data.breadcrumb[0].parentId}
    this.layout 'base_layout', data: data
    this.render 'goal_tree', data: data
  ,
  name: 'goal'
