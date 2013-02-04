class Credits extends Abstract

    className : 'staticPage'
    template  : 'credits'
    fluorish : null
    bottom : null

    init : =>

        @fluorish = new SSAsset 'interface', 'pause_top'
        @addChild @fluorish, 1
        @fluorish.$el.css {"margin" : "0 auto 15px auto"}

        @oz().appView.static.$el.css
            "background-color" : "rgba(0,0,0,0.8)"

        # @$el.css
        #     height : "auto"

        @list = JSON.parse @oz().baseAssets.get('credits').result
        
        @parse()

        @bottom = new SSAsset 'interface', 'pause_bottom'
        @addChild @bottom
        @bottom.$el.css { "margin" : "17px auto" }

        null

    parse : =>
        cont = $('<div class="credits_container"/>')
        @addChild cont
        for k, v of @list
            cont.append @getPartner v.title

            for i in [0...v.names.length]
                cont.append @getPerson v.names[i].role, v.names[i].name
        null
        


    getPerson : (role, name)=>

        roleNode = ""
        nameNode = $('<div class="name">'+name+'</div>')
        node = $('<div class="person"><div class="space_credits"/><div class="clearfix"></div></div>')
        node.prepend nameNode

        if role != ""
            roleNode = $('<div class="role">'+role+'</div>')
            node.prepend roleNode
        else
            nameNode.css
                'width': '100%'
                'text-align': 'center'

        return node

    getPartner : (partner) =>
        return $('<div class="title">'+partner+'</div>')

    render : (callback) =>
        callback()
        null

    dispose : =>

        @oz().appView.static.$el.css
            "background-color" : "rgba(0,0,0,0.7)"

        null