class Zoetrope

    constructor: ->

        console.log "* Init Zoetrope Viewer"

        @enableMouse()
        @loop()

    render: =>

        console.log 'render'

        currentTransform = new WebKitCSSMatrix window.getComputedStyle($(".wrapper")[0]).webkitTransform
        scale = (window.mouseYPos / $(window).height()) + 1
        scale = Math.min(1.5, scale)


        document.querySelector(".wrapper").style[ Modernizr.prefixed("transform") ] = "scale(#{scale})"

    # -----------------------------------------------------
    # Track mouse position
    # -----------------------------------------------------

    enableMouse: =>

        $(window).mousemove (e) ->
            window.mouseXPos = e.pageX
            window.mouseYPos = e.pageY

    loop: =>
        
        requestAnimFrame @loop
        @render()

# -----------------------------------------------------
# Animation
# -----------------------------------------------------

window.requestAnimFrame = ( ->
    window.requestAnimationFrame ||
    window.webkitRequestAnimationFrame ||
    window.mozRequestAnimationFrame ||
    window.oRequestAnimationFrame ||
    window.msRequestAnimationFrame ||
    (callback) ->
        window.setTimeout callback, 1000 / 60)()

