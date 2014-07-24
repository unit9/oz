class BaseAssets

    preloader     : null
    loadedAssets  : null
    collection    : null
    batches       : null
    loadedBatches : null
    batchesToLoad : null

    constructor : ->
        _.extend @, Backbone.Events
        null


    loadBatch : (batches) =>
        
        @batches = batches
        @batchesToLoad = []

        for batch in @batches
            if @loadedBatches.toString().indexOf(batch) == -1
                @batchesToLoad.push batch
                @preloader.loadFiles (@collection.where id : batch)[0].get "list"

        if @batchesToLoad.length == 0
            @trigger "COMPLETE"

        null


    init : (batches) =>

        @batches = batches
        @loadedBatches = []
        @batchesToLoad = []

        @preloader = new AssetLoader
        @preloader.on PreloaderEvents.COMPLETE, @onFileComplete
        @preloader.on PreloaderEvents.PROGRESS, @onProgress
        @preloader.on PreloaderEvents.FAIL    , @onFail

        @collection = new CollectionBatchLoad
        @collection.url = "/js/assetList.json"
        @collection.fetch
            success : @onCollectionSuccess
            error   : @onCollectionError

        null

    onCollectionSuccess : (event) =>
        @loadBatch @batches
        null


    onCollectionError : (event) =>
        #console.log event
        null


    get : (id) =>
        return @loadedAssets[id]


    onProgress : (event) =>
        @trigger "PROGRESS", event
        null


    onFail : (event) =>
        #console.log event
        null


    onFileComplete : (event) =>

        switch event.type
            when 'json'
                if event.src.indexOf('/ss/') > -1
                    (window || document).oz.ss.add event


        if @preloader.preload._numItems == @preloader.preload._numItemsLoaded
            @loadedAssets = event.target._loadedItemsById
            @loadedBatches = @loadedBatches.concat @batchesToLoad
            @trigger "COMPLETE", @loadedAssets
        null
        