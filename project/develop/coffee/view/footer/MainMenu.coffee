class MainMenu extends Abstract

    template    : 'menu'
    className   : "menu"
    openMenuBtn : null
    buttonList  : null
    opened      : false
    disableOpen : false

    constructor : ->
        @templateVars = 
            open      : @oz().locale.get 'menuOpen'
            official  : @oz().locale.get 'menuOfficial'
            tech      : @oz().locale.get 'menuTech'
            credits   : @oz().locale.get 'menuCredits'
            terms     : @oz().locale.get 'menuTerms'
            privacy   : @oz().locale.get 'menuPrivacy'

        super()

    init : =>

        @buttonList = @$el.find '.menu_buttons'
        @openMenuBtn = @$el.find '.open_menu'
        
        @openMenuBtn.find('span').mouseover @showMenu
            
        @$el.find(".button").each (index, value) =>
            $(value).bind "click", (event) =>
                deep = $(event.currentTarget).attr 'deep'
                switch deep
                    when "terms"
                        Analytics.track 'menu_click_terms'
                        window.open '/tou.html'
                    when "privacy"
                        Analytics.track 'menu_click_privacy'
                        window.open '/pp.html'
                    when "tech"
                        Analytics.track 'menu_click_tech'
                        window.open 'http://www.html5rocks.com/en/tutorials/casestudies/oz/'
                    when 'official'
                        Analytics.track 'menu_click_official'
                        window.open '/official.html'
                    else 
                        Analytics.track 'menu_click_credits'
                        @oz().appView.static.changePage deep

                SoundController.send "btn_generic_click"

            $(value).bind "mouseover", (event) =>
                SoundController.send "btn_generic_over"
                

    toggleMenu : =>

        if @disableOpen
            return
            
        @toggleItem @openMenuBtn
        @toggleItem @buttonList

        @opened = !@opened

        if @opened
            @oz().appView.showMap(false)
            @oz().appView.footer.showShare()
        else
            @oz().appView.showMap()
            @oz().appView.footer.showCC()

    showMenu : =>

        @oz().appView.map.hide false

        @hideThis @openMenuBtn
        @showThis @buttonList

        @opened = true

        $('body').unbind 'mousemove'
        $('body').bind 'mousemove', @onMouseMove
        
        @oz().appView.footer.showShare()

    hideMenu : =>

        @oz().appView.showMap()

        @hideThis @openMenuBtn
        @hideThis @buttonList

        @opened = false

        $('body').unbind 'mousemove'

    showThis : ( item ) =>

        item.css { "visibility" : 'visible' }
        item.stop().animate { "opacity" : 1 }, { duration: 300 }

    hideThis : ( item ) =>

        item.stop().animate { "opacity" : 0 }, { duration: 100, complete : => item.css { "visibility" : 'hidden' } }

    onMouseMove : (event) =>
        if event.originalEvent.clientY < $(window).innerHeight() - @$el.height() - 60
            $('body').unbind 'mousemove', @onMouseMove
            @toggleMenu()

    disableMouseMove : (val) =>
        $('body').unbind 'mousemove'
        @disableOpen = val

    toggleItem : (item) =>
        visible = item.css 'visibility'
        if visible == 'hidden' then @showThis item else @hideThis item


    show : (animated) =>

        @$el.css { display:""}
        super animated

    hide : (animated, callback) =>

        super animated, =>
            callback?()
            @$el.css { display:"none"}
