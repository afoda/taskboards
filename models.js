// goal: {
//   complete: bool
//   subgoals: [{goal object}]
//   (archived): bool
//   (active): bool
//   (time_intervals): [[date, date]]
// }

Goals = new Mongo.Collection("goals")
