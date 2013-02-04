$ ->
    window.view = {}

    window.enterFrame = ->
        window.requestAnimationFrame window.enterFrame
        window.view.enterFrame()

    $(document).ready ->
        window.view = new AppView
        enterFrame()
