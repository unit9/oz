class Cutout extends AbstractScene

    video   : null
    canvas  : null
    charStd : null
    coords  : null

    prevButton       : null
    nextButton       : null
    takePicButton    : null
    cameraViewFinder : null
    vignette         : null
    current          : 1
    state            : 0
    textureSize      : null
    camSize          : null

    currentPic  : null

    polaroid : null
    
    # assetsBatch : ['cutoutAssets']

    init : =>

        @camSize = [186, 140]

        @coords = []

        @textureSize = [429, 595]

        @coords.push
            xx : 0
            yy : 0
            o  : 0
            x  : (@textureSize[0] / 2 ) + 30
            y  : (@textureSize[1] / 2)

        @coords.push
            xx : 0
            yy : @textureSize[1]
            o  : -90 * (Math.PI/180)
            x  : 295
            y  : 775

        @coords.push 
            xx : @textureSize[0]
            yy : 0
            o  : 0
            x  : @textureSize[0] + (@textureSize[0] / 2) + 30
            y  : @textureSize[1] / 2


        @render()
        
        null

    onClose: =>

        if !(@oz().appView.static.page instanceof LandingPause)

            Analytics.track 'cutout_close_section'

            SoundController.send "cutout_end"

            @restoreMenu()

            @canvas.paused = true
            @canvas.renderTexture true

            @oz().appView.share.hide()
            @oz().appView.subLoader.hide()
            
            super()

        null

    onAssetsComplete : =>
        @render()
        super()
        null

    render : =>

        @oz().appView.footer.mainMenu.$el.css { display : "none" }
        @oz().appView.logo.disable()

        @addLayout 'instructions_cutout', 'cutoutSub', { w : 800, h : $(window).height(), debug: false, adjustH: 50 }

        @instructions.show true, =>
            @addCameraHelper()
            @video = @oz().cam
            @video.on "CAM_READY", @startRenderVideo
            @video.on "CAM_FAIL", @onCamFail
            @video.init()

        Analytics.track 'cutout_enter_page'

        null


    onCamFail : =>

        @removeCameraHelper()

        image = new SSAsset "interface", "instructions_warning"
        image.css {"margin" : "0 auto"}

        @instructions.hide false

        @instructions.$el.find('.box').find('#c22').empty()
        @instructions.$el.find('.box').find('#c22').append image.$el
        @instructions.$el.find('.box').find('#c22').append("<p>#{@oz().locale.get('no_webcam_copy')}</p>")

        imageFooter = new SSAsset "interface", "pause_bottom"
        imageFooter.css {"margin" : "0 auto"}
        @instructions.$el.find('.box').find('#c22').append imageFooter.$el

        @instructions.show true, =>
            $('body').bind 'click', @onCamFailClose

        null
                

    onCamFailClose : =>
        $('body').unbind 'click', @onCamFailClose
        Analytics.track 'cutout_deny_camera'
        SoundController.send "cutout_end"

        @restoreMenu()

        @video.off "CAM_READY", @startRenderVideo
        @video.off "CAM_FAIL", @onCamFail
        @video.dispose()

        @oz().router.navigateTo ''

        null


    restoreMenu : =>

        @oz().appView.footer.mainMenu.$el.css { display : "" }
        @oz().appView.footer.mainMenu.show true

        @oz().appView.logo.enable()
        null

    startRenderVideo : (event) =>

        @removeCameraHelper()

        Analytics.track 'cutout_allow_camera', "Google_OZ_HoleInFace_EngagementClick"

        @addCloseButton()

        @polaroid = new CutoutPolaroid
        @polaroid.on 'onPolaroidOz', @onPolaroidOz
        @addChild @polaroid

        @flash = $('<div class="cutout_flash" />')
        @addChild @flash

        @$el.animate
            'background-color' : 'rgba(0,0,0,0)', 500, =>
                            
                @video.off "CAM_READY", @startRenderVideo
                @video.off "CAM_FAIL", @onCamFail

                @instructions.hide true, @addInterface

        null

    addInterface : =>

        SoundController.send "cutout_start"

        @remove @instructions

        @canvas = new CutoutCanvas
        @addChild @canvas

        @canvas.setup
            textureS : @textureSize
            camSize  : @camSize
            coords   : @coords[@current]
            videoSrc : @video.get()
            img      : @oz().baseAssets.get('cutout_normal').result
            imgOz    : @oz().baseAssets.get('cutout_oz').result

        @contButtonsCont   = new Abstract().setElement($("<div/>"))
        @contButtonsCont.$el.addClass 'cutout_button_container_center'
        @contButtonsCont.dispose = () -> null
        @addChild @contButtonsCont

        @contButtons   = new Abstract().setElement($("<div/>"))
        @contButtons.$el.addClass 'cutout_button_container'
        @contButtons.dispose = () -> null
        @contButtonsCont.addChild @contButtons

        @addTakePictureButtons()

        @addShare()
        null


    onKeyPress : (event) =>
        if event.which == 32
            event.preventDefault()
            @takePicture()

        null

    addTakePictureButtons : =>

        @$el.css {'background' : 'rgba(0,0,0,0)'}
        
        @state = 0

        @contButtons.empty()

        @prevButton    = new SSAsset 'interface', 'button_prev'
        @prevButton.$el.addClass 'button_alpha_enabled'
        @prevButton.$el.bind 'click', @backButtonClick
        @prevButton.$el.css {'margin-right' : '15px'}

        @nextButton    = new SSAsset 'interface', 'button_next'
        @nextButton.$el.addClass 'button_alpha_enabled'
        @nextButton.$el.bind 'click', @nextButtonClick
        @nextButton.$el.css {'margin-left' : '15px'}

        @takePicButton = new SimpleButton "pictureBtn", @oz().locale.get 'cutoutPicBtn'
        @takePicButton.on 'click', @takePicture

        @contButtons.addChild @prevButton
        @contButtons.addChild @takePicButton
        @contButtons.addChild @nextButton

        $(window).bind 'keypress', @onKeyPress

        @canvas.reset()
        null

    addShareButtons : =>

        @state = 1

        @contButtons.empty()

        @polaroid.addShareButtons(@shareClick, @tryAgainClick)
        @$el.css {'background' : 'rgba(0,0,0,0)'}

        null
        

    tryAgainClick : =>

        @polaroid.shareButton.off 'click'
        @polaroid.tryAgainButton.off 'click'

        # Enable pause
        @oz().appView.pauseEnabled = true

        Analytics.track 'cutout_take_another'
        @contButtonsCont.hide true, => 
            $(".scene3d").css { "-webkit-filter": "blur(0px)" }
            @canvas.reset()
            @addTakePictureButtons()
            @changeButtonsState()
            @polaroid.animateOut =>
                @contButtonsCont.show true, null, 300

        null

    takePicture : =>

        # Disable pause
        @oz().appView.pauseEnabled = false

        $(".scene3d").css { "-webkit-filter": "blur(10px)" }

        Analytics.track 'cutout_take_picture'

        SoundController.send "cutout_photo"

        $(window).unbind 'keypress', @onKeyPress

        @polaroid.update(@canvas.getPhoto(true), @canvas.getPhoto(true, true))

        @contButtonsCont.hide true, null , 200, "linear", true
        @flash.animate {'opacity' : 1}, 100, =>
            @flash.animate {'opacity' : 0}, 400, => 
                @polaroid.animateIn()

        null
        

    onPolaroidOz : (event) =>
        @addShareButtons()
        null

    shareClick : =>

        @polaroid.shareButton.off 'click'
        @polaroid.tryAgainButton.off 'click'

        Analytics.track 'cutout_click_share'
        
        @oz().appView.subLoader.show true

        data = @canvas.getPhoto false, true
        Requester.addImage data, "cutout", @requestSaveDone, @fail

        null

    fail : =>
        @tryAgainClick()
        @oz().appView.subLoader.showError()
        null


    requestSaveDone : (event) =>
        url = window.location.origin + "/preview/cutout/" + event.result.id
        Requester.shortURL url, @showShareBox, @fail

        null


    showShareBox : (event) =>

        @oz().appView.subLoader.hide()

        @$el.css {'background-color' : 'rgba(0,0,0,.6)'}

        @oz().appView.share.show
            title   : @oz().locale.get("cutoutCTA")
            sub     : @oz().locale.get("shareBoxSubCutout")
            back    : @oz().locale.get("shareBoxBackCutout")
            link    : event.id
            backCall: @tryAgainClick
            type    : 'cutout'

        null


    changeButtonsState : =>
        @enableButtons()

        if @current == 2
            @nextButton.mouseEnabled false
            @nextButton.$el.addClass 'button_alpha_disabled'
            @nextButton.$el.css {'visibility' : 'hidden'}


        if @current == 0
            @prevButton.mouseEnabled false
            @prevButton.$el.addClass 'button_alpha_disabled'
            @prevButton.$el.css {'visibility' : 'hidden'}

        null


    enableButtons : =>
        @nextButton.mouseEnabled true
        @nextButton.$el.removeClass 'button_alpha_disabled'
        @nextButton.$el.css {'visibility' : 'visible'}

        @prevButton.mouseEnabled true
        @prevButton.$el.removeClass 'button_alpha_disabled'
        @prevButton.$el.css {'visibility' : 'visible'}

        null


    nextButtonClick : =>
        @current++

        @changeButtonsState()
        @moveCamera()

        @canvas.changeCamera @coords[@current]

        null

    backButtonClick : =>
        @current--

        @changeButtonsState()
        @moveCamera()

        @canvas.changeCamera @coords[@current]

        null


    moveCamera : =>

        SoundController.send "cutout_switch"

        switch @current
            when 0
                @oz().appView.area.changeCutout 'left'

            when 1
                @oz().appView.area.changeCutout 'middle'

            when 2
                @oz().appView.area.changeCutout 'right'

        null
        

    dispose : =>

        # Enable pause
        @oz().appView.pauseEnabled = true
        
        super()
        @instructions = null
        @video?.dispose()

        null
        