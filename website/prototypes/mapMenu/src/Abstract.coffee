class Abstract extends Backbone.View

    el              : null
    id              : null
    children        : null
    template        : null
    templateVars    : null
    assetsBatch     : null
    paused          : true
    displayMode     : ''
    visible         : true

    initialize: ->
        
        @children = []

        if @template
            tmpHTML = _.template @oz().templates.get @template
            @setElement tmpHTML @templateVars


        @$el.attr 'id', @id if @id
        @$el.addClass @className if @className

        @init()

        if @assetsBatch?
            @onAssetsInitLoading()
            @oz().baseAssets.on "COMPLETE", @onAssetsComplete
            @oz().baseAssets.on "PROGRESS", @onAssetsProgress
            @oz().baseAssets.loadBatch @assetsBatch

        @paused = false

    init : =>
        @


    update : =>
        child.update() for child in @children
        @

    resume :=>
        @paused = false
        for child in @children
            child.resume() if child.resume?
            child.$el.resume()
        @


    pause :=>
        @paused = true
        for child in @children
            child.pause() if child.pause?
            child.$el.pause()
        @


    render :=>
        child.render() for child in @children
        @


    empty : =>
        for child in @children
            if child
                child.dispose() if child.dispose?
                child.empty() if child.empty?
                @remove child

        @children = []
        @$el.empty()
        @
        

    move : (x, y) =>
        @$el.css
            left : x
            top  : y 

        @

    dispose : =>
        n = $(@$el.children()[0]).attr('id') or $(@$el.children()[0]).attr('class') or @$el.html() or @$el.attr('class') or @$el.attr('style')
        console.error "don't forget to override dispose -> " + n
        @


    addChild : (child, prepend = false) =>
        @children.push child if child.el
        
        c = if child.el then child.$el else child

        if !prepend 
            @$el.append c
        else 
            @$el.prepend c

        @


    remove : (child) =>

        unless child?
            return
        
        c = if child.el then child.$el else $(child)
        child.dispose() if c

        if c && @children.indexOf(child) != -1
            @children.splice( @children.indexOf(child), 1 )

        c.remove()

    onResize : (event) =>
        for child in @children
            if child.onResize
                child.onResize()
        @

    hide : (anim = false, callback = null, time = 400, ease = "linear", hide = false) =>

        ###@displayMode = @$el.css("display")###

        # console.log 'hide() -> @displayMode -> ' + @displayMode

        @visible = false

        if !anim
            @$el.css { opacity : 0 }
            if hide then @$el.css { "visibility" : "hidden" }
        else 
            @$el.stop().animate {opacity: 0}, time, ease, =>
                if callback then callback()
                if hide then @$el.css { "visibility" : "hidden" }


    show : (anim = false, callback = null, time = 400, ease = "linear") =>
        @visible = true

        # console.log 'show() -> @displayMode -> ' + @displayMode
        
        ###if @displayMode != 'none' && @displayMode != ""
            @$el.css {display : @displayMode}###

        @$el.css { "visibility" : "visible" }

        if !anim
            @$el.css {opacity : 1}
        else 
            @$el.stop().animate {opacity: 1}, time, ease, callback
    

    mouseEnabled : ( enabled ) =>
        @$el.css
            "pointer-events": if enabled then "auto" else "none"


    onEnterFrame : =>
        
        for child in @children 
            if (!@paused and child and child.onEnterFrame and (child.paused == false))
                child.onEnterFrame() 
        @


    onAssetsInitLoading : =>
        @


    onAssetsProgress : =>
        @


    pointLock : =>

        $(document).bind 'pointerlockchange', @pointerLockChange
        $(document).bind 'mozpointerlockchange', @pointerLockChange
        $(document).bind 'webkitpointerlockchange', @pointerLockChange

        b = $('body')[0]
        b.requestPointerLock = b.requestPointerLock || b.mozRequestPointerLock || b.webkitRequestPointerLock
        b.requestPointerLock()

    releasePointLock : =>
        $(document).unbind 'pointerlockchange', @pointerLockChange
        $(document).unbind 'mozpointerlockchange', @pointerLockChange
        $(document).unbind 'webkitpointerlockchange', @pointerLockChange
        $(document).unbind 'mousemove', @onLockMouseMove

        # Ask the browser to release the pointer
        b = document
        b.exitPointerLock = b.exitPointerLock || b.mozExitPointerLock || b.webkitExitPointerLock
        b.exitPointerLock()


    pointerLockChange : (event) =>
        if (document.mozPointerLockElement == $('body')[0] || document.webkitPointerLockElement == $('body')[0])
            $(document).bind 'mousemove', @onLockMouseMove
            @onLock()
        else
            @releasePointLock()
            $(document).unbind 'mousemove', @onLockMouseMove
            @onUnLock()

    onLockMouseMove : (event) =>
        @

    onLock : =>
        @

    onUnLock : =>
        @

    onAssetsComplete : =>
        @oz().baseAssets.off "COMPLETE", @onAssetsComplete
        @oz().baseAssets.off "PROGRESS", @onAssetsProgress

    oz : =>
        return (window || document).oz


    
