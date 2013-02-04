class ZoetropeWebcamFeed extends Abstract

    className   : "webcamfeed"

    canvas      : null
    filtered    : null
    player      : null

    videoW      : 640
    videoH      : 360

    countdown   : null

    camera      : null

    brightness  : { min: -70, max: 70, current: 0 }
    contrast    : { min: -0.7, max: 0.7, current: 0 }
    saturation  : 0

    flasher : null
    
    initialize : (_camera) =>
        @camera = _camera
        super()
        null

    init : () =>

        @flasher = $("<div class='flasher'></div>")
        @addChild @flasher
        @flasher.css
            opacity : 0
        
        @canvas = $("<canvas class='videocanvas' width='600' height='340'/>")
        @addChild @canvas

        @player = new ZoetropePlayer()
        @addChild @player, true

        @canvas[0].getContext("2d").translate 600, 0
        @canvas[0].getContext("2d").scale -1, 1

        @camera.get()
        null

    flash : =>
        @flasher.stop().animate { opacity : 0.8 }, { duration: 300, complete: =>
            @flasher.stop().animate { opacity : 0 }, { duration: 600 }
        }

        null


    addTexture: =>

        img = new Image()
        img.onload = =>

            @texture[0].width = img.width
            @texture[0].height = img.height
            @texture[0].getContext("2d").drawImage img, 0, 0, img.width, img.height

        img.src = "../img/zoetrope/zoetrope_canvas_texture.png"
        null

    onEnterFrame : =>
        
        # http://www.html5canvastutorials.com/tutorials/html5-canvas-image-crop/
        @canvas[0].getContext("2d").drawImage @oz().cam.dom(), 0, 0, @canvas.width(), @canvas.height(), 0, 0, @canvas.width(), @canvas.height()

        # Brightness and contrast
        # @filtered = Filter.filterImage Filter.brightnessContrast, @canvas[0], @brightness.current, @contrast.current
        # @canvas[0].getContext("2d").putImageData @filtered, 0, 0

        # Saturation
        # @filtered = Filter.filterImage Filter.saturation, @canvas[0], @saturation
        # @canvas[0].getContext("2d").putImageData @filtered, 0, 0

        # @texture[0].getContext("2d").blendOnto @canvas[0].getContext("2d"), "multiply" 
        null

    setBrightness: (brightness) =>
        @brightness.current = (brightness * (@brightness.max - @brightness.min) / 100) + @brightness.min
        null

    setContrast: (contrast) =>
        @contrast.current = (contrast * (@contrast.max - @contrast.min) / 100) + @contrast.min
        null

    animate : (from, to) =>

        brightnessI = { opacity: from.opacity, brightness: from.brightness }
        brightnessF = { opacity: to.opacity, brightness: to.brightness }

        tween = new TWEEN.Tween(brightnessI).to(brightnessF, 700)
        tween.easing TWEEN.Easing.Quadratic.Out
        tween.onUpdate =>
            @canvas.$el.css { "opacity" : "#{brightnessI.opacity}", "-webkit-filter" : "brightness(#{brightnessI.brightness}%)" }
        tween.start()
        null

    dispose: =>

        @canvas.remove()
        @oz().cam.dispose()
        null
