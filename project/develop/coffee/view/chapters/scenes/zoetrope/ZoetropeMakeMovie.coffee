class ZoetropeMakeMovie extends Abstract

    id          : "makemovie"
    container   : null
    controls    : null
    flourish    : null
    webcamfeed  : null
    navContainer: null
    record      : null
    tryagain    : null
    preview     : null
    timeline    : null
    recording   : false

    bright      : null
    contrast    : null

    camera     : null

    header : null
    headerFlourish : null
    bottom : null
    bottomFlourish : null
    countdown : null

    done : null
    share : null
    rep : null
    data : null
    scale : null
    img : null
    canvasTexture : null
    ctxTexture : null
    canvasRef : null
    ctxRef : null

    line : null
    col : null
    imgData : null

    w : null
    h : null
    
    initialize : (_camera) =>

        @scale = 128 / 600
        @camera = _camera
        super()
        null

    init: () =>

        # Container
        @container = new Abstract().setElement "<div class='zoetropeContainer'></div>"
        @container.dispose = () -> null
        @addChild @container

        # Header
        @header = new Abstract().setElement "<div class='zoeheader'></div>"
        @header.dispose = () -> null
        @container.addChild @header
        @headerFlourish = new SSAsset "interface", "zoe_top"
        @header.addChild @headerFlourish

        # Webcam feed
        @webcamfeed = new ZoetropeWebcamFeed @camera
        @container.addChild @webcamfeed

        # Bottom
        @bottom = new Abstract().setElement "<div class='zoebottom'></div>"
        @bottom.dispose = () -> null
        @bottomFlourish = new SSAsset "interface", "zoe_bottom"

        @bottomFlourish.$el.css
            "background-position-y" : "#{parseInt(@bottomFlourish.$el.css("background-position-y")) + 1}px"
            "height"                : "#{parseInt(@bottomFlourish.$el.css("height")) + 1}px"

        @bottom.addChild @bottomFlourish

        @countdown = new ZoetropeCountDown
        @bottom.addChild @countdown

        # Timeline
        @timeline = new ZoetropeTimeline @webcamfeed.canvas, @webcamfeed.player
        @timeline.on "REPLACE_THUMB", @recordOneFrame
        @container.addChild @timeline

        @container.addChild @bottom

        # Nav Container
        @navContainer = new Abstract().setElement "<div class='navContainer'></div>"
        @navContainer.dispose = () -> null
        @navContainer.hide()
        @addChild @navContainer

        @addButtons()

        # Transition
        @$el.css 
            "margin-top": "-20px"
            "display": "inline-block"
            "position": "relative"
            "z-index": 5
            "opacity": 0

        @$el.animate {opacity: 1}, 800, 'linear'
        null

    updateSettings: (value) =>
        @webcamfeed.setBrightness @bright.percent
        @webcamfeed.setContrast @contrast.percent
        null

    start: =>
        @record.enable()
        null

    toogleRecord: =>

        if !@recording
            @startRecord()
        else
            @stopRecord()
            @timeline.clear()

        null

    onDone: =>
        @oz().appView.subArea.onClose()
        null

    startRecord: =>

        Analytics.track 'zoe_click_record'

        SoundController.send "zoetrope_recording_start"

        # Flag
        @recording = true

        # Change the button to STOP status
        @record.changeLabel "<span class='red'>&#149;</span> #{@oz().locale.get('zoetrope_stop_recording')}"

        # Enable COUNTDOWN
        @countdown.on "COUNTDOWN_COMPLETE", @onCountdownComplete
        @countdown.startCountDown()

        null

    onCountdownComplete : =>

        # Stop countdown
        @countdown.stopCountDown()

        # Timeline SNAP PHOTO
        @timeline.addFrame()

        # After 1 second init countdown again
        if @timeline.currentFrame < @timeline.numberOfPictures
            @rep = setTimeout @countdown.startCountDown, 1000
        else
            @completed()

        null

    pause: =>

        if @recording

            clearInterval @rep

            # stop COUNTDOWN
            @countdown.stopCountDown()
            @countdown.off "COUNTDOWN_COMPLETE", @onCountdownComplete

            @recording = false

        super()

        null

    resume: =>

        # if @timeline.currentFrame > 0 so the zoetrope was recording
        if @timeline.currentFrame > 0

            @recording = true
            
            # Enable COUNTDOWN
            @countdown.on "COUNTDOWN_COMPLETE", @onCountdownComplete
            @countdown.startCountDown()

        super()

        null

    stopRecord: =>

        Analytics.track 'zoe_stop_record'

        SoundController.send "zoetrope_recording_stop"

        clearInterval @rep
        
        # stop COUNTDOWN
        @countdown.stopCountDown()
        @countdown.off "COUNTDOWN_COMPLETE", @onCountdownComplete

        @recording = false
        @record.changeLabel "<span>&#149;</span> #{@oz().locale.get('zoetrope_start_recording')}"
        @timeline.stop()

        null

    completed: =>

        @stopRecord()

        @record.off "click"
        @record.on "click", @goTryAgain
        @share.enable()
        @done.enable()

        # Hide progress bar
        @timeline.setStatus "end"
        @webcamfeed.player.showAndPlay @timeline.canvas

        @get3DTexture()

        null

    recordOneFrame: (frame) =>

        Analytics.track 'zoe_replace_image'

        # Start countdown
        @countdown.on "COUNTDOWN_COMPLETE", =>
            @recordFrame frame
        @countdown.startCountDown()

        # Stop player and hide it
        @webcamfeed.player.stopIt()
        @webcamfeed.player.hide true

        # Disable buttons until the new photo is taken
        @done.disable()
        @share.disable()

        # Disable timeline
        @timeline.disableThumbs()
        @timeline.$el.css { "pointer-events" : "none" }

        null

    recordFrame: (frame) =>

        # Restore timeline
        @timeline.$el.css { "pointer-events" : "auto" }
        @timeline.enableThumbs()

        @countdown.off "COUNTDOWN_COMPLETE"
        @timeline.shotOnFrame frame

        @webcamfeed.player.showAndPlay @timeline.canvas

        # Enable buttons
        @done.enable()
        @share.enable()

        # Hide overlay on thumb
        @timeline.thumbsArr[frame].onOut()

        @get3DTexture()

        null

    addButtons : =>

        # Done
        @done = new SimpleButton "done", "#{@oz().locale.get('zoetrope_done_button')}"
        @done.on "click", @onDone
        @navContainer.addChild @done
        @done.disable()

        # Record button
        @record = new SimpleButton "record", "<span>&#149;</span> #{@oz().locale.get('zoetrope_start_recording')}"
        @record.on "click", @toogleRecord
        @navContainer.addChild @record

        # Share
        @share = new SimpleButton "share", "#{@oz().locale.get('zoetrope_share_movie')}"
        @share.on "click", @goShare
        @navContainer.addChild @share
        @share.disable()

        # Adjust the buttons to all have the same width
        setTimeout () =>
            w = Math.max @done.$el.width(), @record.$el.width(), @share.$el.width()
            # console.log @done.$el.width(), @record.$el.width(), @share.$el.width()
            @done.$el.width w
            @record.$el.width w
            @share.$el.width w
            @navContainer.show true
        , 300

        null

    goTryAgain : (autostart = true) =>

        Analytics.track 'zoe_create_another'

        @share.disable()
        @done.disable()

        @webcamfeed.player.stopIt()
        @webcamfeed.player.hide true

        @timeline.clear()

        @record.off "click"
        @record.on "click", @toogleRecord
        if autostart then @toogleRecord()

        null

    goShare : =>

        Analytics.track 'zoe_share'

        @share.disable()
        @done.disable()
        @oz().appView.subLoader.show true
        @requestSave()

        null

    requestSave: =>

        @data = @timeline.canvas[0].toDataURL("image/jpeg").slice("data:image/jpeg;base64,".length)

        # Debug
        #window.open @timeline.canvas[0].toDataURL("image/jpeg")

        Requester.addImage @data, "zoetrope", @imageSaved, @fail

        null

    get3DTexture : () =>

        @data = @timeline.canvas[0].toDataURL("image/jpeg")
        
        @img = new Image()
        @img.onload = =>

            @canvasTexture = document.createElement 'canvas'
            @canvasTexture.width = 384
            @canvasTexture.height = 512

            @ctxTexture = @canvasTexture.getContext '2d'

            @canvasRef = document.createElement 'canvas'
            @canvasRef.width = 7200
            @canvasRef.height = 340
            @ctxRef = @canvasRef.getContext '2d'

            @ctxRef.scale(@scale, @scale)
            @ctxRef.drawImage @img, 0, 0

            @line = 0
            @col = 0

            for i in [0...12]
            
                @imgData = @ctxRef.getImageData i * (600 * @scale), 0, 600 * @scale, (340 * @scale)

                @w = @col * (600 * @scale)
                @h = 28 + (128 * @line)

                @ctxTexture.putImageData(@imgData, @w, @h)

                if @col == 2
                    @col = 0
                    @line++
                else 
                    @col++

            @oz().appView.area.updateFilmTexture @canvasTexture

        @img.src = @data

        null


    imageSaved: ( data )=>
        Requester.shortURL((window.location.origin + "/preview/zoe/" + data.result.id), @showShareBox, @fail)
        null

    fail: =>
        @oz().appView.subLoader.showError()
        @trigger 'fail'
        null

    showShareBox : (event) =>
        @oz().appView.subLoader.hide()
        @trigger "SHARE", event.id
        null

    dispose: =>

        @canvasRef = null
        @canvasTexture = null

        @webcamfeed.dispose()

        @webcamfeed.off "COUNTDOWN_COMPLETE"

        # @contrast.off "SLIDER_CHANGED"
        # @brightness.off "SLIDER_CHANGED"

        @timeline.off "COMPLETED"
        @timeline.off "REPLACE_THUMB"

        null
