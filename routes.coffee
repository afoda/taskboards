Router.configure layoutTemplate: 'base_layout'


Router.route '/', ->
  topLevelGoals = Goals.find({parent: {$exists: false}})
  this.render 'goal_list', data: {goals: topLevelGoals}
