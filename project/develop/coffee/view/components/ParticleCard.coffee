class ParticleCard
    
    dx      : 0
    dy      : 0
    x       : 0
    y       : 0
    r       : 0
    canvas  : null
    w       : 0
    h       : 0
    image   : null
    alpha   : 0
    rColour : 1
    mult    : 1
    minSize : 0.8
    maxSize : 0
    type    : null
    rect    : null
    fading  : false
    gradient : null

    constructor : (args) ->

        @speed   = args._speed
        @maxSize = args._maxSize
        @canvas  = args._canvas
        @w       = args._w
        @h       = args._h
        @type    = args._type
        @rect    = args._rect

        @r = @rand @minSize, @maxSize

        @dx = @rand -@speed, @speed
        @dy = @rand -@speed, @speed
        null
    
    draw : =>

        switch @type

            when 0

                @canvas.beginPath()
                @canvas.fillStyle = 'rgba(255,255,255,'+@rColour+')' 
                @canvas.arc(@x, @y, @r, 0, Math.PI * 2, true)
                @canvas.closePath()
                @canvas.fill()

            when 1
            
                @drawParticle @x, @y, @r, 'rgba(247,234,155,'+@rColour.toFixed(2)+')', 'rgba(255,204,0,0)'

        if !@fading then @rColour -= .005 * @mult
        null

    drawParticle : (x, y, radius, color1, color2) =>

        @gradient = @canvas.createRadialGradient x, y, 0, x, y, radius
        @gradient.addColorStop 0, color1
        @gradient.addColorStop 1, color2

        @canvas.fillStyle = @gradient
        @canvas.fillRect x - radius, y - radius, radius * 2, radius * 2
        null

    rand : (low = 0, high = 1) =>
        return (((Math.random() * (high - low)) + low) % high)

    move : () =>

        @x += @dx
        @y -= @dy

        if @rColour < 0 || @rColour > @alpha
            @mult *= -1

        #### RESET PARTICLE
        if ( @x > @rect.w + @rect.x ) || (@x < @rect.x) || ( @y > @rect.h + @rect.y ) || ( @y < @rect.y )
            @fadeOut()

        null

    reset : =>

        @x = @rand (@rect.w / 2 + @rect.x) - 150, (@rect.w / 2 + @rect.x) + 150
        @y = @rand (@rect.h / 2 + @rect.y) - 250, (@rect.h / 2 + @rect.y) + 250

        @dx = @rand -@speed, @speed
        @dy = @rand -@speed, @speed

        @r = @rand @minSize, @maxSize
        @alpha = 1 - MathUtils.map @r, @minSize, @maxSize, 0, 1 # @rand 0, 1
        @rColour = @alpha

        null

    fadeOut : =>

        @fading = true
        @rColour -= 0.005
        if @rColour <= 0
            @fading = false
            @reset()

        null

