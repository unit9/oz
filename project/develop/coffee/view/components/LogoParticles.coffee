class LogoParticles extends Canvas

    className : 'logoParticles'
    particles : null
    speed     : .6
    paused    : true

    init : =>
        super()

        @mouseEnabled false
        @particles = []

        @paused = true

        @$el.css 
            opacity : 0

        for i in [0..20]

            # p = new Particle 
            #     _x       : @rand 0, @$el[0].width
            #     _y       : @rand 0, @$el[0].height
            #     _canvas  : @context
            #     _w       : @$el[0].width
            #     _h       : @$el[0].height
            #     _maxSize : 1.5
            #     _speed   : @speed
            #     _rect    : {x: 0, y: 0, w: 80, h: 80}
            
            p = new Particle 
                _canvas  : @context
                _w       : @$el[0].width
                _h       : @$el[0].height
                _maxSize : 3
                _speed   : .6
                _type    : 0
                _rect    : {x: 0, y: 0, w: 80, h: 80}

            @particles.push(p)
        return

        null

    onEnterFrame : =>

        return if @paused
            
        @clear()

        for p in @particles
            p.move()
            p.draw()
        return

        null

    show : =>
        @resume()
        @$el.stop().animate
            opacity : 1

        null

    hide : =>
        @$el.stop().animate
            opacity : 0
        , @pause

        null    


    clear :->
        @context.clearRect(0, 0, @$el[0].width, @$el[0].height)
        null


    rand : (low = 0, high = 1) ->
        return (((Math.random() * (high - low)) + low) % high)