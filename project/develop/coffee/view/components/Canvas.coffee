class Canvas extends Abstract

    tagName  : 'canvas'
    context  : null
    attr     : null
    paused   : true

    initialize : (w = 1024, h = 768) =>
        @attr = 
            width  : w,
            height : h

        super()
        null

    init: ->
        @$el.attr @attr
        @context = @el.getContext '2d'
        null