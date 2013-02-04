class AssetLoader

    preload  : null

    constructor :->
        _.extend @, Backbone.Events

        @preload = new createjs.PreloadJS
        @preload.onFileLoad = @handleFileLoaded
        @preload.onError    = @handleFileError
        @preload.onProgress = @handleOverallProgress
        @preload.setMaxConnections 5
        null


    loadFiles : (manifest) =>

        while manifest.length > 0
            item = manifest.shift()

            if item.retina?
                if window.devicePixelRatio == 2
                    @preload.loadFile item
            else 
                @preload.loadFile item

        null

    handleOverallProgress : (event) =>

        @trigger PreloaderEvents.PROGRESS, event

        null

    handleFileLoaded : (event) =>

        @trigger PreloaderEvents.COMPLETE, event

        null


    handleFileError : (event) =>

        @trigger PreloaderEvents.FAIL, event

        null



