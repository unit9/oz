class RainDrops extends Abstract
    id       : "raindrops"
    tagName  : 'div'

    container   : null
    topLeft     : null
    topRight    : null
    bottomLeft  : null
    bottomRight : null

    init : ->
        @container = $(@el)
        @container.css
            width : "100%"
            height : "100%"
            position : "absolute"
            top : 0
            left : 0


        @topLeft =  $("<div id='drops_overlay1'></div>")
        @topLeft.css
            position : "absolute"
            width : 792
            height : 392
            top : 0
            left : 0
            background : "url('/models/textures/drops_tl.png')"

        @topRight =  $("<div id='drops_overlay2'></div>")
        @topRight.css
            position : "absolute"
            width : 491
            height : 492
            top : 0
            right : 0
            background : "url('/models/textures/drops_tr.png')"

        @bottomLeft =  $("<div id='drops_overlay3'></div>")
        @bottomLeft.css
            position : "absolute"
            width : 697
            height : 543
            bottom : 0
            left : 0
            background : "url('/models/textures/drops_bl.png')"

        @bottomRight =  $("<div id='drops_overlay4'></div>")
        @bottomRight.css
            position : "absolute"
            width : 291
            height : 286
            bottom : 0
            right : 0
            background : "url('/models/textures/drops_br.png')"        


        @container.append @topLeft
        @container.append @topRight
        @container.append @bottomLeft
        @container.append @bottomRight

        null

