class IFLModelManager

  BatchLoadingPhase :
    SETTINGS        : 0
    MATERIALS       : 1
    MATERIALS_DONE  : 2
    MODELS          : 3
    
  BatchState :
    RUNNING       : 0
    PAUSED        : 1
    COMPLETED     : 2

  @_instance: null

  modelLibraries: {}

  batchLoadTextureIndex:0
  batchLoadTextures:[]
  batchDDSPath:null
  batchJPGPath:null
  cachingTextures:true

  batchLoader:null
  batchLoadingIndex:-1
  batchLoadingPhaseIndex:0
  batchLoadingSettings:{}
  batchSettings:null
  batchMaterialManager:null
  batchLoader:null
  oz:null
  state:null

  loader:null
  #viewCallback:null
  urlLoading:null
  prefetchEnabled : true

  @getInstance: ->
    if not @_instance?
      @_instance = new @
      @_instance.init()
    
    @_instance

  init:->
    # @loader = new IFLLoader()
    # @loader.enableMaterialCache = false
    # @loader.enableTextureCache = false
    @oz = (window || document).oz
    @state = @BatchState.PAUSED
    CustomImageUtils.cacheTextures = true
    @batchLoadingSettings = ["/models/s001_settings.json","/models/s002_settings.json","/models/s003_settings.json"]
    
  batchLoadingPhaseManager:(value) =>
    # console.log @batchLoadingPhaseIndex
    # console.log @batchLoadingIndex
    # console.log value

    return unless @prefetchEnabled
    
    if @state == @BatchState.PAUSED
      return

    switch @batchLoadingPhaseIndex
      when @BatchLoadingPhase.SETTINGS
        @batchSettings = value
        if @modelLibraries[@batchSettings.modelURL]?
          @nextBatchLoading()
        else
          # console.log "carico le textures"
          @batchLoadingPhaseIndex = @BatchLoadingPhase.MATERIALS
          textureQuality = @oz.appView.textureQuality
          # if @batchSettings.textureQuality? then @batchSettings.textureQuality else "med"
          @batchLoadTextures = if @batchSettings.loadTextures? then @batchSettings.loadTextures else []
          @batchDDSPath = if @batchSettings.ddsBasePath? then @batchSettings.ddsBasePath else ""
          @batchJPGPath = if @batchSettings.jpgBasePath? then @batchSettings.jpgBasePath else ""
          ddsQuality = @batchDDSPath.indexOf("#QUALITY#")
          
          if (ddsQuality != -1)
            @batchDDSPath = @batchDDSPath.substr(0,ddsQuality) + textureQuality
          
          @batchLoadTextureIndex=-1
          @batchLoadingPhaseManager()

      when @BatchLoadingPhase.MATERIALS
        
        @batchLoadTextureIndex++
        # console.log "texture #{@batchLoadTextureIndex}" 
        
        if ((@batchLoadTextureIndex < @batchLoadTextures.length)&&(@cachingTextures))
          tex = @batchLoadTextures[@batchLoadTextureIndex]
          if tex.indexOf(".dds") != -1
            CustomImageUtils.loadCompressedTexture( "#{@batchDDSPath}/#{tex}", null, @batchLoadingPhaseManager, null,null, true);
          else
            CustomImageUtils.loadTexture( "#{@batchJPGPath}/#{tex}", null, @batchLoadingPhaseManager);
          
        else
          @batchLoadingPhaseIndex = @BatchLoadingPhase.MATERIALS_DONE
          @batchLoadingPhaseManager()  

      when @BatchLoadingPhase.MATERIALS_DONE

        # console.log "carico i models"
        @batchLoadingPhaseIndex = @BatchLoadingPhase.MODELS
        @batchLoader = new IFLLoader()
        @batchLoader.enableMaterialCache = false
        @batchLoader.enableTextureCache = false
        @batchLoader.doCreateModel = false
        @batchLoader.pickableObjects = @batchSettings.pickables
        @batchLoader.customMaterialInstancer = null #@batchMaterialManager.instanceMaterial
        @batchLoader.load(@batchSettings.modelURL,@batchLoadingPhaseManager,null)

      when @BatchLoadingPhase.MODELS
        # console.log "caricati i models"
        @modelLibraries[@batchSettings.modelURL] = @batchLoader.library
        @nextBatchLoading()
    
      # else console.log "problema con loadingPhase"

  nextBatchLoading: ->
    if @state == @BatchState.PAUSED
      return

    @batchLoadingIndex++;
    if(@batchLoadingIndex<@batchLoadingSettings.length) 
      # console.log "carico in batch i settings"
      # console.log @batchLoadingIndex
      @batchLoadingPhaseIndex = @BatchLoadingPhase.SETTINGS;
      $.ajax( {url : @batchLoadingSettings[@batchLoadingIndex], dataType: 'json', success : @batchLoadingPhaseManager });
    else
      @state = @BatchState.COMPLETED
      # console.log "fine batchLoading"

  resume:->
    # console.log "batchResuming" 
    @state = @BatchState.RUNNING
    @nextBatchLoading()    

  pause:->
    # console.log "batchPausing" 
    @state = @BatchState.PAUSED
    try @batchLoader?.dispose()
    try @loader?.dispose()
          
  #set: (key, val) ->
  #  @modelLibraries[key] = val
  #  return
  #
  #get: (key) ->
  #  @modelLibraries[key]
  
  load: (pickables, instanceMaterial, url, callback, callbackProgress) ->
    @urlLoading =  url
    #@viewCallback = callback


      
    if @modelLibraries[url]?
      # console.log "uso la cache"
      #@loader.decompressCachedLibrary(url, callback, callbackProgress, @modelLibraries[url])
      # @loader.instantiateCachedLibrary(url, callback, callbackProgress, @modelLibraries[url])
      console.log "CACHED library"

      @loader = new IFLLoader()
      @loader.enableMaterialCache = false
      @loader.enableTextureCache = false
      @loader.pickableObjects = pickables
      @loader.customMaterialInstancer = instanceMaterial
      @loader.callback = callback
      @loader.callbackProgress = callbackProgress
      @loader.library = @modelLibraries[url]
      @loader.doCreateModel = false
      # @loader.createModel()
      callback?(@loader,null)
      return

    else
      #@loader.loadAndCache(url,callback,callbackProgress,@localCallBack, null)
      
      @pause()
      @loader = new IFLLoader()
      @loader.enableMaterialCache = false
      @loader.enableTextureCache = false
      @loader.pickableObjects = pickables
      @loader.customMaterialInstancer = instanceMaterial
      @loader.finalCallBack = callback
      @loader.doCreateModel = false
      @loader.load(url,@localCallBack,callbackProgress)
      return
      # console.log "non uso la cache"
  
  localCallBack:(loader,data) =>
    # console.log "cacho la response"
    #console.log response
    @modelLibraries[@urlLoading] = loader.library
    loader.finalCallBack(loader,data)
    if @state!=@BatchState.COMPLETED
      @resume()
    
  dispose: ->
    @loader?.dispose()

  cacheTextures:(value) ->
    @cachingTextures = value
    CustomImageUtils.cacheTextures = value
