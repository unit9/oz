class Final extends AbstractScene

    simulate  : null
    content : null

    init : =>

        @$el.addClass "final"

        # Hide interface elements (map menu)
        @oz().appView.showMap false
        # @oz().appView.footer.mainMenu.hide true
        @oz().appView.footer.shareMenu.hideSoundButton()

        @changeState "menu"

        null

    changeState : (status) =>

        if @content
            # ------------------------------- FADING OUT -------------------------------
            @content.$el.animate {opacity: 0}, {duration: 800, complete: =>
                @remove @content
                @content = null
                @changeState status
            }
            return

        switch status

            when "transitionVideo"

                @content = new Abstract().setElement "<div class='video'><video width='320' height='240' src=''></video></div>"
                @content.dispose = () -> null
                @addChild @content
                @playVideo()
                @fadeIn()

            when "menu"

                # Disable pause
                $(window).unbind "blur", @looseFocus

                @content = new Abstract().setElement "<div class='finalmenu stormImage'><div class='blackOverlay'></div></div>"
                @content.dispose = () -> null
                @addChild @content
                @content.$el.css {opacity : 0}

                landing  = new LandingFinal "finalHeader", "finalSub"
                @content.addChild landing
                landing.render @fadeIn, true

                # Show footer elements
                @oz().appView.logo.showGoogleLogos()
                @oz().appView.footer.showMenu true

        null

        # ------------------------------- FADING IN -------------------------------
        
    fadeIn : =>
        
        @content.$el.animate {opacity: 1}, {duration: 800, complete: =>
            @$el.css
                "background-color": "#000000"
        }

        null


    playVideo: =>

        Analytics.track 'transition_start_video', 'Google_OZ_ViewPayoff_Movie_EngagementClick'

        videoElement = @content.$el.find("video")[0]
        @content.$el.find("video").attr "src", "/videos/eoe.webm"
        
        videoElement.load()
        videoElement.play()
        
        videoElement.addEventListener "ended", @videoEnded, false

        null

    videoEnded: (e) =>

        Analytics.track 'transition_end_video'

        videoElement = @content.$el.find("video")[0]
        videoElement.removeEventListener "ended", @videoEnded, false
        videoElement.src = ""

        @changeState "menu"

        null
    
    pause : =>
        super()

        videoElement = @content.$el.find("video")[0]
        videoElement?.pause()

        null

    resume : =>
        super()
        
        videoElement = @content.$el.find("video")[0]
        videoElement?.play()

        null

    showVideo : =>

        trailer = new VideoPlayer
        @oz().appView.wrapper.addChild trailer, true

        SoundController.send "trailer_start"

        @content.hide true, =>
            @content.$el.css { display : "none" }
        trailer.show true

        # Hide footer elements
        @oz().appView.logo.hideGoogleLogos()
        @oz().appView.footer.mainMenu.hide true
        @oz().appView.footer.cr.show true
        @oz().appView.footer.shareMenu.hide true

        null

    render : =>

        # Workaround
        @simulate = setInterval () =>
            @onWorldProgress(1)
        , 400

        null

    cleanloading : =>

        clearInterval @simulate

        null

    onWorldProgress : (percentage) =>

        @trigger 'onWorldProgress', percentage

        null

    changeView: =>
        null

    dispose :=>
        @remove @transitionVideo
        null

