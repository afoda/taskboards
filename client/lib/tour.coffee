tourSteps = [
    element: '.new-card-placeholder'
    intro: 'Tasks are represented by tiles like this one. Enter a task into this tile and hit enter to save it.'
  ,
    element: '.tour-new-tile'
    intro: 'Each tile contains a list of subtasks. Create some subtasks by typing their titles and then pressing Enter. <br /><br /> You can continue adding subtasks at any time by double-clicking on the tile.'
  ,
    element: '.tour-new-tile'
    intro: 'Click out of the input to finish adding subtasks. <br /><br /> You can continue adding subtasks at any time by double-clicking on the tile.'
  ,
    element: '.tour-new-tile'
    intro: 'You can zoom in on any tile to reveal another board just like this one. Click on the heading of a subtask to zoom in one level.'
  ,
    intro: 'This board shows a detailed view of your new task. You can add subtasks to each tile, and zoom in on the tiles on this board &mdash; there\'s no limit to how deeply you can break down a task.'
  ,
    element: '.goal-card'
    advanceOn: '.goal-active-toggle click'
    intro: 'When you want to work on a task, activate it by selecting <em>Activate</em> from its context menu. You can bring up the context menu by hovering over the list bullet for subtasks, or the top right corner for a tile. <br /><br /> Activate a task to continue.'
  ,
    element: '#active-goal-box'
    intro: 'When you activate a task, its name appears in the menu so you can immediately navigate to its board from anywhere in the task hierarchy.'
  ,
    element: '#goal-timer'
    intro: 'Activating a task also starts the goal timer, which shows how long you have been working on that task.'
  ,
    element: '#goal-timer'
    intro: 'The goal timer gives a sense of how efficiently you are moving through tasks. <br /><br /> It starts off green, and gradually transitions to red over a 30 minute period. <br /><br /> When the goal timer starts showing red, you should consider breaking your task down into smaller pieces.'
  ,
    element: '#login-buttons-item'
    intro: 'You can create a user account at any time, and your work in progress will be saved to your new account.'
  ,
    intro: 'There are many other features for you to explore as you go. <br /><br /> The ability to re-organise tasks is provided by drag-and-drop. Look around the context menus of the <br /><br /> Explore these abilities by dragging tiles and subtasks by their headings, and look around their context menus to see what\'s possible.'
  ,
    intro: 'You\'re done with the tour! We hope you enjoy using TaskBoards.'
]


share.startTour = ->
  tour = introJs()
  tour.setOptions
    steps: tourSteps
    tooltipPosition: 'auto'
    showStepNumbers: false
    disableInteraction: false

  # Save the task id where the tour was started (or null at the top level).
  templateGoal = Template.currentData().goal
  tourStartTaskId = if templateGoal? then templateGoal._id else null
  Session.setPersistent "TourStartTaskId", tourStartTaskId

  tour.start()
  share.tour = tour


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

Router.onAfterAction ->
  step = share.currentStep()
  if step?
    switch step.id
      when "zoomingIn"
        Tracker.afterFlush -> share.tour.next()
      else
        share.stopTour()
