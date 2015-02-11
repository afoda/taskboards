Router.configure layoutTemplate: 'base_layout'


Router.route '/', ->
  topLevelGoals = Goals.find({parent: {$exists: false}})
  this.render 'goal_list', data: {goals: topLevelGoals}


Router.route '/goal/:_id', ->

    goal = Goals.findOne {_id: @params._id}

    if goal?
      data = goal: goal
      data.goal.subGoals = Goals.find {parent: data.goal._id}
      if data.goal.parent?
        data.parent = Goals.findOne {_id: data.goal.parent}
        data.parent.subGoals = Goals.find {parent: data.parent._id}
        if data.parent.parent?
          data.grandparent = Goals.findOne {_id: data.parent.parent}
          data.grandparent.subGoals = Goals.find {parent: data.grandparent._id}

      data.breadcrumb = [Goals.findOne {_id: @params._id}]
      while data.breadcrumb[0].parent?
        data.breadcrumb.unshift Goals.findOne {_id: data.breadcrumb[0].parent}

    else
      this.redirect '/'

    this.render 'goal_tree', data: data
  ,
  name: 'goal'
