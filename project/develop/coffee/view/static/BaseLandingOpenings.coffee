class BaseLandingOpenings extends Abstract

    className : 'staticPage'
    titles    : null
    title     : null
    cta       : null
    dividers  : null
    me        : null
    particles : null
    withParticles : null

    initialize: (title, cta, dividers = true, me = false, particles = true) =>   
        @dividers = dividers
        @title = title
        @cta = cta
        @me = me
        @withParticles = particles

        super()
        null


    init : =>

        if @withParticles
            @particles = new Particles 0, 10, 150, { x: 0, y: 0, w: $(window).innerWidth(), h: $(window).innerHeight() }
            @addChild @particles

        @titles = new OpeningTitles @oz().locale.get(@title), @oz().locale.get(@cta), @dividers
        @addChild @titles

        @mouseEnabled @me

        null

    render : (callback)=>
        @titles.render(callback)
        null

    dispose : =>
        null