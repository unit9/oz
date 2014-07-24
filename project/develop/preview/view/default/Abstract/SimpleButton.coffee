class SimpleButton extends AbstractButton

    initialize : ( _id, _label, transitionClass = "btanimated" ) ->

        @id = _id
        @label = _label
        @classAnimated = transitionClass
            
        super()

    init :  =>

        @enable()

    onover: =>

        SoundController.send "btn_generic_over"

        super()

    onout: =>

        super()

    onclick: =>

        SoundController.send "btn_generic_click"

        @trigger "click", @

    dispose: =>
        @