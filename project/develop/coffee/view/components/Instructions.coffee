class Instructions extends Abstract

    className : "instructionsContainer"
    active : false

    initialize: ( ids ) =>

        super()

        # Box
        box = $("
            <div class='box'>
                <div id='r1' class='row'>
                    <div id='c11' class='cell'></div>
                    <div id='c12' class='cell'></div>
                    <div id='c13' class='cell'></div>
                </div>

                <div id='r2' class='row'>
                    <div id='c21' class='cell'></div>
                    <div id='c22' class='cell'></div>
                    <div id='c23' class='cell'></div>
                </div>

                <div id='r3' class='row'>
                    <div id='c31' class='cell'></div>
                    <div id='c32' class='cell'></div>
                    <div id='c33' class='cell'></div>
                </div>
            </div>")

        @addChild box

        # Image
        image = new SSAsset "interface", ids.assetID
        image.css
            "margin" : "0 auto"

        box.find("#c22").append image.$el
        # @addChild image.$el

        # Sentence
        sentence = $("<p>#{@oz().locale.get(ids.localeID)}</p>")
        box.find("#c22").append sentence
        #@addChild sentence

        # Divider
        divider = new SSAsset "interface", "instructions_flourish"
        divider.css
            "margin" : "0 auto"
        box.find("#c22").append divider.$el
        
        null

    show : (animated, callback) =>
        @active = true
        super animated, callback
        null

    hide : (animated, callback) =>
        super animated, =>
            callback?()
            @active = false
        null
        
    dispose: =>
        null