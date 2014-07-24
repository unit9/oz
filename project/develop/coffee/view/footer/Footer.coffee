class Footer extends Abstract

    id        : 'footer'
    shareMenu : null
    mainMenu  : null
    ratings   : null
    cr        : null

    init : =>
        @shareMenu = new ShareMenu
        @addChild @shareMenu

        @mainMenu = new MainMenu
        @addChild @mainMenu
        @mainMenu.mouseEnabled false
        @mainMenu.hide()
        @mainMenu.$el.css { "display" : "none" }

        @ratings = new Ratings
        @addChild @ratings

        @cr = new Copyright
        @cr.mouseEnabled false
        @addChild @cr
        @cr.hide()
        null

    ###
    setState: (state) =>

        switch state
            when 0
                @oz.appView().logo.show()
                @oz.appView().logo.showGoogleLogos()

                @ratings.show true
                
                @mainMenu.hide true, =>
                    @mainMenu.$el.css { "display" : "none" }

                @shareMenu


                @
            when 1
                @oz.appView().logo.hideGoogleLogos()
                
                @mainMenu.$el.css { "display" : "" }
                @mainMenu.show true

                @
    ###
    
    show : (animated) =>
        @mainMenu.$el.css { "display" : "" }
        super animated
        null

    hide : (animated) =>
        super animated, =>
            @mainMenu.$el.css { "display" : "none" }
        null


    showShare : =>
        @cr.hide()
        @cr.mouseEnabled false
        @shareMenu.$el.css { "display" : "" }
        @shareMenu.show true
        null

    showCC : =>
        @remove @ratings

        @mainMenu.show()

        @cr.mouseEnabled true
        @cr.show()
        
        @shareMenu.hide()
        @shareMenu.$el.css { "display" : "none" }
        null

    showMenu : (mouseEnabled = false) =>
        @remove @ratings

        @mainMenu.show()
        @mainMenu.showMenu()
        @mainMenu.disableMouseMove mouseEnabled
        null

    hideMenu : =>
        @mainMenu.hideMenu()
        null

    disableOver : (val) =>
        @mainMenu.disableMouseMove val
        null