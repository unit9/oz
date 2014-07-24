$ ->

    view = (window || document)

    view.oz = {}
    view.oz.ss = null
    view.oz.view = null
    view.oz.imagesSS = null
    view.oz.result = null

    view.oz.ssImage = new Image()
    view.oz.ssImage.onload = =>
        onLoadImage1x()

    view.oz.ssImage2x = new Image()
    view.oz.ssImage2x.onload = =>
        view.oz.ss.image2FullSize = [view.oz.ssImage2x.width, view.oz.ssImage2x.height]
        onLoadAssets()
        
    onSuccess = (event) =>
        view.oz.imagesSS = view.oz.ss.getImage()
        view.oz.ssImage.src = view.oz.imagesSS.image


    getModule = =>
        url = window.location.href
        del = "preview/"
        i = url.indexOf(del)
        lastI = url.lastIndexOf('/')
        module = url.substring(i + del.length , lastI).split('/').join('')
        return module

    getIdRequest = =>
        return window.location.href.substr(window.location.href.lastIndexOf('/') + 1, window.location.href.length)


    onLoadImage1x = () =>
        view.oz.ss.image1FullSize = [view.oz.ssImage.width, view.oz.ssImage.height]
        if view.oz.imagesSS.image2
            view.oz.ssImage2x.src = view.oz.imagesSS.image2
        else 
            onLoadAssets()


    onLoadAssets = () =>

        view.oz.ss.image1FullSize = [view.oz.ssImage.width, view.oz.ssImage.height]
        view.oz.locale = new Locale
        view.oz.locale.on 'complete', requestImage
        view.oz.locale.init()


    render = (event) =>

        # Save webservice request
        view.oz.result = if event.result then event.result else event

        switch view.oz.module
            when 'cutout'
                if event.result.approved
                    view.oz.view = new AppViewCutout
                else
                    view.oz.view = new ErrorMessage
            when 'music'
                view.oz.view = new AppViewMusic
                initEnterFrame()
            when 'zoe'
                if event.result.approved
                    view.oz.view = new AppViewZoe
                else
                    view.oz.view = new ErrorMessage

    requestImage = =>
        switch view.oz.module
            when 'music'

                $.ajax
                    url : "/api/music/#{getIdRequest()}"
                    error : =>
                        view.oz.view = new ErrorMessage
                    success : render

            else 
                $.ajax
                    url : "/api/image/info/#{getIdRequest()}"
                    error : =>
                        view.oz.view = new ErrorMessage
                    success : render      

    onError = (event) =>
        console.log event

    # INIT ENTER FRAME
    initEnterFrame = =>

        window.requestAnimationFrame initEnterFrame
        view.oz.view.onEnterFrame?()

    view.oz.module = getModule()
    
    view.oz.ss = new CollectionAssets
    view.oz.ss.url = "/js/ss/extra_pages.json"
    view.oz.ss.fetch
        success : onSuccess
        error   : onError

