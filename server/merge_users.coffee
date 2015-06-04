Accounts.onCreateUser (options, user) ->
  guestUser = Meteor.user()
  if guestUser?.profile?.guest == true
    Goals.update {userId: guestUser._id}, {$set: {userId: user._id}}, {multi: true}
  if options.profile?
    user.profile = options.profile
  user
