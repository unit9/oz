class Logo extends Abstract

    id         : 'logo'
    obj        : null
    chromeLogo : null
    googleLogo : null


    init : =>

        @canvas = new LogoParticles 80, 80

        @logoContainer = $("<div class='logo'/>")

        @assetLogo = new SSAsset 'interface', 'logo_oz'
        @assetLogoOver = new SSAsset 'interface', 'logo_oz_over'
        @assetLogoOver.hide false

        @logoContainer.append @assetLogo.$el
        @logoContainer.append @assetLogoOver.$el

        @addChild @logoContainer

        @addChild @canvas
        @canvas.init()

        @chromeLogo = new SSAsset 'interface', 'logo_chrome'
        @chromeLogo.addClass 'chrome'
        @chromeLogo.addClass 'button_alpha_enabled'
        @chromeLogo.$el.bind 'click', =>
            Analytics.track 'click_chrome_logo'
            window.open 'http://www.chromeexperiments.com/'
        
        @addChild @chromeLogo

        @googleLogo = new SSAsset 'interface', 'logo_google'
        @googleLogo.addClass 'google'
        @googleLogo.addClass 'button_alpha_enabled'
        
        @googleLogo.$el.bind 'click', =>
            Analytics.track 'click_friends_google'
            window.open 'http://google.com/'
        @addChild @googleLogo

        @enable()
        null

    hideGoogleLogos : =>

        @googleLogo.$el.removeClass 'button_alpha_enabled'
        @chromeLogo.$el.removeClass 'button_alpha_enabled'

        @chromeLogo.hide true, null, 400, "linear", true
        @googleLogo.hide true, null, 400, "linear", true

        null

    showGoogleLogos : =>

        @chromeLogo.show true, null, 400, "linear"
        @googleLogo.show true, =>

            if @googleLogo.$el.hasClass 'button_alpha_enabled'
                @googleLogo.$el.removeClass 'button_alpha_enabled'
                @chromeLogo.$el.removeClass 'button_alpha_enabled'

            @googleLogo.$el.addClass 'button_alpha_enabled'
            @chromeLogo.$el.addClass 'button_alpha_enabled'
            
        , 400, "linear"

        null


    logoRollOver : =>
        @canvas.show()
        @assetLogoOver.show true, null, 200
        @assetLogo.hide true, null, 200

        null

    logoRollOut : =>
        @canvas.hide()
        @assetLogoOver.hide true, null, 200
        @assetLogo.show true, null, 200

        null


    onClick: =>
        
        # TODO Talk with dani about Carnival.coffee load again
        # document.location.href = "http://" + document.location.host

        @canvas.hide()
        @assetLogoOver.hide true, null, 200
        @assetLogo.show true, null, 200
        
        @oz().router.navigateTo 'carnival', false
        null

    disable : =>
        @logoContainer.unbind "click"
        @logoContainer.css { "cursor" : "default" }
        @logoContainer.unbind "mouseover"
        @logoContainer.unbind "mouseout"
        null

    enable : =>
        @disable()
        @logoContainer.bind "click", @onClick
        @logoContainer.css { "cursor" : "pointer" }
        @logoContainer.bind "mouseover", @logoRollOver
        @logoContainer.bind "mouseout", @logoRollOut
        null

    dispose: =>
        @logoContainer.unbind "mouseover"
        @logoContainer.unbind "mouseout"
        @logoContainer.unbind "click"

        null