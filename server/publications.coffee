Meteor.publish "Goals", ->
  if this.userId? then Goals.find userId: this.userId else []
