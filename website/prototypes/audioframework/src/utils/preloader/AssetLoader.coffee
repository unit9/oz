class AssetLoader

    preload : null
    params  : []

    constructor :->
        _.extend @, Backbone.Events

        @preload = new createjs.PreloadJS
        @preload.onFileLoad = @handleFileLoaded
        @preload.onError    = @handleFileError
        @preload.onProgress = @handleOverallProgress
        @preload.setMaxConnections 5

    loadFiles : (manifest) =>
        
        while manifest.length > 0
            item = manifest.shift()
            
            if item.params
                @params[item.id] = item.params

            item.src = _globals.CDN + item.src
            @preload.loadFile item

    handleOverallProgress : (event) =>

        @trigger PreloaderEvents.PROGRESS, event

    handleFileLoaded : (event) =>

        if @params[event.id]
            event.data = @params[event.id]


        ## TODO
        ## Clean data from params after return it to the event

        @trigger PreloaderEvents.COMPLETE, event

    handleFileError : (event) =>

        @trigger PreloaderEvents.FAIL, event