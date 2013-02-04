class MusicButtons extends Abstract

    tagName : 'div'
    className : 'musicbox_button_container'

    init : =>

        @left = new SSAsset 'interface', 'pause_left'
        @addChild @left

        # Done
        @done = new SimpleButton "doneMusic", @oz().locale.get('music_done_button')
        @done.on "click", @doneAct
        @addChild @done

        # Share your tune
        @share = new SimpleButton "shareTune", @oz().locale.get('music_share_your_tune')
        @share.on "click", @goShare
        @addChild @share

        @right = new SSAsset 'interface', 'pause_right'
        @addChild @right

        null


    render : =>
        width = Math.max(@done.$el.width(), @share.$el.width())
        @share.$el.width(width)
        @done.$el.width(width)

        null

    doneAct : =>
        @trigger 'doneAct'
        null

    goShare : =>
        @trigger 'goShare'
        null

    togglePlay : =>
        @trigger 'togglePlay'
        null