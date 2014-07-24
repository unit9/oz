class CutoutView extends Backbone.View

    tagName : 'div'
    cam     : null
    video   : null

    initialize: =>
        @video = new VideoWebCam
        @$el.append @video.$el
        @video.on "VIDEO_COMPLETE", @startRenderVideo
        @video.render()

        @cam = new Cam
        @$el.append @cam.$el
        @cam.render()

        
    startRenderVideo : =>
        @$el.append('<button id="snapshot">Take Snapshot</button>')
        $('#snapshot').css
            position : 'absolute',
            'margin-left' : '600px',
            'margin-top' : '15px'

        $('#snapshot').click => window.open @cam.el.toDataURL "image/jpeg"
        setInterval @drawVideo, 100

    drawVideo :=>
        @cam.renderVideo @video.el
