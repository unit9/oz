class InstructionsChapter extends Abstract

    className : "instructionsChapterContainer"

    timeoutToMouseMove : null

    activated : false

    initialize: =>

        super()

        @instructions = new Instructions
            "assetID"   : "instructions_music"
            "localeID"  : "landingInstructions"
        @addChild @instructions

        @instructions.$el.css
            display: 'table-cell'
            'vertical-align' : 'middle'

        @instructions.$el.find('#c22 p').css {'text-transform': 'uppercase'}
        @instructions.$el.find('#c22 p').append "<br>#{@oz().locale.get('landing_instructions_small')}"

        @hide()
        null

    activate: =>
        return if @oz().router.showInstructions == false

        if !@activated
            @activated = true

            @show true
            @instructions.show(true)
            @$el.bind "mousedown", @close
            @timeoutToMouseMove = setTimeout @addMouseListener, 4000

        null

    addMouseListener: =>
        document.addEventListener "mousemove", @onMouseMove, false
        null

    onMouseMove: =>
        @close()
        null

    close: =>

        clearTimeout @timeoutToMouseMove

        @$el.unbind "mousedown"
        document.removeEventListener "mousemove", @onMouseMove, false

        @hide true, =>

            @oz().appView.area.remove @oz().appView.area.chapterInstructions
            @oz().appView.area.chapterInstructions = null

        null

    dispose: =>
        null