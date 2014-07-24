class Map extends Abstract

    base          : null
    buttonsCoord  : null
    className     : 'map'
    currentIndex  : -1
    buttons       : null
    view          : null

    init : =>

        @view = new MapMenu
        @addChild @view
        #@view.animateIn()
        null
       

    hide : (anim = false, callback = null, time = 400, ease = "linear") =>
        
        @visible = false

        @mouseEnabled false

        if !anim
            #@$el.css { opacity : 0 , display : 'none'}
            callback?()
        else 
            @view.animateOut callback

        null

    show : (anim = false, callback = null, time = 400, ease = "linear") =>
        
        @visible = true

        @mouseEnabled true


        if !anim
            @view.animateIn()
            callback?()
        else 
            @view.animateIn()
            callback?()
        

        # callback?()
        null

    showMenu:->
        # @visible = true
        # @mouseEnabled true
        # @view.animateIn()
        # callback?()
        return null
   

    changeMenuArea : (area) =>
        @view.changeMenuArea area
        null

        