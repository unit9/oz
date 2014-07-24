class AppView extends Abstract

    footer          : null
    wrapper         : null
    
    area            : null
    scene           : null
    containerSubArea: null
    subArea         : null

    map             : null
    logo            : null
    static          : null
    loaded          : null
    currentArea     : null
    currentSub      : null
    loading         : null

    renderCanvas3D      : null
    zoetropeTexture     : null
    textureQuality      : null
    displayQuality      : null
    ddsSupported        : true
    dofEnabled          : false
    debugMode           : false
    remoteSounds        : false
    showInterface       : null
    enablePrefetching   : false
    pauseEnabled        : true

    areaLoading         : false
    areaLoadingPercent  : 0

    firstTime           : true

    chapterInstructionsShowed : false

    deepLink : null

    secondaryLoad : null
    loadingSecondary : true
    secLoadingProgress : null

    render :=>

        @deepLink = ['', 'cutout', 'music', 'zoetrope', 'storm']

        @setElement $('body')

        @renderCanvas3D = document.createElement( "canvas" )
        @renderCanvas3D.className = "scene3d"
        @addChild @renderCanvas3D

        @oz().baseAssets.on "COMPLETE", @onAssetsComplete
        @oz().baseAssets.on "PROGRESS", @onAssetsProgress
        @oz().baseAssets.loadBatch ['secondHomeAssets']

        ###
        paramTextureQuality = QueryString.get("quality")
        if paramTextureQuality == "low"
            @textureQuality = "low"
        else
            @textureQuality = "med"
        ###

        ###
        paramDisplayQuality = QueryString.get("display")
        if paramDisplayQuality == "low"
            @displayQuality = "low"
        else if paramDisplayQuality == "med"
            @displayQuality = "med"
        else
            @displayQuality = "hi"
        ###

        #### ADD GEOIP for videos

        script = document.createElement('script')
        script.src = 'http://j.maxmind.com/app/country.js'
        script.charset = 'ISO-8859-1'
        script.type = "text/javascript"
        document.getElementsByTagName('head')[0].appendChild script

        @textureQuality = (window || document).textureQuality
        @displayQuality = (window || document).displayQuality
        @dofEnabled     = (window || document).dof

        #@dofEnabled         = if QueryString.get("dof") == "on" then true else false
        @debugMode          = if QueryString.get("debug") == "on" then true else false
        @remoteSounds       = if QueryString.get("remotesounds") == "on" then true else false
        @showInterface      = if QueryString.get("interface") != "off" then true else false
        @enablePrefetching  = if QueryString.get("prefetching") == "on" then true else false


        SoundController.active = true
        if QueryString.get("sound") == "off"
            SoundController.active = false

        @subLoader = new SubLoader
        @addChild @subLoader, true
        
        @wrapper = new Wrapper
        @addChild @wrapper

        @share = new ShareScene
        @static = new StaticOverlay
        @footer = new Footer
        @map = new Map
        @logo = new Logo

        @showMap false

        @addChild @static

        # @static.changePage 'credits'
        # @addNewView ""
        
        if @showInterface
            @addChild @share
            @addChild @footer
            @addChild @map
            @addChild @logo
            if @debugMode
                @addChild @oz().stats.domElement


        # DEBUG MUSIC BOX
        
        # @subArea = new MusicBox 
        # @containerSubArea = new Abstract().setElement "<div></div>"
        # @containerSubArea.$el.css
        #     "display": "table"
        #     "width" : "100%"
        #     "height": "100%"
        #     "position" : 'absolute'

        # @containerSubArea.dispose = () -> null
        # @wrapper.addChild @containerSubArea

        # @containerSubArea.addChild @subArea

        # return

        # Debug the Localised texture
        # 
        # @debug = $("<div id='debug' style='position: absolute; width: 100%; height: 100%; top:0; z-index: 99;'></div>")
        # @$el.append @debug
        # @debug.append @oz().localeTexture.get('cutout').canvas

        @listenToEvents()

        $('#polite').remove()

        @

    onAssetsComplete : (event)=>
        @loadingSecondary = false
        @oz().baseAssets.off "COMPLETE", @onAssetsComplete
        @oz().baseAssets.off "PROGRESS", @onAssetsProgress

    onAssetsProgress : (event)=>
        @secLoadingProgress = event.loaded 


    listenToEvents : =>
        $(window).resize @onResize


    startFocus : =>

        Analytics.track 'resume'

        if @static.page instanceof LandingPause then @static.close()

        $(window).bind 'blur', @looseFocus
        $(window).unbind 'focus', @startFocus
        @static.off 'staticPageClose', @startFocus

        $(".scene3d").css { "-webkit-filter": "blur(0px)" }
        $("#wrapper").css { "-webkit-filter": "blur(0px)" }

        @changeMapState()

        @wrapper.resume()

        SoundController.resume()

        # Show interface elements (logo, menu, map)
        if !@subArea?.instructions && !@subLoader.visible && @scene != "Final" && @static.currentPage != "credits" && @currentArea != "storm"
            @showMap()
            @footer.mainMenu.show true
            @footer.cr.show true
            @logo.show true
        else
            @footer.cr.show true
            @logo.show true

    looseFocus : =>

        Analytics.track 'pause'

        if !@subArea?.instructions.active && @pauseEnabled

            $(window).unbind 'blur', @looseFocus
            $(window).bind 'focus', @startFocus

            $(".scene3d").css { "-webkit-filter": "blur(10px)" }
            $("#wrapper").css { "-webkit-filter": "blur(10px)" }

            SoundController.paused()

            if !@static.opened
                @wrapper.pause()
                @changeOpening 'pause'

                # Hide interface elements (logo, menu, map)
                @showMap false
                @footer.mainMenu.hide true
                @footer.cr.hide true
                @logo.hide true

        
    changeOpening : (type, params) =>
        @static.changePage type, params


    changeView : (area, sub = null) =>

        # Check if the area is one of the static pages
        if @static.has(area) >= 0
            @static.changePage area
            @addNewView ""
            return

        # If there is NO static page opened then
        if !@static.opened
            @addNewView area, sub
            return

        @static.on 'staticPageClose', =>
            @addNewView area, sub

        @static.close()

    hideArea : (callback) =>
        @area.hide true, => 
            callback?()
        , 600

    changeMapState : =>
        @map.changeMenuArea @scene.toLowerCase()

    addNewView : ( area, noLoading = false ) =>

        @static.off()

        # Hide and restore the bottom menu/map visibility in case of a subArea is opened
        # This only will be true, when the user use the browser back button
        if @subArea
            @subArea.hide true, =>

                @oz().appView.footer.mainMenu.$el.css { display : "" }
                @oz().appView.logo.enable()
                @footer.mainMenu.show true

                @wrapper.remove @subArea
                @wrapper.remove @containerSubArea
                @subArea = null

        if area != @currentArea

            @currentArea = area
            @loading = new Loading unless @loaded

            currentScene = @getCurrentScene(area)

            if currentScene != @scene

                # Show internal loader between scenes
                # If @loaded, so already used the main loaded, now every next loading is used the SubLoader class
                # TODO : #1987
                #       Some scenes could be exception and don't need SubLoader
                #       Clever way to don't show the SubLoader
                if @loaded
                    if currentScene == "Final"
                        @subLoader.visible = true
                    else
                        @subLoader.show()

                @scene = currentScene

                if @area then @wrapper.remove @area

                # instance carnival in case we don't have an area class for the given url
                areaClass = eval(@scene)
                if !areaClass?
                    @scene = currentScene = "Carnival"
                    areaClass = eval(@scene)
                    
                @area = new (areaClass)()



                @area.hide()
                @wrapper.$el.empty()
                @area.render()

                if @loading

                    Analytics.track 'start_loading'

                    # Sound Controller
                    SoundController.init(@remoteSounds)

                    # Activate the loading check on onEnterFrame method
                    @areaLoading = true

                    @wrapper.addChild @loading

                    @area.on 'onWorldProgress', @onWorldProgress
                    @area.on 'onWorldLoaded', @onWorldLoaded

                    @logo.disable()
                
                # if else, it's because the first @loading already finish and set to null so now we need the subLoader for the internal scenes transitions
                else if @subLoader.visible

                    @firstTime = false
                    @pauseEnabled = false

                    SoundController.send "loading_start"

                    if currentScene == "Final"
                        @addFinal()
                    else
                        @areaLoading = true
                        @area.on 'onWorldProgress', @onWorldProgress
                        @area.on 'onWorldLoaded', @onWorldLoaded

            else

                @checkSub()

        # Change menu state according to the current 3D scene
        @changeMapState()
        null

    getCurrentScene : (area) =>
        switch area
            when ""
                return (if @scene != null then @scene else "Carnival")

            when "cutout", "music", "carnival"
                return "Carnival"

            when "zoetrope", "carnival2"
                return "Carnival2"

            when "carnival3"
                return "Carnival3"

            # when "nomodels"
            #     return "PerformanceTest"
            # when "notextures"
            #     return "PerformanceNoTextures"             
            # when "prefetch"
            #     return "PerformanceTestPrefetch"       
            # when "barebone"
            #     return "PerformanceTestNoloop"             

            when "storm"
                return "Stormtest"

            when "final"
                return "Final"

    checkSub : =>

        Analytics.track 'finish_loading'
        SoundController.send "loading_end"

        switch @scene.toLowerCase()
            when "carnival"
                Analytics.track 'scene3D_1_enterPage'

            when "carnival2"
                Analytics.track 'scene3D_2_enterPage'

            when "storm", "carnival3"
                Analytics.track 'scene3D_3_enterPage'

            when "final"
                Analytics.track 'payoff_enter_page'

        if @currentArea
            v = @isDeepLink(@currentArea)
            if v != ""
                @area.changeView v
        else
            
            if !@chapterInstructionsShowed
                @chapterInstructionsShowed = true
                @area.chapterInstructions?.activate()
            
            @area.changeView null

    isDeepLink : (area) =>
        return area if @deepLink.indexOf(area) > -1
        ""

    onCameraReady : =>
        
        switch @currentArea

            when "cutout"
                @subArea = new Cutout

            when "music"
                @subArea = new MusicBox 

            when "zoetrope"
                @subArea = new Zoetrope

            when "storm"
                @subArea = new StormInstructions

            else 
                @subArea = null

        if @subArea

            @containerSubArea = new Abstract().setElement "<div></div>"
            @containerSubArea.$el.css
                "display": "table"
                "width" : "100%"
                "height": "100%"
                "position" : 'absolute'

            @containerSubArea.dispose = () -> null
            @wrapper.addChild @containerSubArea

            @containerSubArea.addChild @subArea

    removeLoading : =>
        @wrapper.remove @loading
        @loading = null


    onWorldProgress : (percentage) =>
        @areaLoadingPercent = Math.round percentage * 100
        
        # if @loadingSecondary
        #     perc = Math.round (@areaLoadingPercent + Math.round(@secLoadingProgress * 100)) / 2
        # else
        perc = @areaLoadingPercent

        #

        if @subLoader.visible
            @subLoader.update perc
        else
            @loading.update perc        


    onWorldLoaded : (event) =>

        @areaLoadingPercent = 0
        @areaLoading = false
        @pauseEnabled = true

        @area.cleanloading?()
        @area.off 'onWorldProgress', @onWorldProgress
        @area.off 'onWorldLoaded', @onWorldLoaded

        if @loading
            
            # Add the area when it is loaded
            @wrapper.addChild @area

            @static.on 'staticPageClose', @onAgreed
            @loading.update 99 if @loading
            @loading.onAnimateOut if !@oz().agreed then @addTermsScreen else @addChapter
        else 
            
            if !@oz().agreed
                @addTermsScreen()
            else
                @subLoader.on "END_LOADING", @hideSubLoader
                @subLoader.hideCard()

    hideSubLoader: =>

        @subLoader.off "END_LOADING", @hideSubLoader
        
        # Add the area when it is loaded
        @wrapper.addChild @area
        @addChapter()

        setTimeout @subLoader.hide, 500

    addTermsScreen : =>

        Analytics.track null, "Google_OZ_landing page"

        @oz().appView.changeOpening 'agree',
            title : "homeTitle",
            cta   : "homeSub"

    addFinal : =>

        @wrapper.addChild @area

        @logo.disable()
        @footer.shareMenu.enableSound()

        SoundController.send "end_scene_start"
        @removeLoading()
        @loaded = true
        @area.show true


    addChapter : =>

        @logo.enable()
        @footer.shareMenu.enableSound()

        switch @scene.toLowerCase()
            # when 'carnival'
            #     SoundController.send "scene_carnival_start"

            # when 'carnival2'
            #     SoundController.send "scene_carnival2_start"

            # when 'carnival3'
            #     SoundController.send "scene_carnival3_start"

            when 'final'
                SoundController.send "end_scene_start"
                @removeLoading()
                @loaded = true
                @area.show true
                return

        @footer.show true
        @footer.mainMenu.showThis @footer.mainMenu.openMenuBtn
        @logo.hideGoogleLogos()
        @footer.showCC()

        @removeLoading()
        @loaded = true

        @area.show true, =>

            @checkSub()
            @showMap()

        , 700

    showMap : (val = true)=>

        if val == false
            @map.hide true
            return

        # Only show menu on 3D scenes
        switch @scene.toLowerCase()
            when 'carnival', 'carnival2', 'carnival3', '', null
                @map.show true


    onAgreed : =>
        @static.off 'staticPageClose', @onAgreed

        @loading.hide true, =>

            @addChapter()

            @oz().agreed = true
            $(window).bind 'blur', @looseFocus

    showMenu :->
        @map?.showMenu()
        return null

    # onEnterFrame : =>

    #     super()

        # if @areaLoading

            # console.log "[ Loading: ", perc + " ]", "[ Area: ", @areaLoadingPercent, "Sounds: ", SoundController.progress + " ]"
            # perc = @areaLoadingPercent#Math.round (@areaLoadingPercent + SoundController.progress) / 2

            # if @subLoader.visible
            #     @subLoader.update perc
            # else
            #     @loading.update perc

            # if perc >= 100
            #     @areaLoading = false
            #     setTimeout @onWorldLoaded, 1000
