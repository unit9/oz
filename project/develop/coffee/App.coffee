
# Avoid console errors in browsers that lack a console.

`
(function() {
    var method;
    var noop = function () {};
    var methods = [
      'assert', 'clear', 'count', 'debug', 'dir', 'dirxml', 'error',
      'exception', 'group', 'groupCollapsed', 'groupEnd', 'info', 'log',
      'markTimeline', 'profile', 'profileEnd', 'table', 'time', 'timeEnd',
      'timeStamp', 'trace', 'warn'
    ];
    var length = methods.length;
    var console = (window.console = window.console || {});
 
    while (length--) {
      method = methods[length];
 
      // Only stub undefined methods.
      if (!console[method]) {
        console[method] = noop;
      }
    }
}());
`
$ ->

    _.templateSettings = 
        interpolate : /\{\{(.+?)\}\}/g


    # DECLATE MAIN WINDOW METHODS AND VARS
    view = (window || document)
    
    window.URL = (window.URL || window.webkitURL)
    navigator.getUserMedia = (navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia)
    loadedFiles = null

    # ON BASE ASSETS LOAD
    onBaseAssetsComplete = (event) =>
        view.oz.baseAssets.off "COMPLETE", onBaseAssetsComplete
        iniLocale()
        null


    # INIT LOCALE
    iniLocale = =>

        Analytics.start()

        view.oz.locale = new Locale
        view.oz.locale.on 'complete', initObjects
        view.oz.localeTexture = new LocalisedTexture
        null


    # INIT OBJECTS
    initObjects = =>
        view.oz.locale.off 'complete', initObjects
        
        view.oz.templates  = new Templates view.oz.baseAssets.get('templates').result
        view.oz.cam        = new WebCam
        view.oz.appView    = new AppView
        view.oz.router     = new Router
        view.oz.agreed     = false

        initApp()

        null


    # INIT APP
    initApp = =>

        TweenLite.ticker.useRAF(false)

        view.oz.appView.render()
        view.oz.router.on Router.EVENT_HASH_CHANGED, view.oz.appView.changeView
        
        view.oz.router.start()
        
        initEnterFrame()
        addStats()
        null


    initEnterFrameContinues = =>
        window.requestAnimationFrame( initEnterFrame )


    # INIT ENTER FRAME
    initEnterFrame = =>
        # JORDI: Temp fix for Yates capture
        #ini = Date.now()
        #window.setTimeout( initEnterFrameContinues, 2 / 30 )
        view.oz.stats.begin();
        view.oz.appView.onEnterFrame();
        view.oz.stats.end();
        #end = Date.now()
        #window.setTimeout( initEnterFrameContinues, Math.max( 0, (1000 / 30) - (end - ini) ) )
        window.requestAnimationFrame( initEnterFrame )
        return


    # STATS
    addStats = =>
        view.oz.stats.domElement.style.position = 'absolute'
        view.oz.stats.domElement.style.top = '0px'
        #view.oz.appView.addChild view.oz.stats.domElement
        null



    # INIT GLOBAL OBJECTS
    view.initApp = =>
        view.oz = 
            BASE_PATH    : view.location.origin + "/"
            ss           : new CollectionSpriteSheets
            baseAssets   : new BaseAssets
            stats        : new Stats
            touch        : Modernizr.touch

        view.oz.baseAssets.on "COMPLETE", onBaseAssetsComplete
        view.oz.baseAssets.init ['homeAssets']
        null


    view.textureQuality = window.textureQuality
    view.displayQuality = window.displayQuality
    view.dof = window.dof
    
    # PREVENT TOUCH SCROLL
    $('body').bind 'touchmove', (event) -> 
        event.preventDefault()
        null

    view.initApp()
