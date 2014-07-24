class MenuCircle

    view    : null
    diamond : null
    circle  : null
    radius  : null
    fill    : null
    glow    : null
    icon    : null

    currentState  : null
    tween         : null
    clicked       : false

    targetY : null
    current : null

    constructor : (x, y, r, images, stroke) ->

        _.extend @, Backbone.Events

        @radius = r
        @fill = images.fill

        @targetY = y
        @current = {y : 200}

        @currentState = {radius : @radius, stroke : stroke, alpha : 0}

        @view = new createjs.Container

        @view.onMouseOver = (e) =>
            return if @clicked
            @animateCircle(r + (r * .25))
            $('#containerMenu canvas').css {cursor : 'pointer'}

        @view.onMouseOut = (e) =>
            return if @clicked
            @animateCircle @radius
            $('#containerMenu canvas').css {cursor : ''}

        @view.onClick = (e) =>
            @trigger 'click', @
            $('#containerMenu canvas').css {cursor : ''}

        @glow = new createjs.Bitmap images.glow
        @glow.regX = 98 / 2
        @glow.regY = 97 / 2
        @glow.alpha = 0

        @view.addChild @glow

        @view.x = x
        @view.y = @current.y

        @circle = new createjs.Shape()
        @draw r, stroke
            
        @view.addChild @circle

        @

    disable : (val = true) =>
        if val
            @glowAnimate 1
            @clicked = true
        else 
            @animateCircle @radius
            @glowAnimate 0
            @clicked = false


    addDiamond : (size = 10) =>
        @glow.scaleX = @glow.scaleY = .35
        @diamond = new createjs.Shape
        @diamond.graphics.beginFill('#FFF').drawRect(-size/2, -size/2, size, size)
        @diamond.rotation = -45
        @view.addChild @diamond


    addIcon : (icon) =>
        @glow.scaleX = @glow.scaleY = .59
        @icon = new createjs.Bitmap icon
        @icon.regX = 10
        @icon.regY = 10
        @icon.scaleX = @icon.scaleY = .68
        @view.addChild @icon


    draw : (r, stroke) =>
        @circle.graphics.clear()
        @circle.graphics.setStrokeStyle stroke
        if @fill
            @circle.graphics.beginBitmapFill @fill
        @circle.graphics.beginStroke('#FFFFFF').drawCircle(0, 0, @currentState.radius)

    animateCircle : (radius, alpha = 0) =>
        @tween = new TWEEN.Tween(@currentState).to({ radius: radius, alpha: alpha}, 200 ).easing( TWEEN.Easing.Quadratic.Out )
        @tween.onUpdate (e) => 
            @draw @currentState.radius, @currentState.stroke

        @tween.start()

    glowAnimate : (alpha) =>
        @tween = new TWEEN.Tween(@currentState).to({ alpha: alpha}, 400 ).easing( TWEEN.Easing.Quadratic.Out )
        @tween.onUpdate (e) => 
            @glow.alpha = @currentState.alpha

        @tween.start()


    animateIn : (delay) =>
        @tween = new TWEEN.Tween(@current).to({ y: @targetY }, 600 ).easing( TWEEN.Easing.Back.Out ).delay(delay)
        @tween.onUpdate (e) => 
            @view.y = @current.y

        @tween.start()

