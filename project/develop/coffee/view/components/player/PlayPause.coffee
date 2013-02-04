class PlayPause extends Abstract

    className : 'playPauseButton'
    asset     : null
    playing   : true

    init : =>
        @asset = new SSAsset 'interface', 'button_play'
        @addChild @asset
        @$el.addClass 'btanimated'
        @$el.bind 'click', @toggle
        null

    toggle : =>
        if @playing
            @pauseState()
        else 
            @playState()

        @trigger 'clicked'
        null

    dispose : =>
        null

    pauseState : =>
        @asset.changeState 'button_pause'
        @playing = false
        null

    playState : =>
        @asset.changeState 'button_play'
        @playing = true
        null

