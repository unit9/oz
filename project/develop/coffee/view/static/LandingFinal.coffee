class LandingFinal extends BaseLandingOpenings

    checkBox : null

    init: =>
        super()

        @mouseEnabled true

        header = new Abstract
        header.dispose = () => return
        header.$el.addClass 'bigDividers'
        header.$el.css {}

        ### Dividers ###

        topEnding = new SSAsset 'interface', 'final_end_top'

        bottom = $('<div class="containerBottom" />')
        bigDividerBottom = new SSAsset 'interface', 'bottomheader'
        bigDividerBottom.$el.css {display: 'table-cell'}
        bottom.append bigDividerBottom.$el

        header.addChild topEnding

        @titles.$el.find('.openingTitlesHeader').css {'margin-top' : '0'}
        
        buttonContainer = $('<div class="finalButtonContainer"/>')

        buttonTrailer = new SimpleButton "trailer", @oz().locale.get 'finalBtnTrailer'
        buttonTrailer.on 'click', @onTrailerClick

        buttonContainer.append buttonTrailer.$el
        buttonContainer.append '<br>'

        buttonReset = new SimpleButton "reset", @oz().locale.get 'finalBtnReset'
        buttonReset.on 'click', @onResetClick
        buttonContainer.append buttonReset.$el

        # Make the buttons with the same width
        setTimeout () =>
            w = Math.max buttonTrailer.$el.width(), buttonReset.$el.width()
            buttonTrailer.$el.width w
            buttonReset.$el.width w
        ,300

        @titles.$el.find('.openingTitlesCTA').addClass 'openingTitlesCTAFinal'
        #@titles.$el.find('.openingTitlesCTA').css {'margin-top' : '-15px'}
        @titles.$el.find('.openingTitlesCTA').find('.cta p').css {"cursor" : "default"}

        contFluf = $('<div class="ctaFlufFinal"/>')

        fluf = new SSAsset 'interface', 'pause_bottom'
        fluf.$el.css {'margin' : '38px auto 0 auto'}
        contFluf.append fluf.$el
        @titles.$el.find('.openingTitlesCTA').append contFluf
        
        @titles.addChild buttonContainer

        header.$el.insertAfter(@titles.$el.children()[0])

        @titles.fluorish.$el.remove()
        @titles.diamond.$el.remove()
        null

    onResetClick : =>

        Analytics.track 'payoff_playagain'        
        
        # TODO Talk with dani about Carnival.coffee load again
        document.location.href = "http://" + document.location.host

        # @oz().appView.loaded = null
        # @oz().router.navigateTo ""
        # @oz().appView.footer.hideMenu()

        null

    onTrailerClick : =>

        Analytics.track 'payoff_watch_trailer'

        @oz().appView.area.showVideo()

        null