class VideoWebCam extends Backbone.View

    tagName : "video"

    render : =>
        @$el.attr 'width', 566
        @$el.attr 'height', 800
        @$el.attr 'autoplay', "true"

        @$el.css
            position            : 'absolute'
            display             : 'none'

        navigator.getUserMedia 
            video : true,
            audio : true, 
            @onUserMediaSuccess, @onUserMediaError


    onUserMediaSuccess : (stream) =>
        @el.src = window.URL.createObjectURL(stream)
        @trigger "VIDEO_COMPLETE"
        @

    onUserMediaError :=>
        @