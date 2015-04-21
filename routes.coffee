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
      data.breadcrumb = [data.parent]
      last = (arr) -> arr[arr.length - 1]
      while last(data.breadcrumb).parentId?
        data.breadcrumb.push Goals.findOne {_id: last(data.breadcrumb).parentId}

    this.layout 'base_layout', data: data
    this.render 'goal_tree', data: data
  ,
  name: 'goal'
