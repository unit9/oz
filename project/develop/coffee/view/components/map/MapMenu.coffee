class MapMenu extends Abstract

    tagName   : 'div'
    stage     : null
    canvas    : null
    fill      : null
    buttons   : null
    seq       : null
    paused    : true
    container : null

    animateSequence : null
    timeout : 0
    scale : 0

    totalW : 0
    center : 0

    init : =>

        @scale = .7
        

        @canvas = document.createElement 'canvas'
        @canvas.width = 800
        @canvas.height = 160
        @$el.append @canvas

        @stage = new createjs.Stage @canvas
        @stage.mouseEventsEnabled = true
        @stage.enableMouseOver(10)

        @container = new createjs.Container
        @stage.addChild @container

        @fill = @oz().baseAssets.get('buttonpattern').result

        @render()
        null
        

    render : =>

        @createSequence()
        
        @animateSequence = []
        @buttons = []

        @totalW = 35
        @center = 75

        for i in [0...@seq.length]
            
            item = @seq[i]

            switch item.type
                when 'scene'
                    menuItem = new MenuFilledCircle @totalW, @center, 30 * @scale, @scale, @oz().baseAssets.get("menu_#{item.id}").result, @oz().baseAssets.get("menu_on").result
                    @buttons.push menuItem
                    menuItem.id = item.id
                    @totalW += if i < @seq.length - 1 then 43 else 35

                when 'sep'
                    menuItem = new MenuSeparator @totalW, @center
                    @totalW += item.space

            @animateSequence.push menuItem
            @container.addChild menuItem.view

            if menuItem.on
                menuItem.on 'click', @menuClick       
                menuItem.on 'rollover', @menuEvents
                menuItem.on 'rollout', @menuEvents

        @container.x = @canvas.width / 2 - @totalW / 2

        @paused = false
        null

    animateIn : =>
        clearTimeout @timeout
        for i in [0...@animateSequence.length]
            @animateSequence[i].animateIn 25 * i

        null
          
    animateOut : (callback) =>
        for i in [@animateSequence.length-1..0]
            @animateSequence[i].animateOut 25 * i
          
        @timeout = setTimeout callback, @animateSequence.length * 25 + 500
        null


    menuClick : (e) =>
        Analytics.track "menu_click_#{e.id}"
        $(@canvas).css {cursor : ''}
        @oz().router.navigateTo e.id, false
        null


    menuEvents : (e) =>
        cursor = if e == 'rollover' then 'pointer' else ''
        $(@canvas).css {cursor : cursor}
        null


    changeMenuArea : (area) =>
        b.menuState(b.id == area) for b in @buttons
        null
            

    onEnterFrame : =>
        @stage.update()
        TWEEN.update()
        null


    createSequence : =>

        @seq = [
            {
                type: 'scene'
                id : 'carnival'
            },
            {type : 'sep', space: 16},{type : 'sep', space: 16},{type : 'sep', space: 48},
            {
                type: 'scene'
                id : 'carnival2'
            },
            {type : 'sep', space: 16},{type : 'sep', space: 16},{type : 'sep', space: 48},
            {
                type: 'scene'
                id : 'carnival3'
            },
        ]

        null
                
        
        


            