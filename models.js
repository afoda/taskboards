// goal: {
//   title: string
//   complete: bool
//   parentId: id
//   createdAt: date
//   userId: string
//   (archived): bool
//   (active): bool
//   (time_intervals): [[date, date]]
// }

Goals = new Mongo.Collection("goals")
