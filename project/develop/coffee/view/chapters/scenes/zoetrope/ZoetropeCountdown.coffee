class ZoetropeCountDown extends Abstract

    className   : "counter"
    counter     : 3
    counting    : null
    numbers     : []
    circle      : null

    init : =>

        @numbers = null
        @numbers = []

        for i in [1..@counter]
            n = $("<div>#{ i }</div>")
            n.css { fontSize: "0px", opacity: 0}
            @numbers.push n
            @addChild n

        i = null

        @hold = $("<div>- - -</div>")
        @hold.css
            "fontSize"          : "38px"
            "opacity"           : 1
            "letter-spacing"    : "-1px"
            "line-height"       : "49px"

        @addChild @hold
        
        null

    startCountDown: =>

        @counter = 3
        @hold.stop().animate {opacity: 0}
        @counting = setInterval @start, 500
        @start()
        null

    stopCountDown: =>

        clearInterval @counting
        
        for i in [0...3]
            @numbers[i].stop().animate({opacity: 0, fontSize: "16px"}, 400, 'easeOutExpo')

        i = null

        @hold.stop().animate {opacity : 1}
        null

    start : =>

        if @counter < @numbers.length
            # if @counter == 0 then @circle.$el.animate({opacity: 0}, 400, 'easeOutExpo')
            @numbers[@counter].stop().animate({opacity: 0, fontSize: "36px"}, 400, 'easeOutExpo')
            if @counter == 0 then @done()

        if @counter > 0
            @numbers[@counter - 1].delay(100).stop().animate({opacity: 1, fontSize: "38px"}, 700, 'easeOutBack')
            @counter--

        null

    next : =>
        @counter--

        null

    done : =>

        @hold.stop().animate {opacity : 1}

        clearInterval @counting
        @trigger "COUNTDOWN_COMPLETE"
        
        null

    dispose: =>
        null