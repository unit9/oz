class ZoetropeThumb extends Abstract

    className   : "thumb"
    
    pos         : 0
    w           : 0
    h           : 0

    id          : 0
    canvas      : null

    initialize: (id, w, h, gap) =>

        super()

        @id = id
        @pos = ( id * w ) + ( gap * id )

        @w = w
        @h = h

        @$el.css { width: w, height: h, left: @pos }

        @overlay = new Abstract().setElement "<div class='overlay'></div>"
        @overlay.$el.css { "opacity" : 0 }
        @overlay.dispose = () -> null
        @addChild @overlay

        @camera = new SSAsset "interface", "camera_icon"
        @overlay.addChild @camera

        @canvas = new Abstract().setElement "<canvas width='#{ w }' height='#{ h }' ></canvas>"
        @canvas.dispose = () -> null
        @addChild @canvas

        @enable()

        null

    enable : =>

        @$el.bind "mouseover", @onMouseOver
        @$el.bind "mouseout", @onMouseOut
        @$el.bind "mouseup", @onMouseUp
        @$el.bind "mousedown", @onMouseDown

        null

    disable : =>

        @$el.unbind "mouseover"
        @$el.unbind "mouseout"
        @$el.unbind "mouseup"
        @$el.unbind "mousedown"  

        null

    onMouseOver: =>
        @trigger "ON_OVER", @id, @
        null

    onMouseOut: =>
        @trigger "ON_OUT", @id, @
        null

    onMouseUp: (e) =>
        @trigger "ON_MOUSE_UP", @id, e.pageX, @
        null

    onMouseDown: (e) =>
        @trigger "ON_MOUSE_DOWN", @id, e.pageX, @
        null

    onOver: =>
        @overlay.$el.stop().animate { "opacity" : 1 }, 400
        null

    onOut: =>
        @overlay.$el.stop().animate { "opacity" : 0 }, 400
        null

    draw : ( data ) =>
        @canvas.$el.css { "opacity" : "0" }
        @canvas.$el.animate { "opacity" : 1 }
        #@animate { opacity: 0, brightness: -100 }, { opacity: 1, brightness: 0 }

        @canvas.$el[0].getContext("2d").drawImage data, 0, 0, @w, @h
        null

    clear : =>
        @canvas.$el[0].getContext("2d").clearRect 0 , 0 , @w , @h
        null

    getRandomColor : =>
        letters = '0123456789ABCDEF'.split('')
        color = '#'
        for i in [0...6]
            color += letters[Math.round(Math.random() * 15)]

        color

    animate : (from, to) =>
        brightnessI = { opacity: from.opacity, brightness: from.brightness }
        brightnessF = { opacity: to.opacity, brightness: to.brightness }

        tween = new TWEEN.Tween(brightnessI).to(brightnessF, 700)
        tween.easing TWEEN.Easing.Quadratic.Out
        tween.onUpdate =>
            @canvas.$el.css { "opacity" : "#{brightnessI.opacity}", "-webkit-filter" : "brightness(#{brightnessI.brightness}%)" }
        tween.start()

        null