class CutoutCanvas extends Abstract

    ctx         : null

    # textures
    cutout      : null
    cutout_oz   : null

    textureImgOz : null
    textureImg   : null

    coord       : null

    canvas      : null
    camCanvas   : null
    camCtx      : null

    paused      : true
    camSize     : null
    textureSize : null
    className   : 'cutout_canvas'
    photoCanvas : null
    photoCtx    : null

    photoCanvasTemp : null
    photoCtxTemp    : null

    colorCorrectCanvas : null
    colorCorrectCtx : null

    portrait : null

    paused : true

    init : =>
        @canvas = document.createElement('canvas')
        @canvas.width = 1024
        @canvas.height = 1024
        @ctx = @canvas.getContext '2d'

        @camCanvas = document.createElement 'canvas'
        @camCanvas.width = 1024
        @camCanvas.height = 1024
        @camCtx = @camCanvas.getContext '2d'

        $(@canvas).css
            "z-index"   : 99
            "position"  : "absolute"
            "width"     : "1024px"
            "height"    : "1024px"
            "top"       : "-90000px"
            "left"      : "-90000px"

        $('body').append $(@canvas)

        null


    setup : (params) =>

        @coord       = params.coords
        @camSize     = params.camSize
        @textureSize = params.textureS

        @cutout      = params.img
        @cutout_oz   = params.imgOz

        #@colorCorrectCtx = @colorCorrectCanvas.getContext '2d'

        null


    changeCamera : (params) =>
        Analytics.track 'cutout_change_camera'
        @coord = params
        @paused = false

        null

    pause : =>
        return

    resume : =>
        return

    onEnterFrame : =>
        return if @paused
        @renderTexture()

        null

    renderTexture : (nocamera = false) =>
        @canvas = @createTextureWebCam(@ctx, @canvas, false, nocamera)
        @oz().appView.area.updateCutoutsTexture @canvas
        null
    
    createTextureWebCam : (context, canvas, oz, nocamera = false) =>
        context.clearRect(0, 0, 1024, 1024)
        context.setTransform(1, 0, 0, 1, 0, 0)
        context.save()

        if nocamera == false
            if @coord.o != 0
                context.translate @coord.x, @coord.y + @camSize[0]
                context.rotate @coord.o
                # @ctx.drawImage @colorCorrectCam( @oz().cam.flipImage() ), (@camSize[0] >> 1), -(@camSize[1] >> 1), @camSize[0], @camSize[1]
                context.drawImage @oz().cam.flipImage(), (@camSize[0] >> 1), -(@camSize[1] >> 1), @camSize[0], @camSize[1]
            else
                context.rotate @coord.o
                context.translate @coord.x, @coord.y
                # @ctx.drawImage @colorCorrectCam( @oz().cam.flipImage() ), -(@camSize[0] >> 1), - (@camSize[1] >> 1), @camSize[0], @camSize[1]
                context.drawImage @oz().cam.flipImage(), -(@camSize[0] >> 1), - (@camSize[1] >> 1), @camSize[0], @camSize[1]

            context.restore()

        context.translate 0, 0
        context.rotate 0 
        context.drawImage((if oz then @cutout_oz else @cutout), 0, 0)
        # return
        canvas

    reset : =>
        @paused = false
        null

    getPhoto : (canvas = false, oz = false) =>

        if canvas == true
            @portrait = null

        @camCanvas = @createTextureWebCam(@camCtx, @camCanvas, oz)

        @renderTexture()

        @photoCanvas = document.createElement('canvas')
        @photoCtx = @photoCanvas.getContext '2d'

        @photoCanvasTemp = document.createElement('canvas')
        @photoCtxTemp = @photoCanvasTemp.getContext '2d'


        if @coord.o != 0
            @photoCanvasTemp.width = @textureSize[1]
            @photoCanvasTemp.height = @textureSize[0]

            @photoCanvas.width = @textureSize[0]
            @photoCanvas.height = @textureSize[1]

            if canvas
                imgData = @camCtx.getImageData @coord.xx, @coord.yy, @textureSize[1], @textureSize[0]
                @portrait = @camCtx.getImageData @coord.xx, @coord.yy, @textureSize[1], @textureSize[0]
            else 
                imgData = @portrait

            @photoCtxTemp.putImageData imgData, 0,0

            @photoCtx.translate(@photoCanvas.height - 166, 0)
            @photoCtx.rotate(90 * (Math.PI / 180))
            
            @photoCtx.drawImage @photoCanvasTemp, 0, 0

        else
            @photoCanvasTemp.width = @textureSize[0]
            @photoCanvasTemp.height = @textureSize[1]

            @photoCanvas.width = @textureSize[0]
            @photoCanvas.height = @textureSize[1]

            if canvas
                imgData = @camCtx.getImageData @coord.xx, @coord.yy, @textureSize[0], @textureSize[1]
                @portrait = @camCtx.getImageData @coord.xx, @coord.yy, @textureSize[0], @textureSize[1]
            else 
                imgData = @portrait

            @photoCtxTemp.putImageData imgData, 0, 0
            @photoCtx.drawImage @photoCanvasTemp, 0, 0

        @paused = true

        if canvas
            return @photoCanvas
        else 
            @portrait = null
            return @image = @photoCanvas.toDataURL("image/jpeg").slice "data:image/jpeg;base64,".length


    dispose : =>
        $(@canvas).remove()
        @portrait = null
        @photoCanvas = @photoCtx = @photoCanvasTemp = @photoCtxTemp = null
        null


    # not using, performance issues
    colorCorrectCam:(imageObj)->
        @colorCorrectCanvas.width   = imageObj.width
        @colorCorrectCanvas.height  = imageObj.height

        @colorCorrectCtx.drawImage(imageObj, 0, 0);

        imageData = @colorCorrectCtx.getImageData(0, 0, imageObj.width, imageObj.height)
        data = imageData.data;

        for i in [0...data.length] by 4

            # this brightens it more 
            data[i]     *= 1.6 # r
            data[i+1]   *= 1.6 # g
            data[i+2]   *= 1.6 # b

          # this is to turn it greyscale
            
          # brightness = 0.34 * data[i] + 0.5 * data[i + 1] + 0.16 * data[i + 2];
          # # red
          # data[i] = brightness;
          # # green
          # data[i + 1] = brightness;
          # # blue
          # data[i + 2] = brightness;
        
        # overwrite original image
        @colorCorrectCtx.putImageData(imageData, 0, 0)
        return @colorCorrectCanvas


            
        