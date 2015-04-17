Router.route '/', ->
  topLevelGoals = Goals.find $or: [{parentId: {$exists: false}}, {parentId: null}]
  this.layout 'base_layout'
  this.render 'goal_list', data: {goals: topLevelGoals}


Router.route '/goal/:_id', ->
    data = Goals.findOne {_id: @params._id}
    if !data
      this.redirect '/'
      return

    if data.parentId?
      data.parent = Goals.findOne {_id: data.parentId}
    data.breadcrumb = [Goals.findOne {_id: @params._id}]
    while data.breadcrumb[0].parentId?
      data.breadcrumb.unshift Goals.findOne {_id: data.breadcrumb[0].parentId}
    this.layout 'base_layout', data: data
    this.render 'goal_tree', data: data
  ,
  name: 'goal'
