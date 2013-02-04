class SSAsset extends Abstract

    ss      : null
    from    : null
    asset   : null

    initialize : (from, asset) ->
        @from  = from
        @asset = asset

        super()

    init : =>

        @ss = @oz().ss.get @from, @asset

        x = Math.round(@ss.x / 2) - 1
        y = Math.round(@ss.y / 2)
        w = Math.round(@ss.width / 2)
        h = Math.round(@ss.height / 2)

        # x = @ss.x
        # y = @ss.y
        # w = @ss.width
        # h = @ss.height

        css = 
            width                 : w
            height                : h
            'background-image'    : "url(#{@ss.image})"
            'background-size'     : "#{@ss.fullSize[0]}px #{@ss.fullSize[1]}px"
            'background-position' : "-#{x}px -#{y}px"

        if(window.devicePixelRatio == 2)
            css['background-image'] = "-webkit-image-set(url(#{@ss.image}) 1x, url(#{@ss.image2x}) 2x)"

        @$el.css css
            
        @render()
        null

    over : (over) =>
        @changeState over
        null

    out : =>
        x = Math.round(@ss.x / 2)-1
        y = Math.round(@ss.y / 2)

        ###x = @ss.x
        y = @ss.y###

        @$el.css
            'background-position' : "#{-x}px #{-y}px"

        null

    css : ( params )=>
        @$el.css params
        null


    addClass : ( clazz ) =>
        @$el.addClass clazz
        null


    removeClass : ( clazz ) =>
        @$el.removeClass clazz
        null


    changeState : (state) =>
        params = @oz().ss.get @from, state

        x = Math.round(params.x / 2)-1
        y = Math.round(params.y / 2)
        
        ###x = params.x
        y = params.y###

        @$el.css
            'background-position' : "#{-x}px #{-y}px"

        null


    center : =>
        x = Math.round(@ss.width / 4)
        @$el.css
            'position'    : 'absolute'
            'left'        : '50%'
            'margin-left' : "#{-x}px"

        null

    dispose: =>
        null

    