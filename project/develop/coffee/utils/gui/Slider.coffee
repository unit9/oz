class Slider extends Abstract

    className   : "slider"
    tagName     : "div"

    foreground  : null
    hit         : null
    progress    : null
    handler     : null

    assetID     : null

    dragging    : false
    mouseCoord  : {}

    percent     : 0

    initialize: (_assetID) =>

        @assetID = _assetID

        super()

        null

    init: =>

        # Foreground
        @foreground = $("<div class='foreground'></div>")
        @$el.prepend @foreground

        # Progress
        @progress = $("<div class='progress'></div>")
        @$el.append @progress
        
        # Hit
        @hit = $("<div class='hit'></div>")
        @$el.append @hit

        # Handler
        @handler = new SSAsset "interface", @assetID
        @handler.$el.addClass "handler"
        @addChild @handler

        @hit.bind "mousedown", @onMouseDown
        $(document).bind "mousemove", @onMouseMove
        null

    onMouseMove: (e) =>

        @mouseCoord.x = Math.round e.pageX
        @mouseCoord.y = Math.round e.pageY

        null

    onMouseDown : (e) =>

        $("body").bind "mouseup", @onMouseUp
        @dragging = true

        null

    onMouseUp: (e) =>

        $("body").unbind "mouseup"
        @dragging = false

        null

    onEnterFrame: =>

        if @dragging

            position = Math.round(@mouseCoord.x - @hit.offset().left)
            position = if position > 0 then position else 0
            @updateGUI position

        null

    updateProgress: (position) =>

        @percent = Math.round position * 100 / @hit.width()
        @trigger "SLIDER_CHANGED", @percent

        null

    setProgress: (percent) =>

        position = Math.round percent * @hit.width() / 100
        @updateGUI position
        null

    updateGUI: (position) =>

        position = if position > @hit.width() then @hit.width() else position
        @progress.css { width: "#{ position }px" }

        handlerPosition = position - (@handler.$el.width() / 2) - 4
        handlerPosition = if handlerPosition < 0 then 0 else handlerPosition
        @handler.$el.css { left: "#{ handlerPosition }px" }

        @updateProgress position

        null

    enabled: ( state ) =>

        if state
            @$el.css { "pointer-events" : "auto" }
            @hit.bind "mousedown", @onMouseDown
            @$el.stop().animate { opacity: 1 }
        else
            @$el.css { "pointer-events" : "none" }
            @hit.unbind "mousedown", @onMouseDown
            @$el.stop().animate { opacity: 0.5 }

        null

    dispose: =>

        $(document).unbind "mousemove", @onMouseMove
        @hit.unbind "mousedown", @onMouseDown

        null