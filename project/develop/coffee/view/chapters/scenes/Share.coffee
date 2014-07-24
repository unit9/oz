class ShareScene extends AbstractScene

    shareBox : null

    init : =>

        @$el.css { width: "100%" }
        @$el.css { height: "100%" }
        @$el.css { opacity : 0, display: "none", "position" : "absolute", "z-index" : 10, "background-color": "transparent" }

        null

    show : (data) =>

        @shareBox = new ShareBox data.title, data.sub, data.back, data.backCall, data.link, data.type
        @shareBox.on 'removeShareBox', @hide
        @addChild @shareBox

        @$el.css {display : 'table'}

        super(true)

        null

    hide : =>

        super true, =>

            @remove @shareBox
            @shareBox?.off 'removeShareBox'
            @shareBox = null

            @$el.css {display : 'none'}

        null
            
        