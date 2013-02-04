class LandingPause extends BaseLandingOpenings

    particles : null

    init: =>
        @particles = new Particles 0, 7, 40, { x: 0, y: $(window).innerHeight() / 3, w: $(window).innerWidth(), h: $(window).innerHeight() / 3 }
        @addChild @particles

        @titles = new OpeningTitles @oz().locale.get('politePause'), @oz().locale.get('politePauseCTA'), @dividers, true
        @addChild @titles

        @titles.$el.find('.openingTitlesCTA').addClass 'openingTitlesCTAFinal'
        @titles.$el.find('.openingTitlesCTA').find('.cta').css {'margin-top' : '0px'}
        
        $(@titles.$el.children()[0]).css
            'margin-top' : '-45px'

        @titles.$el.find('.openingTitlesCTA').css
            'margin-top' : '-5px'

        @titles.$el.find('.openingTitlesCTA').find('.left').css
            'margin-top' : '0px'

        @titles.$el.find('.openingTitlesCTA').find('.right').css
            'margin-top' : '0px'

        @titles.diamond.$el.css {'margin-top' : '-35px'}

        @mouseEnabled @me
        null

    dispose : =>
        null