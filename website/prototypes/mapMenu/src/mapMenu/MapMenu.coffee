class MapMenu extends Abstract

    tagName   : 'div'
    className : 'canvasMenu'
    stage     : null
    canvas    : null
    fill      : null
    buttons   : null

    animateSequence : null

    initialize : =>

        @$el.attr {id : 'containerMenu'}

        @$el.css
            #'border' : '1px solid #FF0000'
            'width'  : '528px'
            'height' : '93px'

        @canvas = document.createElement 'canvas'
        @canvas.width = 528
        @canvas.height = 94
        @$el.append @canvas

        @stage = new createjs.Stage @canvas
        @stage.mouseEventsEnabled = true
        @stage.enableMouseOver(10)

        @fill = new Image()
        @fill.onload = =>

            @left = new Image()
            @left.onload = =>

                @right = new Image()
                @right.onload = =>

                    @icon = new Image()
                    @icon.onload = =>
                        @glow = new Image()
                        @glow.onload = @render
                        @glow.src = 'img/glowmenu1x.png'

                    @icon.src = 'img/music1x.png'

                @right.src = "img/righsidemenu1x.png"

            @left.src = "img/leftsidemenu1x.png"

        @fill.src = "img/pattern_button.png"

    render : =>

        seq = ['diamond', 'sep', 'interact', 'sep', 'sep', 'diamond', 'sep', 'sep', 'sep', 'diamond', 'sep', 'sep', 'interact', 'sep', 'sep','diamond', 'sep', 'sep', 'sep', 'diamond', 'sep', 'sep', 'interact', 'sep', 'sep', 'diamond', 'sep', 'sep', 'sep', 'diamond', 'sep', 'sep', 'interact', 'sep', 'diamond']
        totalW = 39
        center = 47

        @left = new createjs.Bitmap @left
        @left.scaleX = @left.scaleY = .68
        @left.y = center - 6.8
        @stage.addChild @left

        @buttons = []
        @animateSequence = []

        for i in [0...seq.length]
            switch seq[i]
                when 'diamond'
                    r = 6
                    stroke = 1
                    circle = new MenuCircle (totalW + r + stroke / 2), center, r, {fill : @fill, glow: @glow}, stroke
                    circle.on 'click', @menuClick
                    circle.addDiamond 3

                    @buttons.push circle
                    @animateSequence.push circle

                    @stage.addChild circle.view
                    totalW += (r * 2 + stroke) + 7

                when 'sep'
                    sep = new MenuSeparator totalW, center
                    @animateSequence.push sep
                    @stage.addChild sep.view

                    totalW += 7

                when 'interact'
                    r = 12.5
                    stroke = 2
                    circle = new MenuCircle (totalW + r + stroke / 2), center, r, {fill : @fill, glow: @glow}, stroke
                    circle.on 'click', @menuClick
                    circle.addIcon @icon

                    @buttons.push circle
                    @animateSequence.push circle

                    @stage.addChild circle.view
                    totalW += (r * 2 + stroke) + 7

        @right = new createjs.Bitmap @right
        @right.scaleX = @right.scaleY = .68
        @right.x = totalW
        @right.y = center - 6.8
        @stage.addChild @right

        @animate()

        @animateIn()


    animateIn : =>
        for i in [0...@animateSequence.length]
            @animateSequence[i].animateIn 25 * i


    menuClick : (e) =>
        for i in @buttons
            i.disable false

        e.disable()
        
    animate : =>
        requestAnimationFrame @animate
        TWEEN.update();
        @stage.update()



        
        
        


            