Router.route '/', ->
  this.render 'goal_tree', data: {}
  document.title = "#{share.siteName}: Home"


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

    this.render 'goal_tree', data: data
    document.title = "#{share.siteName}: #{goal.title}"
  ,
  name: 'goal'
