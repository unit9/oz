class ZoetropeTimeline extends Abstract
    

    className : "timeline"

    # Canvas with the spritesheet
    canvas          : null
    recording       : false

    # Video DOM element from where we get the webcam feed
    webcamfeed      : null
    player          : null
    status          : null

    # Current frame to draw the picture from the webcam feed
    currentFrame    : 0

    # Number of pictures needed to make the Zoetrope
    numberOfPictures: 12

    # Thumbs container
    thumbsArr       : []
    thumbs          : null
    thumbslist      : null
    thumbW          : 44
    thumbH          : 25
    thumbGap        : 6

    # Progress Overlay
    progress        : null

    # Track the click position and id of the thumb to prevent to identify a click when was just dragged
    mouseX          : null
    thumbToReplace  : null


    initialize : ( webcamfeed, player ) =>

        # Canvas of webcam feed
        @webcamfeed = webcamfeed
        @player = player

        super()
        null

    init: () =>

        # Replace Label container
        @label = new ZoetropeReplaceLabel
        @label.$el.css { "height" : @thumbH }
        @addChild @label, true

        # Thumbs container
        @thumbs = new Abstract().setElement "<div class='thumbs'></div>"
        @thumbs.dispose = () -> null
        @thumbs.$el.css { "height" : @thumbH }
        @addChild @thumbs

        # Thumbs list
        @thumbslist = new Abstract().setElement "<div class='list'></div>"
        @thumbslist.dispose = () -> null
        @thumbs.addChild @thumbslist

        # Add all the thumbs
        @thumbsArr = []
        for i in [0...@numberOfPictures]

            thumb = new ZoetropeThumb i, @thumbW, @thumbH, @thumbGap
            
            thumb.on "ON_OVER", @overThumb
            thumb.on "ON_OUT", @outThumb
            thumb.on "ON_MOUSE_DOWN", @clickThumb
            thumb.on "ON_MOUSE_UP", @upThumb

            @thumbslist.addChild thumb
            @thumbsArr.push thumb
        
        # Progress Overlay
        # @progress = new Abstract().setElement "<div class='progress'><div class='line'></div><div class='clearfix'></div></div>"
        # @progress.dispose = () -> null
        # @progress.$el.css { "height" : @thumbH }
        # @thumbs.addChild @progress

        # Create the canvas
        w = @numberOfPictures * 600
        @canvas = $("<canvas width='#{w}' height='#{340}'></canvas>")
        @canvas.css { "display" : "none" }
        @addChild @canvas, true

        # @scroll()
        null

    addFrame: =>

        @oz().appView.subArea.makemovie.webcamfeed.flash()

        @thumbsArr[@currentFrame].draw @webcamfeed[0]
        @canvas[0].getContext("2d").drawImage @webcamfeed[0], @currentFrame * 600, 0, 600, 340

        @drawOzElement @currentFrame

        @currentFrame++
        null

    shotOnFrame: (frame) =>

        @oz().appView.subArea.makemovie.webcamfeed.flash()
        
        @thumbsArr[ frame ].draw @webcamfeed[0]
        @canvas[0].getContext("2d").drawImage @webcamfeed[0], frame * 600, 0, 600, 340
        @drawOzElement frame
        null

    drawOzElement : (frame) =>
        id = "fairy_final_#{frame+1}"
        icon = @oz().baseAssets.get(id).result
        @canvas[0].getContext("2d").drawImage icon, frame * 600, 0, 600, 340

        null

    overThumb: (id, target) =>

        if @status == "end"
            pos = target.$el.position().left - (@label.label.$el.width() / 2) + 29
            @label.showAt pos

            @player.gotoFrame id
            target.onOver()

        null

    outThumb: (id, target) =>

        if @status == "end"
            @label.hide()
            @player.play()
            target.onOut()

        null

    clickThumb: (id, mouseX, target) =>

        if @status == "end"
            @label.hide()
            @mouseX = mouseX
            @thumbToReplace = id

        null

    upThumb: (id, mouseX, target) =>

        if @status == "end" && @thumbToReplace == id && @mouseX == mouseX
            @trigger "REPLACE_THUMB", id

        null

    record: =>

        @clear()

        null

    stop: =>

        @currentFrame = 0
        null

    clear: =>

        @setStatus "normal"
        
        @thumbs.$el[0].scrollLeft = 0
        # @progress.$el.css {"width" : "#{ 0 }px"}

        @canvas[0].getContext('2d').clearRect 0 , 0 , @canvas.width() , @thumbH

        # Add all the thumbs
        for i in [0...@numberOfPictures]
            @thumbsArr[i].clear()
        return

        null

    onEnterFrame: =>
        null

    setStatus: (status) =>

        @status = status

        # if status == "end"

        #     @progress.hide true, =>
        #         @progress.$el.css { visibility : "hidden" }

        # else if status == "normal"

        #     @progress.show true, =>
        #         @progress.$el.css { visibility : "visible" }

        null

    disableThumbs: =>

        for i in [0...@numberOfPictures]
            @thumbsArr[i].disable()
        return

        null

    enableThumbs: =>

        for i in [0...@numberOfPictures]
            @thumbsArr[i].enable()
        return

        null

    dispose: =>

        for i in [0...@numberOfPictures]
            @thumbsArr[i].off "ON_OUT"
            @thumbsArr[i].off "ON_OVER"
            @thumbsArr[i].off "ON_MOUSE_DOWN"
            @thumbsArr[i].off "ON_MOUSE_UP"
        return

        null
