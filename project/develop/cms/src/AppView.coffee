class AppView extends Backbone.View

    el: $(".wrapper")
    
    preloader: null
    currentView: null

    initialize: ->

        # Load templates
        @preloader = new AssetLoader
        @preloader.on PreloaderEvents.COMPLETE, @onFileComplete
        @preloader.on PreloaderEvents.PROGRESS, @onProgress
        @preloader.on PreloaderEvents.FAIL, @onFail
        @preloader.loadFiles [{ "id" : "templates", "src" : _globals.ROOT + "template/templates.xml" }]

        # Listen resize
        view.onresize = @resizeHandler

# -----------------------------------------------------
# Template loader events
# -----------------------------------------------------

    onProgress: (event) =>

        # console.log event

        @

    onFail: (event) =>

        # console.log event

        @

    onFileComplete: (event) =>

        view.oz.templates = new Templates event.result

        @startRoute()

# -----------------------------------------------------
# Router manager
# -----------------------------------------------------

    startRoute: =>

        view.oz.appRouter.on AppRouter.EVENT_HASH_CHANGED, @changeView
        view.oz.appRouter.start()

    changeView: (page) =>

        # Clean wrapper content
        @$el.empty()

        # Add content
        switch page

            when HeaderView.buttons[0].id, HeaderView.buttons[1].id, HeaderView.buttons[2].id
                
                r = @checkPermissions()
                r.done (result) =>

                    view.oz.role = result.result.role
                    
                    @updateHeader true, page

                    @currentView = new GalleryView page

                    view.onresize()

                r.error (result) =>

                    view.oz.appRouter.navigateTo "/cms"

            when HeaderView.buttons[3].id, HeaderView.buttons[4].id

                r = @checkPermissions()
                r.done (result) =>

                    view.oz.role = result.result.role

                    @updateHeader true, page

                    @currentView = new LocaleView page

                    view.onresize()

                r.error (result) =>

                    view.oz.appRouter.navigateTo "/cms"


            when "home"

                r = @checkPermissions()
                r.done (result) =>

                    view.oz.role = result.result.role
                    
                    @updateHeader true, page

                r.error (result) =>

                    view.oz.appRouter.navigateTo "/cms"


            else

                @updateHeader false
                @currentView = new LoginView

    updateHeader: ( visible, id = null ) =>

        # Show / Hide 
        if !visible
            if $(".header")[0]
                $(".header")[0].remove()
        else
            if !$(".header")[0]
                new HeaderView

        # Update highlighted button
        if id
            for i in [HeaderView.buttons.length-1..0]
                if id == HeaderView.buttons[i].id
                    $("#"+id).removeClass "hover"
                    $("#"+id).addClass "selected"
                else
                    $("#"+HeaderView.buttons[i].id).removeClass "selected"

    checkPermissions: () =>

        r = $.ajax {
                type: "GET",
                url: "/api/user/status",
                data: null
            }

        r

# -----------------------------------------------------
# Router manager
# -----------------------------------------------------

    resizeHandler: ( event ) =>

        $(".header .center").css( "width" : $(window).width() - ( @getWidth( $(".header .left") ) + $(".header .left").width() + @getWidth( $(".header .right") ) + $(".header .right").width() ) - @getWidth( $(".header .center") ) )

        if @currentView?
            nThumbs = Math.floor(($(window).width() * 0.95) / @currentView.THUMB_WIDTH)
            $(".gallery").css( "width" : nThumbs * (@currentView.THUMB_WIDTH + 1))

    getWidth: ( div ) =>

        # w = div.width()
        w = parseInt(div.css("padding-left"), 10) + parseInt(div.css("padding-right"), 10)
        w += parseInt(div.css("margin-left"), 10) + parseInt(div.css("margin-right"), 10)
        w += parseInt(div.css("borderLeftWidth"), 10) + parseInt(div.css("borderRightWidth"), 10)

        w

