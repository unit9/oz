class CutoutPolaroid extends Abstract

    className : 'cutout_polaroid'
    tagName   : 'div'

    container    : null
    mask         : null
    canvasOz     : null
    canvasNormal : null
    ctxNormal    : null
    ctxOz        : null

    fluf1 : null
    title : null
    fluf2 : null
    mainContainer : null
    containerButtons : null
    shareButton : null
    tryAgainButton : null

    init: =>

        @mouseEnabled false

        # titles container

        @mainContainer = $('<div class="cutout_polaroid_cell"/>')
        @addChild @mainContainer

        @titleContainer = new Abstract().setElement $('<div class="cutout_polaroid_title_container"/>')

        @fluf1 = new SSAsset 'interface', 'instructions_flourish_top'
        @fluf1.$el.css {margin : '0 auto'}
        @titleContainer.addChild @fluf1

        @title = $('<p>' + @oz().locale.get('shareBoxTitleCutout') + "</>")
        @titleContainer.addChild @title

        @fluf2 = new SSAsset 'interface', 'instructions_flourish'
        @fluf2.$el.css {margin : '0 auto'}
        @titleContainer.addChild @fluf2

        @mainContainer.append @titleContainer.$el

        # Picture

        @container = $('<div class="cutout_polaroid_cont" />')
        @mask = $('<div class="cutout_polaroid_mask" />')

        @canvasNormal = document.createElement 'canvas'
        @canvasNormal.width = 438
        @canvasNormal.height = 526
        @ctxNormal = @canvasNormal.getContext '2d'
        @mask.append @canvasNormal

        @canvasOz = document.createElement 'canvas'
        @canvasOz.width = 438
        @canvasOz.height = 526
        @ctxOz = @canvasOz.getContext '2d'
        @mask.append @canvasOz

        @container.append @mask
        @container.append @oz().baseAssets.get('cutout_polaroid').result

        @mainContainer.append @container

         # Buttons container
        @containerButtons = new Abstract().setElement $('<div/>')
        @containerButtons.hide false
        @containerButtons.$el.css
            "visibility" : "hidden"

        @tryAgainButton = new SimpleButton "tryAgainBtn", @oz().locale.get 'cutoutTry'
        @tryAgainButton.$el.css {'margin-right' : '20px'}
        
        @shareButton = new SimpleButton "shareCutoutBtn", @oz().locale.get 'cutoutShare'
        

        @containerButtons.addChild @tryAgainButton
        @containerButtons.addChild @shareButton

        @mainContainer.append @containerButtons.$el

        null


    addShareButtons : (call1, call2)=>

        @containerButtons.$el.css
            "visibility" : "visible"

        @shareButton.on 'click', call1
        @tryAgainButton.on 'click', call2

        width = Math.max(@shareButton.$el.width(), @tryAgainButton.$el.width())
        @shareButton.$el.width(width)
        @tryAgainButton.$el.width(width)

        @containerButtons.show true

        null

    animateIn : (callback) =>

        @show true, =>
            @$el.css {cursor : 'pointer'}
            @$el.bind 'click', @onClick
            @mouseEnabled true
            callback?()

        null


    animateOut : (callback) =>

        @shareButton.off 'click'
        @tryAgainButton.off 'click'

        @mouseEnabled false

        @containerButtons.hide true

        @hide true, =>
            callback?()
            @hide false
            @$el.css {visibility : false}
            
            @containerButtons.$el.css
                "visibility" : "hidden"
        
        null


    update : (normal, oz) =>
        
        $(@canvasOz).css {opacity: 0}

        @ctxOz.clearRect 0, 0, @canvasOz.width, @canvasOz.height
        @ctxOz.drawImage oz, 0, 0

        @ctxNormal.clearRect 0, 0, @canvasNormal.width, @canvasNormal.height
        @ctxNormal.drawImage normal, 0, 0

        null


    onClick : =>
        @$el.unbind 'click', @onClick
        @$el.css {cursor : 'auto'}

        @titleContainer.hide true, null, 200

        $(@canvasOz).animate {opacity: 1}, 700, =>
            @trigger 'onPolaroidOz'

        null


