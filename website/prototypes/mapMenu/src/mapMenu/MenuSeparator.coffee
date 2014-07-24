class MenuSeparator

    view  : null
    shape : null

    targetY : null
    current : null

    constructor : (x, y) ->
        @current = {y : 200}

        @view = new createjs.Container
        @view.x = x
        @view.y = @current.y

        @targetY = y

        size = 2

        @shape = new createjs.Shape
        @shape.graphics.beginFill('#FFF').drawRect(-size/2, -size/2, size, size)
        @shape.rotation = -45

        @view.addChild @shape

    animateIn : (delay) =>
        @tween = new TWEEN.Tween(@current).to({ y: @targetY}, 600 ).easing( TWEEN.Easing.Back.Out ).delay(delay)
        @tween.onUpdate (e) => 
            @view.y = @current.y

        @tween.start()

