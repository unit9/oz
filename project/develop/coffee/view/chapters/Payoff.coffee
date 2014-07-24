class Payoff extends AbstractChapter

    className : "payoff"

    init : ->

        #console.log "start payoff"

        $(window).unbind "blur", @looseFocus

        @video = new VideoPlayer
        @addChild @video
        @video.hide()

        @oz().appView.changeOpening 'final',
            title : "finalHeader",
            cta   : "finalSub"

        @oz().appView.logo.showGoogleLogos()
        @oz().appView.footer.showMenu()

        null


    showVideo: =>

        #console.log 'show video'

        @show true
        @video.show true
        null

    dispose :=>
        null