Session.setDefault "HomeHideComplete", false


share.homeHideComplete = ->
  Session.get "HomeHideComplete"

share.toggleHomeHideComplete = ->
  homeHideComplete = share.homeHideComplete()
  Session.set "HomeHideComplete", !homeHideComplete
