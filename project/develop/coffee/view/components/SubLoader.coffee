class SubLoader extends Abstract

    className   : "subLoader"
    container   : null
    square      : null
    visible     : false
    angleX      : 0
    angleY      : 0
    error       : null

    init : =>

        @container = new Abstract().setElement "<div class='subLoaderContainer'></div>"
        @container.dispose = () -> null
        @addChild @container

        @card = new LoadingCard
        @addChild @card

        @addSpinner()

        @hide false
        null

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

        @container.addChild @spinner.canvas
        @container.$el.css {"display" : "none"}
                

        null

    showError : () =>

        @container.$el.css {"display" : "none"}

        header = new SSAsset 'interface', 'pause_top'
        header.$el.css {'margin' : '0 auto 15px auto'}

        @error = $("<div class='subLoaderError'><div class='shareErrorCopy'>#{@oz().locale.get("share_error_message")}</div></div>")
        @error.prepend header.$el
        @addChild @error

        bottom = new SSAsset 'interface', 'pause_bottom'
        @error.append bottom.$el
        bottom.$el.css {'margin' : '20px auto'}

        @$el.bind 'click', @hide


    update : (perc) =>
        @card.update perc
        null

    onMouseMove : (event) =>

        if @paused
            return
            
        x = (((event.clientX - ($(window).innerWidth() / 2) )) / 40) 
        y = (((event.clientY - ($(window).innerHeight() / 2) )) / 35)

        @angleX += (x - @angleX) * .075
        @angleY += (y - @angleY) * .075

        @angleX = @angleX % 360
        @angleY = @angleY % 360

        @card.transform @angleX, @angleY
        null

    onClick : (event) =>
        @card.toggleTopple()
        null

    show : (spin = false) =>

        super true, null, 400, "linear"

        @paused = false
        
        # Blurred the scene behind
        $(".scene3d").css { "-webkit-filter": "blur(10px)" }
        
        if !spin
            @spinner.stop()
            @card.$el.css
                "display" : ""
            @container.$el.css
                "display" : "none"

            # Show the card
            @card.animateIn @activateMouseInteraction
        else
            @spinner.play()
            @card.$el.css
                "display" : "none"
            @container.$el.css
                "display" : ""

        # Disable footer
        @oz().appView.logo.disable()
        @oz().appView.showMap(false)
        @oz().appView.footer.mainMenu.hide true

        @visible = true
        null

    hide : (anim = true, callback = null, time = 400, ease = "linear", hide = true) =>

        @$el.unbind 'click', @hide

        @error?.remove()

        super anim, callback, time, ease, hide
        
        # Remove blur from the scene
        $(".scene3d").css { "-webkit-filter": "blur(0px)" }

        @$el.css { "background-color" : "rgba(0,0,0,0.6)" }

        # Enable footer
        # @oz().appView.logo?.enable()
        # @oz().appView.map?.show true
        # @oz().appView.footer?.mainMenu.show true

        @visible = false
        null

    hideCard : =>

        # Hide card
        @card.animateOut null

        # Mouse Interaction
        $(window).unbind 'mousemove', @onMouseMove
        $(window).unbind 'click', @onClick
        @paused = true

        @$el.css { "background-color" : "rgba(0,0,0,1)" }

        delay = (ms, func) -> setTimeout func, ms
        
        d = Number(@$el.css "opacity") * 1000
        delay d, => @trigger "END_LOADING"

        null


    activateMouseInteraction : =>
        $(window).bind 'mousemove', @onMouseMove
        $(window).bind 'click', @onClick
        null

    dispose : =>
        null