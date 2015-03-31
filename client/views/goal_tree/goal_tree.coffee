Template.goal_tree.events

  'click #add-goal-button, keypress #new-goal-title': (event, template) ->
    if event.type == "click" || event.type == "keypress" && event.which == 13
      titleInput = template.find "#new-goal-title"
      share.createGoal titleInput.value, this.goal._id
      titleInput.value = ""


Template.registerHelper "isContext", (parentContext) -> this._id == parentContext.goal._id


Template.goal_tree.helpers

  chainLengthGte: (n) -> this.breadcrumb.length >= n

  toplevel: -> if this.breadcrumb.length >= 3 then this.breadcrumb[0] else null
  parent: -> if this.breadcrumb.length >= 2 then this.breadcrumb[this.breadcrumb.length - 2] else null
  context: -> this.breadcrumb[this.breadcrumb.length - 1]


Template.goal_tree.rendered = ->
  if window.location.hash.length > 1
    goalCard = $(window.location.hash)
    if goalCard.length > 0
      h = goalCard.height()
      w = $(window).height()
      t = goalCard.offset().top
      m = $(".fixed.menu").height()
      scrollDist = if h < w then t - m - (w - m - h) / 2 else t - m - 3
      pulseFun = ->
        goalCard.transition('pulse')
      $('html, body')
        .animate({scrollTop: scrollDist}, 'slow')
        .promise()
        .done(-> goalCard.transition('pulse'))
