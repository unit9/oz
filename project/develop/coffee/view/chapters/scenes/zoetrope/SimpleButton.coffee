class SimpleButton extends AbstractButton

    initialize : ( _id, _label, transitionClass = "btanimated" ) ->

        @id = _id
        @label = _label
        @classAnimated = transitionClass
            
        super()

    init :  =>

        @enable()

    onover: =>

        super()

    onout: =>

        super()

    onclick: =>

        @trigger "click", @
        null

    dispose: =>
        null