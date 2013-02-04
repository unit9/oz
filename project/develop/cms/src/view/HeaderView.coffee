class HeaderView extends Backbone.View

    el : $("body")

    @buttons: [
        { label: "ZOETROPE GALLERY", id: "zoetrope", link: _globals.ROOT + "zoetrope", roles: [0, 1] },
        { label: "CUTOUT DESKTOP", id: "cutoutDesktop", link: _globals.ROOT + "cutoutDesktop", roles: [0, 1] },
        { label: "CUTOUT MOBILE", id: "cutoutMobile", link: _globals.ROOT + "cutoutMobile", roles: [0, 1] },
        { label: "LOCALE DESKTOP", id: "localeDesktop", link: _globals.ROOT + "localeDesktop", roles: [0, 2] },
        { label: "LOCALE MOBILE", id: "localeMobile", link: _globals.ROOT + "localeMobile", roles: [0, 2] },
        { label: "LOGOUT", id: "logout", link: _globals.ROOT + "logout", roles: [0, 1, 2] }
    ]

    initialize: =>

        @render()

    render: =>

        $(@el).prepend view.oz.templates.get "header"

        @addMenu()

    addMenu: =>

        console.log 'role -> ' + view.oz.role

        for i in [0..HeaderView.buttons.length-1]

            show = false

            for a in HeaderView.buttons[i].roles
                if a.toString() == view.oz.role.toString()
                    show = true
                    break

            if show
                button = _.template view.oz.templates.get "headerButton"
                $(".header .left ul").append button HeaderView.buttons[i]

                @addButtonListener HeaderView.buttons[i].id
                

    addButtonListener: ( button ) =>
        
        $("#"+button).click (event) ->
            if button != "logout"
                event.preventDefault()
                view.oz.appRouter.navigateTo button

        $("#"+button).hover (event) ->
            if !$(this).hasClass("selected")
                $(this).addClass "hover"

        $("#"+button).mouseout (event) ->
            $(this).removeClass "hover"
