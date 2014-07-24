class StaticOverlay extends Abstract

    className : 'staticOverlay'
    page      : null
    lastPage  : null
    opened    : false
    pages     : [ "trailer", "credits", "opening" ]
    area      : null
    currentPage: null

    init : =>

        @$el.bind "click", @close
        
        @hide()
        null

    changePage : (p, params) =>

        @empty()

        @page = null
        @currentPage = p

        # console.log p
        @$el.removeClass "stormImage"

        @$el.css
            "background-color" : "rgba(0, 0, 0, .7)"
            "position" : "absolute"
        
        switch p

            when 'credits'

                @addCloseButton()

                # Pause website
                @oz().appView.wrapper.pause()
                @oz().appView.pauseEnabled = false

                $(".scene3d").css { "-webkit-filter": "blur(10px)" }
                $("#wrapper").css { "-webkit-filter": "blur(10px)" }

                # Hide interface elements (logo, menu, map)
                if @oz().appView.scene != "Final"

                    @oz().appView.footer.mainMenu.hide true, =>
                        @oz().appView.footer.mainMenu.$el.css { display : "none" }
                        @oz().appView.footer.cr.show true
                        @oz().appView.footer.mainMenu.showThis @oz().appView.footer.mainMenu.openMenuBtn
                        @oz().appView.footer.mainMenu.hideThis @oz().appView.footer.mainMenu.buttonList

                    @oz().appView.logo.disable()
                    @oz().appView.showMap(false)
                    @oz().appView.footer.shareMenu.hide true
                    
                    $('body').unbind 'mousemove'

                @page = new Credits

            when 'pause'

                @page  = new LandingPause

            when 'agree'

                # @oz().appView.logo.enable()
                
                @$el.css
                    "background-color" : "rgba(0, 0, 0, 0)"
                    "position" : "static"

                @$el.unbind "click", @close
                @mouseEnabled true
                @page = new LandingAgree params.title, params.cta, params.divider, false, false
                @page.on 'agreedEnter', @close
                

        unless @page?
            return

        @$el.css {display: 'block'}

        @addChild @page
        @page.render @showPage

        @lastPage = p
        null

    showPage : =>

        time = if @page instanceof LandingPause then 500 else 1000        

        @opened = true
        @show true, null, time
        null

    show : (anim = false, callback = null, time = 400, ease = "linear") =>
        @visible = true

        if !anim
            @$el.css {opacity : 1}
        else
            @$el.animate {opacity: 1}, time, ease, callback

        null

    hide : (anim = false, callback = null, time = 400, ease = "linear") =>
        @visible = false

        if !anim
            @$el.css { opacity : 0, display: 'none'}
        else 
            @$el.animate {opacity: 0}, time, ease, => 
                @$el.css { display: 'none' }
                callback?()

        null

    close : ( manual = false ) =>
                
        if manual && @oz().appView.scene != "Final"

            # Restore Footer
            @oz().appView.footer.mainMenu.$el.css { display : "" }
            @oz().appView.footer.mainMenu.show true
            @oz().appView.logo.enable()
            @oz().appView.showMap()

        # When you leave the credtis because the wrapper was paused manually we should resume it here
        if @currentPage == "credits"
            $(".scene3d").css { "-webkit-filter": "blur(0px)" }
            $("#wrapper").css { "-webkit-filter": "blur(0px)" }

            @oz().appView.pauseEnabled = true
            @oz().appView.wrapper.resume()

        @$el.animate
            'opacity' : '0', @animateComplete

        null

    animateComplete : =>

        @restoreAddress()

        @opened = false
        @page = null
        @currentPage = null

        @$el.css
            'display' : 'none'

        @trigger 'staticPageClose'

        null

    has: (area) =>
        @pages.indexOf area

    addCloseButton : =>

        @closeBtn = new Abstract().setElement "<div class='sceneClose'></div>"
        @closeBtn.$el.addClass 'button_alpha_enabled'
        @closeBtn.dispose = () -> null
        @closeBtn.$el.bind "click", @onClose
        @addChild @closeBtn

        icon = new SSAsset "interface", "button_close"
        @closeBtn.addChild icon

        null

    onClose: =>
        @close true
        null

    dispose: =>
        null

    restoreAddress : =>

        url = if @oz().router.area == @lastPage || @has( @oz().router.area ) >= 0 then "" else if @oz().router.sub then @oz().router.area + "/" + @oz().router.sub else @oz().router.area
        @oz().router.navigate url, { trigger: false }
        null
