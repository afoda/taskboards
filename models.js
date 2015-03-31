// goal: {
//   title: string
//   complete: bool
//   parent: id
//   createdAt: date
//   (archived): bool
//   (active): bool
//   (time_intervals): [[date, date]]
// }

Goals = new Mongo.Collection("goals")
