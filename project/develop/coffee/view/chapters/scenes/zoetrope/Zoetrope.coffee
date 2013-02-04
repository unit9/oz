class Zoetrope extends AbstractScene

    # assetsBatch : ['zoetropeAssets']
    id          : "zoetrope"

    container   : null
    camera      : null

    image : null
    imageFooter : null

    instructionsBox : null

    init : =>

        @render()

        null

    onAssetsComplete : =>

        @remove @loader
        
        super()
        null

    render : =>

        Analytics.track 'zoe_enter_page', "Google_OZ_Zeotrope"
        
        @addLayout 'instructions_zoetrope', 'zoetrope_intructions', { w : 656, h : 750, debug: false }

        super()
        null

    onClose: =>

        if !(@oz().appView.static.page instanceof LandingPause)

            Analytics.track 'zoe_close_section'

            SoundController.send "zoetrope_end"
            SoundController.send "zoetrope_scene_end"
            
            @oz().appView.footer.mainMenu.$el.css { display : "" }
            @oz().appView.logo.enable()
            @oz().appView.share.hide()
            @oz().appView.subLoader.hide()
           
            super()

        null

    addLayout : (assetID, localeID, boundaries) =>

        SoundController.send "zoetrope_start"

        super assetID, localeID, boundaries

        @oz().appView.footer.mainMenu.$el.css { display : "none" }
        @oz().appView.logo.disable()

        @instructions.show true, =>
            # Ask for camera permissions
            @addCameraHelper()
            @camera = @oz().cam
            @camera.on "CAM_READY", @onEnableCamera
            @camera.on "CAM_FAIL", @onCamFail
            @camera.init()

        null
    
    onEnableCamera: =>

        Analytics.track 'zoe_allow_camera'
        SoundController.send "zoetrope_scene_start"

        @addCloseButton()

        @cleanCameraListeners()
        @next()

        null

    onCamFail : =>

        @image = new SSAsset "interface", "instructions_warning"
        @image.css {"margin" : "0 auto"}

        @cleanCameraListeners()

        @instructions.hide false

        @instructionsBox = @instructions.$el.find('.box').find('#c22')

        @instructionsBox.empty()
        @instructionsBox.append @image.$el
        @instructionsBox.append("<p>#{@oz().locale.get('no_webcam_copy')}</p>")

        @imageFooter = new SSAsset "interface", "pause_bottom"
        @imageFooter.css {"margin" : "0 auto"}
        @instructionsBox.append @imageFooter.$el

        @instructions.show true, =>
            $('body').bind 'click', @onDisableCamera

        null
            

    onDisableCamera: =>

        $('body').unbind 'click', @onDisableCamera

        Analytics.track 'zoe_deny_camera'

        @cleanCameraListeners()
        @onClose()

        null

    cleanCameraListeners: =>
        @removeCameraHelper()

        @camera?.off "CAM_READY", @onEnableCamera
        @camera?.off "CAM_FAIL", @onCamFail

        null

    next: =>
        @instructions.hide true, @goMakeMovie
        null
        
    goMakeMovie: =>

        @remove @instructions

        @makemovie = new ZoetropeMakeMovie @camera
        @makemovie.on "SHARE", @goShare
        @makemovie.on "fail", @restore
        @addChild @makemovie

        null

    goShare: (link) =>

        # Disable pause
        @oz().appView.pauseEnabled = false

        @makemovie.$el.animate {opacity: 0}, 300, 'linear'

        @oz().appView.share.show
            title   : @oz().locale.get("zoetrope_nice_illusion")
            sub     : @oz().locale.get("zoetrope_share_copy")
            back    : @oz().locale.get("zoetrope_record_another")
            link    : link
            backCall: @restore
            type    : "zoe"

        null

    restore: =>

        @makemovie.off "fail", @restore

        # Enable pause
        @oz().appView.pauseEnabled = true

        @makemovie.$el.animate {opacity: 1}, 300, "linear"
        @makemovie.goTryAgain false

        null

    dispose: =>

        # Stop record
        @makemovie?.stopRecord()

        # Enable pause
        @oz().appView.pauseEnabled = true
        
        super()
        @instructions = null
        @cleanCameraListeners()
        @camera?.dispose()
        @camera = null
        @makemovie?.off "SHARE", @goShare

        null

    ###
    addPreview: =>

        @makemovie.mouseEnabled false

        @preview = new ZoetropePreview
        @preview.on "BACK", @removePreview
        @addChild @preview

    removePreview: =>
        
        @preview.off "BACK"
        @remove @preview

        @makemovie.mouseEnabled true
        @makemovie.$el.animate { opacity: 1 }, 300, 'linear'
    ###
