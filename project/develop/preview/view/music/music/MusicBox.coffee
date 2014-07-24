class MusicBox extends Abstract

    data : null

    initialize: (data) =>

        @data = data

        super()

    init: ->

        @container = new Abstract().setElement $('<div class="musicbox"/>')
        @container.dispose = () -> return
        @addChild @container

        @render()

    render : =>

        @$el.css
            "position"  : "absolute"
            "display"   : "table"
            "width"     : "100%"
            "height"    : "100%"

        @table = new MusicBoxTable @data
        @container.addChild @table

    restore: =>

        # TODO : Clean Musix Box Table
        
        @container.$el.animate {opacity: 1}, 300, "linear"

    dispose : =>

        super()
