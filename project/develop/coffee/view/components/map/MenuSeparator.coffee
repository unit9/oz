class MenuSeparator

    view  : null
    shape : null

    targetY : null
    current : null

    tween : null

    constructor : (x, y) ->
        @current = {y : 200}

        @view = new createjs.Container
        @view.x = x
        @view.y = @current.y

        @targetY = y

        @shape = new createjs.Shape
        @shape.graphics.beginFill('#FFF')
        @shape.graphics.drawCircle(0,0,3.5)
        @shape.graphics.endFill()

        @view.addChild @shape
        null

    animateIn : (delay) =>
        @tween = new TWEEN.Tween(@current).to({ y: @targetY}, 600 ).easing( TWEEN.Easing.Back.Out ).delay(delay)
        @tween.onUpdate (e) => 
            @view.y = @current.y

        @tween.start()
        null

    animateOut : (delay) =>
        @tween = new TWEEN.Tween(@current).to({ y: 200 }, 600 ).easing( TWEEN.Easing.Back.In ).delay(delay)
        @tween.onUpdate (e) => 
            @view.y = @current.y

        @tween.start()
        null

    menuState : ( enabled = true ) =>
        null

