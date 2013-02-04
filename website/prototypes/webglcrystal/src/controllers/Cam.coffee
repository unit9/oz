class Cam

    video           : null # DOM Element
    canvas          : null # DOM Element of the debug canvas
    canvasContext   : null
    stream          : null

    debugMode       : false

    constructor: ( camDomElement, debug ) ->

        console.log "* Cam Initiated"

        @video = camDomElement
        @debug debug

# -----------------------------------------------------
# Initiate / Stop the webcam
# -----------------------------------------------------

    start: =>

        @getUserMedia()

    stop: =>

        @video.pause()
        @video.src = ""

    getUserMedia: =>

        navigator.getUserMedia { video:true }, @onUserMediaSuccess, @onUserMediaError
        

# -----------------------------------------------------
# Callback from the streaming
# -----------------------------------------------------

    onUserMediaSuccess: (stream) =>

        @stream = stream
        @video.src = window.URL.createObjectURL(@stream)

        this.video.addEventListener "loadedmetadata", @onMetaDataLoaded

    onUserMediaError: (error) =>

        console.error "Failed to get access to local media. Error code was " + error.code

    onMetaDataLoaded: (e) =>

        console.log "* Cam Ready"

        # Add a debug canvas
        @addDebugCanvas()

        # Dispatch event claiming cam is ready
        $( this ).trigger("camReady");

# -----------------------------------------------------
# Setup video
# -----------------------------------------------------

    flip: =>

        $( @video ).css({
            "-moz-transform"    : "scaleX(-1)",
            "-webkit-transform" : "scaleX(-1)",
            "-o-transform"      : "scaleX(-1)",
            "transform"         : "scaleX(-1)",
            "-ms-filter"        : "fliph",
            "filter"            : "fliph"
        });

    scaleTo: ( scale ) =>

        $( @video ).css({
            "-moz-transform"    : "scale(#{ scale })",
            "-webkit-transform" : "scale(#{ scale })",
            "-o-transform"      : "scale(#{ scale })",
            "transform"         : "scale(#{ scale })"
        });

# -----------------------------------------------------
# Canvas debug
# -----------------------------------------------------

    debug: ( mode ) =>

        @debugMode = mode

        visibility = if mode then "visible" else "hidden"

        $( @video ).parent().css { "visibility" : "#{ visibility }" }


    addDebugCanvas: =>

        # Add canvas with the same size of the video
        $( @video ).parent().append "<canvas id='videoDebug' width='#{$( @video ).width()}' height='#{$( @video ).height()}'></canvas>"

        # Set the DOM Element variable
        @canvas         = document.getElementById "videoDebug"
        @canvasContext  = @canvas.getContext "2d"

        # Flip context horizontally
        @canvasContext.translate @canvas.width / 2, @canvas.height / 2
        @canvasContext.scale -1, 1

        # Set the canvas with an initial color / dimension
        @canvasContext.fillStyle = "#000000"
        @canvasContext.fillRect -@canvas.width / 2, -@canvas.height / 2, @canvas.width, @canvas.height

        # CSS the canvas
        $( @canvas ).css { "position" : "absolute", "top" : "#{$( @video ).height()}px" }

    snapshot: =>

        # FYOU - INDEX_SIZE_ERR: DOM Exception 1
        try

            if @video.readyState is @video.HAVE_ENOUGH_DATA
                @canvasContext.drawImage @video, - @canvas.width / 2, - @canvas.height / 2, @canvas.width, @canvas.height

        catch e

           # console.log e
        
        

# -----------------------------------------------------
# Render
# -----------------------------------------------------
    
    render: =>

        @snapshot()
    
    startRender: =>

        requestAnimationFrame @startRender
        @render()      
