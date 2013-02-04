class Particles extends Abstract

    tagName     : 'canvas'
    className   : 'particles'
    particles   : null
    paused      : true
    speed       : .6

    pType       : 0
    pMaxSize    : 2
    rectangle   : null
    nParticles  : 150

    initialize : (pType, pMaxSize, nParticles, rectangle) =>

        if pType? then @pType = pType
        if pMaxSize? then @pMaxSize = pMaxSize
        if nParticles? then @nParticles = nParticles
        if rectangle?
            @rectangle = rectangle
        else
            @rectangle = 
                x : 0
                y : $(window).innerHeight() / 3
                w : $(window).innerWidth()
                h : $(window).innerHeight() / 3

        super()
        null

    init : =>

        if !Modernizr.canvas
            return

        @$el[0].width = $(window).innerWidth()
        @$el[0].height = $(window).innerHeight()

        @ctx = @$el[0].getContext('2d')
        @particles = []

        for i in [0..@nParticles]

            if @pType == 0

                p = new Particle 
                    _canvas  : @ctx
                    _w       : @$el[0].width
                    _h       : @$el[0].height
                    _maxSize : @pMaxSize
                    _speed   : @speed
                    _type    : @pType
                    _rect    : @rectangle

                p.reset()

            else if @pType == 1

                

                p = new ParticleCard
                    _canvas  : @ctx
                    _w       : @$el[0].width
                    _h       : @$el[0].height
                    _maxSize : @pMaxSize
                    _speed   : @speed
                    _type    : @pType
                    _rect    : @rectangle

                p.reset()

            @particles.push(p)

        @paused = false
        null


    onEnterFrame : =>

        if !Modernizr.canvas
            return

        @clear()

        for p in @particles
            p.move()
            p.draw()

        null

    dispose : =>
        null


    clear :->
        @ctx.clearRect(0, 0, @$el[0].width, @$el[0].height)
        null


    rand : (low = 0, high = 1) ->
        return (((Math.random() * (high - low)) + low) % high)

    onResize : =>

        if !Modernizr.canvas
            return

        @$el[0].width = $(window).innerWidth()
        @$el[0].height = $(window).innerHeight()
        null
