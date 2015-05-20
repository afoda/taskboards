addAllSteps = (tour) ->

  nextButton = text: 'Next', action: tour.next
  exitButton = text: 'Exit', action: tour.cancel

  tour.addStep 'createTask',
    attachTo: '.new-card-placeholder right'
    text: 'Tasks are represented by tiles like this one. Enter a task into this tile and hit enter to save it.'
    buttons: [ ]

  tour.addStep 'createSubtask',
    attachTo: '.tour-new-tile right'
    text: 'Each tile contains a list of subtasks. Create some subtasks by typing their titles and then pressing Enter. <br /><br /> You can continue adding subtasks at any time by double-clicking on the tile.'
    buttons: [ ]

  tour.addStep 'stopCreatingSubtasks',
    attachTo: '.tour-new-tile right'
    text: 'Click out of the input to finish adding subtasks. <br /><br /> You can continue adding subtasks at any time by double-clicking on the tile.'
    buttons: [ ]

  tour.addStep 'zoomingIn',
    attachTo: '.tour-new-tile right'
    text: 'You can zoom in on any tile to reveal another board just like this one. Click on the heading of a subtask to zoom in one level.'
    buttons: [ ]

  tour.addStep 'nestedBoards',
    text: 'This board shows a detailed view of your new task. You can add subtasks to each tile, and zoom in on the tiles on this board &mdash; there\'s no limit to how deeply you can break down a task.'

  tour.addStep 'activateTask',
    attachTo: '.goal-card left'
    text: 'When you want to work on a task, activate it by selecting <em>Activate</em> from its context menu. You can bring up the context menu by hovering over the list bullet for subtasks, or the top right corner for a tile. <br /><br /> Activate a task to continue.'
    buttons: [ ]

  tour.addStep 'activateTaskMenuItem',
    attachTo: '#active-goal-box bottom'
    text: 'When you activate a task, its name appears in the menu so you can immediately navigate to its board from anywhere in the task hierarchy.'

  tour.addStep 'goalTimer',
    attachTo: '#goal-timer bottom'
    text: 'Activating a task also starts the goal timer, which shows how long you have been working on that task.'

  tour.addStep 'goalTimer2',
    attachTo: '#goal-timer bottom'
    text: 'The goal timer gives a sense of how efficiently you are moving through tasks. It starts off green, and gradually transitions to red over a 30 minute period. <br /><br /> When the goal timer starts showing red, you should consider breaking your task down into smaller pieces.'

  tour.addStep 'accounts',
    attachTo: '#login-buttons-item bottom'
    text: 'You can create a user account at any time, and your work in progress will be saved to your new account.'

  tour.addStep 'moreFeatures',
    text: 'There are more features for you to explore as you go. <br /><br /> Try drag-and-drop to reorganise tasks, and look around the context menus to see what else is possible.'

  tour.addStep 'done',
    text: 'You\'re done with the tour! We hope you enjoy using TaskBoards.'
    buttons: [ exitButton ]


share.currentStep = -> Shepherd.activeTour?.getCurrentStep()
share.currentStepId = -> share.currentStep()?.id
share.onStep = (id) -> id == share.currentStepId()
share.stopTour = -> Shepherd.activeTour?.cancel()


share.startTour = ->
  share.stopTour()

  tour = new Shepherd.Tour
    defaults:
      classes: 'shepherd-theme-dark'
      showCancelLink: true
      scrollTo: true

  addAllSteps tour

  destroyAllSteps = ->
    _.each tour.steps, (step) -> step.destroy()
  tour.on('cancel', destroyAllSteps)
  tour.on('complete', destroyAllSteps)

  share.tour = tour
  tour.start()

  # Save the task id where the tour was started (or null at the top level).
  templateGoal = Template.currentData().goal
  tourStartTaskId = if templateGoal? then templateGoal._id else null
  Session.setPersistent "TourStartTaskId", tourStartTaskId


Meteor.startup ->

  # createTask: advance on creating a new tile
  Goals.after.insert (userId, doc) ->
    if share.onStep 'createTask'
      if Session.equals "TourStartTaskId", doc.parentId
        Session.setPersistent "TourNewTaskId", doc._id
        Tracker.afterFlush -> share.tour.next()

  # createSubtask: advance on creating a subtask of the newly-created task
  Goals.after.insert (userId, doc) ->
    if share.onStep 'createSubtask'
      if Session.equals "TourNewTaskId", doc.parentId
        Tracker.afterFlush -> share.tour.next()


Template.goal_card.helpers
  isTourNewTile: -> Session.equals "TourNewTaskId", @goal._id

Template.goal_card.events
  'blur .new-subgoal-title': ->
    if share.onStep 'stopCreatingSubtasks'
      Tracker.afterFlush -> share.tour.next()

# activateTask: goal activation triggers a call to this function
share.signalGoalActivated = ->
  if share.onStep 'activateTask'
    if share.activeGoalId()?
      Tracker.afterFlush -> share.tour.next()


Router.onRun ->
  switch share.currentStepId()
    when "zoomingIn"
      # When landing on a board without tiles, close tour gracefully
      landingOnId = Router.current().params._id
      if Goals.findOne {"parentId": landingOnId}
        Tracker.afterFlush -> share.tour.next()
      else
        share.stopTour()
    else
      share.stopTour()
  this.next()
