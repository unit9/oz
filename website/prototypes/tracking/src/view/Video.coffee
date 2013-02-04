class Video extends Backbone.View

    tagName      : "video"
    trackingData : null

    render : (data) =>

        @trackingData = data

        @$el.attr
            'width'    : 640
            'height'   : 480
            'id'       : 'video'
            'autoplay' : 'true'
            'controls' : 'true'

        @$el.append "<source src='videos/track.mp4'>"
        @$el.append "<source src='videos/track.webm'>"
        @$el.append '<track src="videos/captions.vtt" label="English subtitles" kind="subtitles" srclang="en-us" default >'
        @$el.append "your browser doesn't support video"

        @

    enterFrame : (event) =>

        frame = Math.round @el.currentTime * 29.97
        frame = frame.toString()
        frameModel = @trackingData.where frame : frame

        if frameModel.length > 0
            frameModel = frameModel[0]

            $('#trackDiv').show()
            $('#trackDiv').css
                'top'  : (parseFloat(frameModel.get('y')) - 25) + "px"
                'left' : (parseFloat(frameModel.get('x')) - 25) + "px"

        else 
            $('#trackDiv').hide()