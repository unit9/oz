class OpeningTitles extends Abstract

    template  : 'openingTitles'
    fluorish  : null
    diamond   : null
    className : 'openingTitles'
    divider   : null
    cta       : null
    header    : null
    pauseState : false

    initialize : (title, cta, divider = true, pauseState = false) =>
        @templateVars = 
            title : title
            cta   : cta

        @pauseState = pauseState

        @divider = divider

        super()
        null

    init : =>

        @fluorish = new SSAsset 'interface', 'pause_top'
        @addChild @fluorish, 1
        @fluorish.center()

        @diamond = new SSAsset 'interface', 'pause_bottom'
        @addChild @diamond
        @diamond.center()


        if @divider
            @cta = @$el.find('.openingTitlesCTA')

            left = new SSAsset 'interface', 'pause_left'
            right = new SSAsset 'interface', 'pause_right'

            leftSpan = $("<span class='left'>")
            leftSpan.append left.$el

            rightSpan = $("<span class='right'>")
            rightSpan.append right.$el

            @cta.prepend leftSpan
            @cta.append rightSpan


        @header = @$el.find('.openingTitlesHeader')
        null


    render : (callback)=>
        setTimeout =>
            
            fontSize = parseInt(window.getComputedStyle(@header[0], null).fontSize)

            while parseInt(@header.find('span').width()) > 725
                fontSize--
                @header.css {'font-size' : fontSize}

            @header.css {'line-height' : fontSize - 2 + "px"}

            callback()



        , 200

        null
   

    dispose : =>
        null