class Router extends Backbone.Router

    @EVENT_HASH_CHANGED   : 'EVENT_HASH_CHANGED'

    firstEnter : true
    showInstructions : true

    routes :

        ':area'            : 'hashChanged'
        ':area/'           : 'hashChanged'
        '/:area'           : 'hashChanged'
        '/:area/'          : 'hashChanged'

        '*actions'         : 'hashChanged'

    start: ->

        Backbone.history.start 
            pushState: true, 
            root: window.oz.BASE_PATH

        null

    hashChanged : (@area = null, @sub = null) =>
        
        if @firstEnter and @area != "" and @area != null
            @showInstructions = false
            @firstEnter = false

        # qualityIndex = @area.indexOf("quality=")        
        # if (qualityIndex != -1)
        #     @area = @area.substr(0,qualityIndex)

        # interfaceIndex = @area.indexOf("?nterface")
        # if (interfaceIndex != -1)
        #     @area = @area.substr(0,interfaceIndex)

        parametersIndex = @area.indexOf("?")
        if (parametersIndex != -1)
            @area = @area.substr(0,parametersIndex)

        @trigger Router.EVENT_HASH_CHANGED, @area, @sub

        null

    navigateTo : (where, trigger = true) =>

        if !trigger
            @trigger Router.EVENT_HASH_CHANGED, where
            return

        
        window.oz.appView.showMap(where is "")
        

        if where.charAt( where.length - 1 ) != "/"
            where += '/'

        @navigate where, trigger: true

        null
