tourSteps = [
    target: '.new-card-placeholder'
    placement: 'right'
    content: 'Tasks are represented by tiles like this one. Enter a task into this tile and hit enter to save it.'
  ,
    target: '.tour-new-tile'
    placement: 'right'
    content: 'Each tile contains a list of subtasks. Create some subtasks by typing their titles and then pressing Enter. <br /><br /> You can continue adding subtasks at any time by double-clicking on the tile.'
  ,
    target: '.tour-new-tile'
    placement: 'right'
    content: 'Click out of the input to finish adding subtasks. <br /><br /> You can continue adding subtasks at any time by double-clicking on the tile.'
  ,
    target: '.tour-new-tile'
    placement: 'right'
    content: 'You can zoom in on any tile to reveal another board just like this one. Click on the heading of a subtask to zoom in one level.'
  ,
    target: 'pop-stack-link'
    placement: 'below'
    content: 'This board shows a detailed view of your new task. You can add subtasks to each tile, and zoom in on the tiles on this board &mdash; there\'s no limit to how
deeply you can break down a task.'
  ,
    target: document.querySelector('.goal-card')
    advanceOn: '.goal-active-toggle click'
    content: 'When you want to work on a task, activate it by selecting <em>Activate</em> from its context menu. You can bring up the context menu by hovering over the lis
 bullet for subtasks, or the top right corner for a tile. <br /><br /> Activate a task to continue.'
  ,
    target: 'active-goal-box'
    content: 'When you activate a task, its name appears in the menu so you can immediately navigate to its board from anywhere in the task hierarchy.'
  ,
    target: 'goal-timer'
    content: 'Activating a task also starts the goal timer, which shows how long you have been working on that task.'
  ,
    target: 'goal-timer'
    content: 'The goal timer gives a sense of how efficiently you are moving through tasks. <br /><br /> It starts off green, and gradually transitions to red over a 30 mi
ute period. <br /><br /> When the goal timer starts showing red, you should consider breaking your task down into smaller pieces.'
  ,
    target: 'login-buttons-item'
    content: 'You can create a user account at any time, and your work in progress will be saved to your new account.'
  ,
    content: 'There are many other features for you to explore as you go. <br /><br /> The ability to re-organise tasks is provided by drag-and-drop. Look around the conte
t menus of the <br /><br /> Explore these abilities by dragging tiles and subtasks by their headings, and look around their context menus to see what\'s possible.'
  ,
    content: 'You\'re done with the tour! We hope you enjoy using TaskBoards.'
]


tour =
  id: "introduction"
  steps: tourSteps
