class LoadingCard extends Abstract

    className      : 'card'
    frontImage     : null
    containerFront : null
    containerBack  : null
    cardWidth      : 228
    cardHeight     : 333
    counter        : 0
    flipped        : false
    flipping       : false

    percTop : null
    percBot : null

    rotation : null

    angle : null

    init : =>
        @containerFront = new SSAsset 'interface', 'preloader_front'
        @containerFront.addChild $('<span class="percLoadingTop">00%</span>')
        @containerFront.addChild $('<span class="percLoadingBottom">00%</span>')
        @containerFront.$el.addClass 'cardImg'

        @containerBack  = new SSAsset 'interface', 'preloader_back'
        @containerBack.$el.addClass 'cardImgBack'
        
        @containerFront.$el.css {display : 'none'}

        @percTop = @containerFront.$el.find '.percLoadingTop'
        @percBot = @containerFront.$el.find '.percLoadingBottom'

        @addChild @containerFront
        @addChild @containerBack


    update : (perc) => 

        if perc == NaN or perc == Infinity
            perc = 0

        if perc >= 99
            perc = 99
        
        p = if perc < 10 then "0" + perc.toFixed(0) else perc.toFixed(0)

        @percTop.html p + "%"
        @percBot.html p + "%"


    transform : (x, y, time = 0, ease = 'linear', callback = null) =>
        @$el.transition
            perspective: @cardHeight
            rotateY: x
            rotateX: y
            , time, ease, callback

    animateIn : (onComplete) =>

        SoundController.send 'card_in'

        @transform -360, -20
        @$el.transition 
            scale : 0, 0

        @$el.transition 
            perspective: @cardHeight
            rotateY: -270
            scale : .5, 400, 'in', =>

                @containerFront.css {display : 'block'}
                @containerBack.css  {display : 'none' }

                @$el.transition 
                    perspective: @cardHeight
                    rotateY: 0
                    rotateX: 0
                    scale : 1, 500, 'ease', onComplete
        

    animateOut : (onComplete) =>

        SoundController.send "card_out"

        @$el.transition 
            perspective: @cardHeight
            rotateY: 0
            rotateX: -90
            scale : 1, 600, 'in', =>

                @containerFront.css {display : 'none'}
                @containerBack.css  {display : 'block' }

                @$el.transition 
                    perspective: @cardHeight
                    rotateY: 90
                    rotateX: -180
                    scale : 0.8, 200, 'linear', =>

                        @containerFront.css {display : 'block'}
                        @containerBack.css  {display : 'none' }

                        @$el.transition 
                            perspective: @cardHeight
                            rotateY: 270
                            rotateX: -150
                            scale : 0.6, 200, 'out', onComplete


    toggleTopple : (callback) ->
        return if @flipping

        SoundController.send "card_flip"

        @rotation = @getRotationDegrees()

        @flipping = true

        @containerBack.$el.transition {'rotate': @rotation}, =>
            @resetRotation
            callback?(if @flipped then 1 else 0 )
        @containerFront.$el.transition {'rotate': @rotation}, @resetRotation

    resetRotation : =>
        if(@flipped == false)
            @containerBack.$el.transition {'rotate': 0}, 0
            @containerFront.$el.transition {'rotate': 0}, 0

        @flipping = false

    getRotationDegrees : ->
        @angle = if @flipped then 359 else 180
        @flipped = !@flipped
        @angle

    dispose : =>
        @




