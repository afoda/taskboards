Router.route '/', ->
  topLevelGoals = Goals.find({parent: {$exists: false}})
  this.layout 'base_layout'
  this.render 'goal_list', data: {goals: topLevelGoals}


Router.route '/goal/:_id', ->
    goal = Goals.findOne {_id: @params._id}
    if goal?
      data = goal: goal
      if goal.parent?
        data.parent = Goals.findOne {_id: goal.parent}
      data.goal.subGoals = Goals.find {parent: @params._id}
      data.breadcrumb = [Goals.findOne {_id: @params._id}]
      while data.breadcrumb[0].parent?
        data.breadcrumb.unshift Goals.findOne {_id: data.breadcrumb[0].parent}
      this.layout 'base_layout', data: data
      this.render 'goal_tree', data: data
    else
      this.redirect '/'
  ,
  name: 'goal'
