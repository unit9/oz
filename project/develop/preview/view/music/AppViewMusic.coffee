class AppViewMusic extends Abstract

    soundsLoaded    : false
    container       : null
    buttons         : null
    playing         : false

    init: =>

        @setElement $('body')

        # Header
        @header = new Header
        @$el.append @header.$el

        # Init SoundController
        SoundController.active = true
        SoundController.init false

        @addInterface()

        # Button to go to the main site
        @buttonContainer = @$el.append ('<div class="buttonContainer"><div class="buttonCell" /></div>')
        @button = new Button @oz().locale.get('musicSharePageButton'), '/music'
        @buttonContainer.find('.buttonCell').append @button.$el

        # Footer
        @footer = new Footer
        @$el.append @footer.$el

     addSpinner: =>

        @spinner = new Sonic

            width: 50
            height: 50

            stepsPerFrame: 1
            trailLength: 1
            pointDistance: .02
            fps: 30

            fillColor: '#FFFFFF'

            step: (point, index) ->
                
                this._.beginPath()
                this._.moveTo(point.x, point.y)
                this._.arc(point.x, point.y, index * 3, 0, Math.PI*2, false)
                this._.closePath()
                this._.fill()

            path: [
                ['arc', 25, 25, 10, 0, 360]
            ]

        loader = $("<div />")
        loader.css
            "position": "absolute"
            "width": "100%"
            "height": "100%"
            "display": "table"
            "pointer-events" : "none"

        loaderCanvas = $("<div />")
        loaderCanvas.css
            "display": "table-cell"
            "width": "100%"
            "height": "100%"
            "vertical-align": "middle"

        loader.append loaderCanvas
        @$el.append loader

        loaderCanvas.append @spinner.canvas

        @spinner.play()

    addInterface : =>

        # Container
        @container = $('<div class="button_music_container"/>')

        # Buttons container
        @buttons = $('<div class="button_music_play"/>')

        @playPause = $('<div class="playPause"/>')
        @playPause.css
            "visibility" : "hidden"

        # Play
        @btPlay = $('<img src="/img/preview/music_button_play.png"/>')
        @btPlay.bind 'click', @tooglePlay

        #Pause
        @btPause = $('<img src="/img/preview/music_button_pause.png"/>')
        @btPause.bind 'click', @tooglePlay
        @btPause.css
            opacity : 0

        @playPause.append @btPause
        @playPause.append @btPlay

        @buttons.append @playPause
        @container.append @buttons

        @$el.append @container

        @addSpinner()

    tooglePlay : =>

        if !@playing
            @playing = true
            @btPause.css
                opacity : 1
            @btPlay.css
                opacity : 0
            SoundController.preview @oz().result
        else
            @playing = false
            @btPause.css
                opacity : 0
            @btPlay.css
                opacity : 1
            SoundController.stopBackgroundMusic()

    soudControllerLoaded: =>
        
        @soundsLoaded = true

        # Turn the volume on
        SoundController.send "load_scene_5", "musicbox_shared"

    onAllSoundsLoaded: =>   

        SoundController.batchLoaded = false

        @spinner.stop()
        $(@spinner.canvas).animate
            opacity : 0
        ,{
            duration: 250
            complete: =>
                $(@spinner.canvas).css
                    visibility : "hidden"
            }

        @activate()

    activate: =>

        @playPause.css
            opacity : 0
            visibility : "visible"

        @playPause.animate
            opacity : 1
        , 300

        @

    onEnterFrame: =>

        if !@soundsLoaded
            if SoundController.loaded
                @soudControllerLoaded()
        else if SoundController.batchLoaded
            @onAllSoundsLoaded()
                    
                


        super()

    oz : =>

        return (window || document).oz
