class Loading extends AbstractScene

    angleX  : 0
    angleY  : 0
    card    : null
    copy    : null
    state   : 0

    timerChange : null
    out : false

    particles : null

    containerCopy : null

    top : null
    bottom : null
    copySwitcher : null

    c : null
    t : null
    s : null
    x : null
    y : null

    visible : null

    disclaimer : [
        {
            s: "loading_magician",
            t: 4
        },
        {
            s: "loading_wizard",
            t: 4
        },
        {
            s: "loading_copy",
            t: 4
        },
        {
            s: "loading_uncover",
            t: 4
        }
    ]

    currentDisclaimer: 0
    
    init : =>

        @particles = new Particles 1, 20, 80, { x: 0, y: 0, w: $(window).innerWidth(), h: $(window).innerHeight() } 
        # { x: $(window).innerWidth() / 3, y: $(window).innerHeight() / 4, w: $(window).innerWidth() / 3, h: $(window).innerHeight() / 2}
        @addChild @particles
        @particles.hide()
        setTimeout @particles.show, 500, true

        @card = new LoadingCard
        @addChild @card

        @$el.addClass 'landingPage'

        @containerCopy = $('<div class="loadingCopy"/>')

        @top = new SSAsset 'interface', 'swosh_up'
        @top.$el.css {'margin' : '0 auto'}
        @containerCopy.append @top.$el

        @copy = $('<div class="loadingCardCopy"><div></div></div>')
        @containerCopy.append @copy

        @bottom = new SSAsset 'interface', 'swosh_down'
        @bottom.$el.css {'margin' : '0 auto'}
        @containerCopy.append @bottom.$el

        @addChild @containerCopy

        @render()
        null

    changeCopy : =>

        @c = @disclaimer[@currentDisclaimer].s
        @t = @disclaimer[@currentDisclaimer].t

        @copy.animate {'opacity' : '0'}, 200, 'linear', =>

            @s = @oz().locale.get(@c)
            @copy.find('div').html @s.toUpperCase()
            @copy.animate {'opacity' : '1'}, 200

        @currentDisclaimer++
        if @currentDisclaimer >= @disclaimer.length
            @currentDisclaimer = 0

        @copySwitcher = setTimeout @changeCopy, @t * 1000
        null

    render : =>
        @card.animateIn @onAnimateIn
        null

    update : (perc) =>
        @card.update perc
        null

    onAnimateIn : =>

        @changeCopy()
        
        $(window).bind 'mousemove', @onMouseMove
        $(window).bind 'click', @onClick

        @containerCopy.animate {opacity: 1}, 500, 'linear', =>
            @timerChange = setTimeout @onClick, 8000, null
            @oz().appView.footer.shareMenu.render()

        null

    onAnimateOut : (callback) =>
        @out = true
        clearInterval @timerChange
        clearInterval @copySwitcher

        $(window).unbind 'mousemove', @onMouseMove
        $(window).unbind 'click', @onClick

        @containerCopy.animate {opacity: 0}, 700, 'linear', =>
            @card.animateOut () => 
                @containerCopy.remove()
                @remove @card
                callback()

        null

    hide : (anim = false, callback = null) =>
        @visible = false

        if !anim
            @$el.css {opacity : 0}
        else 
            @$el.animate {opacity: 0}, 800, 'linear', callback

        null

    onMouseMove : (event) =>

        unless !@paused
            return
            
        @x = (((event.clientX - ($(window).innerWidth() / 2) )) / 40) 
        @y = (((event.clientY - ($(window).innerHeight() / 2) )) / 35)

        @angleX += (@x - @angleX) * .075
        @angleY += (@y - @angleY) * .075

        @angleX = @angleX % 360
        @angleY = @angleY % 360

        @card.transform @angleX, @angleY

        null

    onClick : (event) =>
        return if @out
        clearInterval @timerChange
        @timerChange = setTimeout @onClick, 8000

        @card.toggleTopple()

        null

    dispose : =>
        @particles.pause()
        @remove @particles
        clearInterval @timerChange        
        null

    