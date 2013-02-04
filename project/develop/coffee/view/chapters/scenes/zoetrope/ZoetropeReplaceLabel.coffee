class ZoetropeReplaceLabel extends Abstract

    className   : "labelContainer"
    label       : null

    init: () =>

        @label = new Abstract().setElement "<div class='label'></div>"
        @label.dispose = () -> null
        @label.$el.css { "height" : @thumbH }
        @addChild @label
        @hide()
        
        # @left = $("<div class='left'></div>")
        @left = new SSAsset "interface", "tooltip_large"
        @left.$el.css { "float" : "left", "width" : "20px" }
        @label.addChild @left

        @content = $("<div class='content'><div class='text'>#{@oz().locale.get('zoetrope_replace')}</div></div>")
        @label.$el.append @content

        # Content BG
        @contentBG = new SSAsset "interface", "tooltip_large"
        @content.append @contentBG.$el
        @contentBG.$el.css 
            "position"      : "relative"
            "width"         : "20px"
            "margin-top"    : "-38px"
            "left"          : "50%"
            "margin-left"   : "-7px"
            "z-index"       : "-1"
            "width"         : "13px"
            "background-position-x" : "#{parseFloat(@contentBG.$el.css("background-position-x")) - 30}px"

        # @right = $("<div class='right'></div>")
        @right = new SSAsset "interface", "tooltip_large"
        @label.addChild @right
        @right.$el.css
            "float" : "left"
            "width" : "20px"
            "background-position-x" : "#{parseFloat(@right.$el.css("background-position-x")) - 52}px"


        @clear = $("div class='clearfix'></div>")
        @label.$el.append @clear
        null

    showAt: (x) =>
        @label.$el.stop().animate { opacity: 1 }
        @label.$el.css { left: "#{ x }px"}
        null

    hide: () =>
        @label.$el.stop().animate { opacity: 0 }
        null

    dispose: () =>
        null