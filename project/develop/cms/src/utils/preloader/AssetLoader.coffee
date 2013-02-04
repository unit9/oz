class AssetLoader

    preload  : null

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
            item.src = _globals.CDN + item.src
            @preload.loadFile item

    handleOverallProgress : (event) =>

        @trigger PreloaderEvents.PROGRESS, event

    handleFileLoaded : (event) =>

        @trigger PreloaderEvents.COMPLETE, event

    handleFileError : (event) =>

        @trigger PreloaderEvents.FAIL, event