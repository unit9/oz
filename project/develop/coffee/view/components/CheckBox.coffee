class CheckBox extends Abstract

    check   : null
    checked : null
    className : 'openingCheckBox'

    init : =>
        @$el.addClass 'btanimated'

        @check = new SSAsset 'interface', 'checkbox'
        @check.mouseEnabled false
        @addChild @check

        @check.$el.addClass 'openingCheckBox'
        @check.$el.css 
            'background-position-y' : (parseInt(@check.$el.css('background-position-y')) + 1)
            'height' : parseInt(@check.$el.css('height')) + 1
            'width' : parseInt(@check.$el.css('width')) + 1

        @checked = new SSAsset 'interface', 'checkbox_checked'
        @checked.mouseEnabled false
        @addChild @checked
        @checked.$el.addClass 'openingCheckBox'
        @checked.$el.css 
            'background-position-y' : (parseInt(@checked.$el.css('background-position-y')) + 1)
            'height' : parseInt(@checked.$el.css('height')) + 1
            'width' : parseInt(@check.$el.css('width')) + 1
            
        @checked.hide()

        @$el.click @click
        null

    click : =>
        @trigger 'toggled'
        null


    toggleCheck : =>

        if @check.visible

            @check.hide()
        else 
            @check.show()


        if @checked.visible

            @checked.hide()
        else 
            @checked.show()

        null


    val : =>
        return @checked.visible



