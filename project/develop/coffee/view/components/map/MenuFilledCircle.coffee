class MenuFilledCircle

    view    : null
    circle  : null
    radius  : null
    
    currentState  : null
    tween         : null
    
    targetY : null
    current : null
    id : null
    arrow : null

    icon : null
    iconAsset : null

    glowAsset : null
    glow : null

    constructor : (x, y, r, scale, icon, glow) ->

        _.extend @, Backbone.Events

        @radius = r
        @iconAsset = icon

        @glowAsset = glow

        @targetY = y
        @current = {y : 400}

        @currentState = {radius : @radius, stroke : 4, alpha : 0, rotation : 0}

        @view = new createjs.Container
        @view.x = x
        @view.y = @current.y

        @view.onMouseOver = (e) =>
            return if @clicked
            @animateCircle(r + (@radius * .25))
            @trigger 'rollover', 'rollover'

        @view.onMouseOut = (e) =>
            return if @clicked
            @animateCircle @radius
            @trigger 'rollout', 'rollout'
            
        @view.onClick = (e) =>
            @animateCircle @radius
            @trigger 'click', @

        @circle = new createjs.Shape()
        @draw @radius, @currentState.stroke

        @icon = new createjs.Bitmap @iconAsset
        @icon.regX = @icon.regY = 17
        @icon.scaleX = @icon.scaleY = scale

        @glow = new createjs.Bitmap @glowAsset
        @glow.regX = 149 / 2
        @glow.regY = 149 / 2
        @glow.scaleX = @glow.scaleY = scale
        @glow.alpha = 0

        @view.addChild @circle
        @view.addChild @icon
        @view.addChild @glow
        null

    disable : =>
        null

    draw : (r, stroke) =>
        @circle.graphics.clear()
        @circle.graphics.setStrokeStyle stroke
        @circle.graphics.beginFill('rgba(255, 255, 255, 0.39)')
        @circle.graphics.beginStroke('#FFFFFF')
        @circle.graphics.drawCircle(0, 0, @currentState.radius)
        @circle.graphics.endFill()
        null

    animateCircle : (radius, alpha = 0, rotation ) =>
        @tween = new TWEEN.Tween(@currentState).to({ radius: radius }, 200 ).easing( TWEEN.Easing.Quadratic.Out )
        @tween.onUpdate (e) => 
            @draw @currentState.radius, @currentState.stroke

        @tween.start()
        null

    animateIn : (delay) =>
        @tween = new TWEEN.Tween(@current).to({ y: @targetY }, 600 ).easing( TWEEN.Easing.Back.Out ).delay(delay)
        @tween.onUpdate (e) => 
            @view.y = @current.y

        @tween.start()
        null

    animateOut : (delay) =>
        @tween = new TWEEN.Tween(@current).to({ y: 400 }, 600 ).easing( TWEEN.Easing.Back.In ).delay(delay)
        @tween.onUpdate (e) => 
            @view.y = @current.y

        @tween.start()
        null


    menuState : ( enabled = true ) =>
        @clicked = enabled

        tween = new TWEEN.Tween(@glow).to({ alpha : (if enabled then 1 else 0) }, 400 )
        tween.start()

        null
