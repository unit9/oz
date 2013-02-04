class AppView extends Backbone.View

    tagName    : "body"
    video      : null
    ready      : false
    collection : null
    trackDiv   : null
    fsButton   : null

    initialize : =>

        @init()
        @

    init : =>

        @collection = new FrameCollection()
        @collection.url = "js/tracking.json"
        @collection.fetch
            success : @addVideo
            error : (model, response) ->
                console.log 'error', response


    addVideo :(model, response) =>

        @video = new Video
        $('.container').append @video.$el
        @video.render @collection

        @trackDiv = $("<div id='trackDiv'></div>")
        $('.container').append @trackDiv

        @trackDiv.css
            "position"            : 'absolute',
            "width"               : '50px',
            "height"              : '50px',
            "opacity"             : '.7',
            "background-color"    : '#FF0000'

        @fsButton = $("<br><br><button id='fs' class='btn'>Enter Fullscreen</div>")
        $('.container').append @fsButton

        @fsButton.click =>
            window.fullScreenApi.requestFullScreen @video.el

        @ready = true


    enterFrame : =>

        unless !@ready
            @video.enterFrame()