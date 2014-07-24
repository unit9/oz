class AbstractScene extends Abstract

    tagName     : 'div'
    className   : 'scene'
    instructions: null
    closeBtn    : null
    boundaries  : null
    boundary    : null

    addLayout : (assetID, localeID, boundaries = null) =>

        @instructions = new Instructions
            "assetID"   : assetID
            "localeID"  : localeID
        @addChild @instructions

        @boundaries = boundaries
        if @boundaries?.debug then @debugBoundary @boundaries
        $(window).bind "click", (e) =>
            if !@instructions.active
                if @boundaries
                    
                    x = ( $(window).width() / 2 ) - ( @boundaries.w / 2 )
                    y = ( $(window).height() / 2 ) - ( @boundaries.h / 2 )

                    if !( e.pageX >= x && e.pageX <= x + @boundaries.w && e.pageY >= y && e.pageY <= y+ @boundaries.h )
                        @onClose()
                else
                    @onClose()

        null

    addCameraHelper : =>
        @helpIconContainer = $('<div class="camera_allow_help"/>')
        @helpCameraIcon = new SSAsset 'interface', 'allow_web'
        @helpIconContainer.append @helpCameraIcon.$el
        @flashIconHelper()
        @addChild @helpIconContainer
        null

    removeCameraHelper : =>
        @helpIconContainer.stop()
        @helpIconContainer.remove()
        null

    flashIconHelper : =>
        @helpIconContainer.animate {opacity : 0}, 500, =>
            @helpIconContainer.animate {opacity : 1}, 500, @flashIconHelper
        null

    debugBoundary: (b) =>

        @boundary = $("<div></div>")
        @boundary.css
            "position" : "absolute"
            "width" : b.w
            "height" : b.h
            "top" : "50%"
            "left" : "50%"
            "margin-left" : - Math.round b.w / 2
            "margin-top" : - Math.round b.h / 2
            "z-index": 1
            "border" : "1px solid red"

        @addChild @boundary
        null

    addCloseButton: =>

        @closeBtn = new Abstract().setElement "<div class='sceneClose'></div>"
        @closeBtn.dispose = () -> null
        @closeBtn.$el.addClass 'button_alpha_enabled'
        # @closeBtn.$el.bind "click", @onClose
        @addChild @closeBtn

        icon = new SSAsset "interface", "button_close"
        @closeBtn.addChild icon

        icon.$el.css
            "width" : "#{parseInt(icon.$el.css('width'))+2}px"
            "height" : "#{icon.$el.height() + 1}px"
            "background-position-y" : "#{parseFloat(icon.$el.css("background-position-y")) + 1}px"

        null

    removeCloseButton: =>
        @remove @closeBtn
        null

    onResize: =>

        if @boundaries?
            if @boundaries.adjustH?
                @boundaries.h = $(window).height() - @boundaries.adjustH
                @boundary?.css
                    "height" : @boundaries.h
                    "margin-top" : - Math.round @boundaries.h / 2
        super()

        null

    onClose: =>
        if !(@oz().appView.static.page instanceof LandingPause)
            $(".scene3d").css { "-webkit-filter": "blur(0px)" }
            @oz().router.navigateTo ''

        null

    addShare : =>
        @trigger 'showShare'
        null

    hideShare : =>
        @trigger 'hideShare'
        null

    dispose : =>
        $(window).unbind "click"

        null