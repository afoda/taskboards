Router.configure
  waitOn: -> Meteor.subscribe("Goals")
  loadingTemplate: "loading"


Router.route "/",
  name: "home"
  data: -> {}
  action: ->
    document.title = "#{share.siteName}: Home"
    this.render 'goal_tree'


Router.route "/goal/:_id",
  name: "goal"
  data: ->
    goal = Goals.findOne {_id: @params._id}
    return {} if !goal?
    data = goal: goal
    if goal.parentId?
      data.parent = Goals.findOne {_id: goal.parentId}
      data.breadcrumb = [data.parent]
      last = (arr) -> arr[arr.length - 1]
      while last(data.breadcrumb).parentId?
        data.breadcrumb.push Goals.findOne {_id: last(data.breadcrumb).parentId}
    data
  action: ->
    data = @data()
    if data.goal?
      document.title = "#{share.siteName}: #{data.goal.title}"
      this.render 'goal_tree'
    else
      document.title = "#{share.siteName}: Home"
      this.render 'goal_tree'
  onAfterAction: ->
    if Meteor.isClient
      $(window).scrollTop 0
      hash = @params.hash
      if hash
        Tracker.afterFlush ->
          share.scrollAndHighlight hash
