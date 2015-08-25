share.scrollAndHighlight = (hash) ->
  card = $("#" + hash)
  headerLink = card.find(".header a")
  h = card.height()
  w = $(window).height()
  t = card.offset()?.top
  m = $(".fixed.menu").height()
  scrollTop = if h < w then t - m - (w - m - h) / 2 else t - m - 3
  $("html, body")
    .animate scrollTop: scrollTop, 'slow'
    .promise()
    .done ->
      if hash != share.activeGoalId()
        headerLink.addClass 'highlight'
        window.setTimeout (-> headerLink.removeClass 'highlight'), 500
