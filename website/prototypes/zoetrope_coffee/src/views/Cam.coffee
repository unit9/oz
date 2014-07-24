class Cam

    video           : null
    stream          : null
    filters         : ["grayscale", "sepia", "brightness", "contrast", "hue-rotate", "hue-rotate2", "hue-rotate3", "saturate", "invert", ""]
    currentFilter   : 0

    constructor: ->

        console.log "* Cam App"

        @video = $('video')[0]

        @currentFilter = @filters.length

        @getUserMedia()

# -----------------------------------------------------
# Initiate / Stop the webcam
# -----------------------------------------------------

    getUserMedia: =>

        navigator.getUserMedia {audio:true, video:true}, @onUserMediaSuccess, @onUserMediaError

    stop: =>

        @video.pause()
        @video.src = ""

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
        event = document.createEvent "Event"
        event.initEvent "webcamLoaded", true, true
        window.dispatchEvent event

# -----------------------------------------------------
# CSS Filters over the video
# -----------------------------------------------------

    changeFilter: =>
        @video.className = ""

        @currentFilter++

        if @currentFilter >= @filters.length
            @currentFilter = 0

        effect = @filters[ @currentFilter ]

        if effect
            console.log effect
            @video.classList.add effect

# -----------------------------------------------------
# Return the current frame of the webcam streaming feed
# -----------------------------------------------------

    snapshot: ( canvas, x ) =>
        canvas.getContext("2d").drawImage @video, x, 12, 100, 75
