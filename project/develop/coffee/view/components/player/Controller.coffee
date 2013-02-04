class Controller extends Abstract

    className   : 'controller'
    progressBar : null 
    scruber     : null
    bg          : null
    border      : null

    pausePlayButton : null

    init : =>

        @pausePlayButton = new PlayPause
        @pausePlayButton.on 'clicked', @toggleVideo
        @addChild @pausePlayButton

        @progressBar = new Abstract
        @progressBar.dispose - => null
        @addChild @progressBar
        @progressBar.$el.addClass 'progressBar'

        @border = new SSAsset 'interface', 'video_progress_border'
        @progressBar.addChild @border

        @bg = new SSAsset 'interface', 'video_progress_background'
        @progressBar.addChild @bg

        @scruber = new SSAsset 'interface', 'video_progress_scrubber'
        @progressBar.addChild @scruber

        @width = parseInt(@scruber.$el.css('width'))
        null

    toggleVideo : =>
        @trigger 'toggleVideo'
        null

    progress : (val) =>

        @scruber.$el.css
            width : @width * val
        null

    playState : =>
        @pausePlayButton.playState()
        null

    pauseState : =>
        @pausePlayButton.pauseState()
        null

        


        