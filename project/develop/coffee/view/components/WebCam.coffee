class WebCam

    stream   : null
    videoDom : null
    canvas   : null
    ctx      : null

    constructor : ->
        _.extend @, Backbone.Events
        null

    init : =>

        @canvas = document.createElement 'canvas'
        @canvas.width = 512
        @canvas.height = @canvas.width / 1.333333333

        @ctx = @canvas.getContext '2d'
        @ctx.scale -1, 1

        @videoDom = $('<video style="display:none;" autoplay="true"/>')
        $('body').prepend @videoDom

        if !@stream?
            navigator.getUserMedia { video : true, audio : false }, @onUserMediaSuccess, @onUserMediaError
        else
            @onUserMediaSuccess()

        null

       
    onUserMediaSuccess : (s = null) =>
        @stream = s || @stream
        @trigger 'CAM_READY'
        null

    onUserMediaError :=>
        @trigger 'CAM_FAIL'
        @dispose()
        null

    get : =>

        if !@stream?
            @init()
            return

        src = window.URL.createObjectURL(@stream)
        @dom().src = src

        #return
        src

    dom : =>
        #return
        @videoDom.get()[0]

    flipImage : =>
        @ctx.drawImage @dom(), -@canvas.width, 0
        # return 
        #@ctx.getImageData 0, 0, @canvas.width, @canvas.height
        return @canvas

    dispose : =>
        @stream.stop() if @stream
        @stream = null
        @canvas = null
        null
