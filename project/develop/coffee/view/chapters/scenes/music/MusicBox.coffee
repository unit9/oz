class MusicBox extends AbstractScene

    data        : null

    initialize: =>

        if SoundController.userLoop

            @data = SoundController.userLoop

        else

            @data = JSON.parse @oz().baseAssets.get('loopstart').result

        super()

    init: =>

        @addLayout 'instructions_music', 'musicInstructions', { w : 757, h : $(window).height(), debug: false, adjustH: 0 }

        @container = new Abstract().setElement '<div class="musicbox"/>'
        @container.dispose = () -> return
        @addChild @container

        # on window loose focus we stop the music
        $(window).bind 'blur', @looseFocus

        @render()

        null

    render : =>

        @oz().appView.footer.mainMenu.$el.css { display : "none" }
        @oz().appView.logo.disable()

        @instructions.active = true

        @createMusicStep()

        null

    looseFocus : =>

        @table?.stop()     

        null   

    addCreateMusicButton : =>

        @addCloseButton()

        firstState = false

        if @containerFirst
            @containerFirst.$el.empty()
            $('body').unbind "click", @instructionsDismiss
            firstState = false
        else 
            @containerFirst = new Abstract().setElement '<div class="musicbox_firstButtonContainer"/>'
            @containerFirst.dispose = () -> return
            firstState = true

        @containerFirstButton = new Abstract().setElement('<div class="musicbox_createMusicContainer"/>')
        @containerFirstButton.dispose = () -> return
        @containerFirstButton.addChild new SSAsset 'interface', 'pause_left'

        @buttonEnter = new SimpleButton "createMusic", @oz().locale.get 'music_create_music_button'
        @buttonEnter.$el.addClass 'button_alpha_enabled'
        @buttonEnter.on 'click', @createMusicStep

        @containerFirstButton.addChild @buttonEnter
        @containerFirstButton.addChild new SSAsset 'interface', 'pause_right'
        @containerFirst.addChild @containerFirstButton.$el

        @container.addChild @containerFirst

        @containerFirst.hide()
        @containerFirst.show true

        @$el.css
            "background-color" : "rgba(0, 0, 0, 0.0)"

        @closeBtn.$el.bind "click", @cancel

        null


    cancel : =>

        @closeBtn.$el.unbind "click"
        @onClose true

        # Restore background from scene
        @$el.css
            "background-color" : "rgba(0, 0, 0, 0.6)"

        null

    createMusicStep : =>

        # Analytics
        Analytics.track 'music_enter_page', "Google_OZ_Music Box"

        @instructions.show true, =>
            $('body').bind "click", @instructionsDismiss
    

        null

    instructionsDismiss : =>

        $('body').unbind "click", @instructionsDismiss

        @instructions.hide true, @advance

        null

    advance : =>

        @remove @instructions

        @addCloseButton()

        # Stop background music
        SoundController.stopBackgroundMusic()
        SoundController.send "musicbox_start"

        @top = new SSAsset 'interface', 'music_top'
        @top.$el.css {margin : "25px auto"}
        @container.addChild @top

        @table = new MusicBoxTable @data
        @table.on "SHARE", @goShare
        @table.on "fail", @onDone
        @table.on 'playState', @playState
        @table.on 'pauseState', @pauseState
        @container.addChild @table
        @table.addLine()

        @bottomContainer = $('<div class="musicbox_bottomContainer"/>')

        @playBtn = new SSAsset 'interface', 'button_play'
        @playBtn.$el.css
            "width" : "#{parseInt(@playBtn.$el.css("width")) + 1}px"
        
        # Pause button
        @pauseBtn = new SSAsset 'interface', 'button_pause'
        @pauseBtn.$el.css
            "width" : "#{parseInt(@pauseBtn.$el.css("width")) + 1}px"
        @pauseBtn.hide()

        @playPauseBtn = new Abstract().setElement $("<div class='musicbox_autoplay'/>")
        @playPauseBtn.$el.on "click", @table.togglePlay
        @playPauseBtn.addChild @playBtn
        @playPauseBtn.addChild @pauseBtn
        @playPauseBtn.$el.css
            "position": "relative"

        @bottom = new SSAsset 'interface', 'music_bottom'
        @bottom.$el.css {margin : "0 auto"}
        @bottomContainer.append @bottom.$el
        @bottomContainer.append @playPauseBtn.$el

        @container.addChild @bottomContainer

        @buttons = new MusicButtons
        @buttons.on 'doneAct', @onDone
        @buttons.on 'goShare', @table.goShare
        @container.addChild @buttons
        @buttons.render()

        null

    playState : =>

        @playBtn.hide true
        @pauseBtn.show true

        null

    pauseState : =>

        @playBtn.show true
        @pauseBtn.hide true

        null

    onDone : =>

        @table.saveUserLoop()
        SoundController.transition @table.playing, @table.colNo
        @table.stop()

        @onClose()

        null

    goShare: (link) =>

        # Disable pause
        @oz().appView.pauseEnabled = false

        @container.$el.animate {opacity: 0}, 300, 'linear'

        @oz().appView.share.show
            title   : @oz().locale.get("music_nice_tune")
            sub     : @oz().locale.get("music_share_disclaimer")
            back    : @oz().locale.get("music_make_another")
            link    : link
            backCall: @restore
            type    : 'music'

        null

    restore: =>

        # Enable pause
        @oz().appView.pauseEnabled = true

        @container.$el.animate {opacity: 1}, 300, "linear"

        null

    onClose : (cancelling = false) =>

        if !(@oz().appView.static.page instanceof LandingPause)
            
            super()

            if !cancelling
                @table.saveUserLoop()
                SoundController.transition @table.playing, @table.colNo
                @table.stop()

            # Analytics
            Analytics.track 'music_close_section'

            SoundController.send "musicbox_end"

            @oz().appView.footer.mainMenu.$el.css { display : "" }
            @oz().appView.logo.enable()
            @oz().appView.share.hide()

    dispose : =>

        # Enable pause
        @oz().appView.pauseEnabled = true
        
        $(window).unbind "blur", @looseFocus
        @instructions = null
        super()

        null
