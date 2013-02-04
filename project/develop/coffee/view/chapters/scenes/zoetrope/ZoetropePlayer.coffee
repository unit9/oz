class ZoetropePlayer extends Abstract

    className       : "player"

    data            : null
    timer           : null
    transitionTime  : 100
    currentX        : 0
    
    w               : 600
    numberOfPictures: 12

    init: =>
        @$el.css { opacity: 0 }
        null

    showAndPlay: ( canvas ) =>

        @$el.animate {"opacity" : 1.0}, 700

        @$el.css {"background-image": "url(#{ canvas[0].toDataURL "image/jpeg" })"}
        @play()
        null

    nextFrame: =>

        @$el.css { "background-position-x" : "#{@currentX}px" }
        @currentX -= @w
        
        if @currentX <= - @w * @numberOfPictures
            @currentX = 0
        null

    play: =>
        clearInterval @timer
        @timer = setInterval (=> @nextFrame()), @transitionTime
        null

    stopIt: =>
        clearInterval @timer
        null

    gotoFrame: ( frame ) =>
        
        @stopIt()
        @currentX = - ( frame * @w )
        @$el.css { "background-position-x" : "#{@currentX}px" }
        null