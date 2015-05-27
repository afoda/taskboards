Router.onRun ->
  $(window).scrollTop 0
  hash = @params.hash
  if hash
    Tracker.afterFlush ->
      element = $("#" + hash)
      h = element.height()
      w = $(window).height()
      t = element.offset()?.top
      m = $(".fixed.menu").height()
      scrollTop = if h < w then t - m - (w - m - h) / 2 else t - m - 3
      $("html, body")
        .animate scrollTop: scrollTop, 'slow'
        .promise()
        .done(-> element.transition 'pulse')
  this.next()
