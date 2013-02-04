class SSAsset extends Abstract

    ss      : null
    from    : null
    asset   : null
    # tagName : 'div'

    initialize : (asset) ->
        @asset = asset
        super()

    init : =>

        @ss = @oz().ss.get @asset
       
        # x = @ss.x
        # y = @ss.y
        # w = @ss.width
        # h = @ss.height

        x = Math.round(@ss.x / 2) - 1
        y = Math.round(@ss.y / 2)
        w = Math.round(@ss.width / 2)
        h = Math.round(@ss.height / 2)

        fullSize = if window.devicePixelRatio == 2 then @oz().ss.image1FullSize else @oz().ss.image1FullSize

        css = 
            width                 : w
            height                : h
            'background-image'    : "url(#{@oz().ssImage.src})"
            'background-size'     : "#{fullSize[0]}px #{fullSize[1]}px"
            'background-position' : "-#{x}px -#{y}px"

        if(window.devicePixelRatio == 2)
            css['background-image'] = "-webkit-image-set(url(#{@oz().ssImage.src}) 1x, url(#{@oz().ssImage2x.src}) 2x)"

        @$el.css css

        @render()

    over : (over) =>
        @changeState over

    out : =>
        
        x = Math.round(@ss.x / 2)-1
        y = Math.round(@ss.y / 2)

        @$el.css
            'background-position' : -x + "px " + -y + "px"

    css : ( params )=>
        @$el.css params


    addClass : ( clazz ) =>
        @$el.addClass clazz


    removeClass : ( clazz ) =>
        @$el.removeClass clazz


    center : =>
        x = Math.round(@ss.width / 4)
        @$el.css
            'position'    : 'absolute'
            'left'        : '50%'
            'margin-left' : "#{-x}px"

    dispose: =>
        @

    oz : =>

        return (window || document).oz

    