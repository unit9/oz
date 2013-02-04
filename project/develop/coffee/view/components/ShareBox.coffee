class ShareBox extends Abstract

    className : "shareContainer"
    template  : "sharebox"

    iconsContainer : null
    shareLinkCont  : null
    linkIcon       : null
    callback       : null
    shareType      : null

    initialize : (title, sub, back, backCall, link, type) =>

        @templateVars =
            title      : title
            sub        : sub
            link       : link
            shareBack  : back
            shareLegal : @oz().locale.get 'shareBoxExpiry'

        @shareType = type

        @callback = backCall

        super()
        null

    init: =>

        @iconsContainer = @$el.find('.shareIconsRow')

        # Add social depending on language.
        # Google, Facebook, Twitter for all languages except Chinese that are Renren, Weibo
        if (@oz().locale.lang).indexOf("zh-") == 0
            @iconsContainer.append "<button_renren /><button_weibo />"
        else
            @iconsContainer.append "<button_google /><button_facebook /><button_twitter />"
        
        @iconsContainer.children().each (index, value) =>

            shareButton = new SSAsset 'interface', $(value)[0].tagName.toLowerCase()

            shareButton.addClass 'shareIcon'
            shareButton.$el.attr "id", $(value)[0].tagName.toLowerCase()

            @iconsContainer.append shareButton.$el

            shareButton.$el.css
                width : "#{parseInt(shareButton.$el.css('width'))+2}px"

            shareButton.$el.bind "click", @onShare

            $(value).remove()

        @shareLinkCont = @$el.find('.shareLinkContainer').find('.abstractbutton')

        @linkIcon = new SSAsset 'interface', 'link_icon'
        @linkIcon.$el.bind 'click', @onLinkClick
        @linkIcon.$el.addClass 'shareLinkIcon'
        @shareLinkCont.prepend @linkIcon.$el

        shareBackBtn = @$el.find '.shareBack'
        shareBackBtn.bind 'click', @onBackClick

        # Fix alignment button (Chrome Win / Chrome OSx)
        if navigator.appVersion.indexOf("Win") != -1
            shareBackBtn.css {"padding" : "7px 20px 8px 20px"}
            @shareLinkCont.css {"padding" : "3px 12px 7px 12px"}

        null

    onLinkClick : =>
        Analytics.track(@shareType + '_open_preview')
        window.open @shareLinkCont.find('input').val()
        null

    onBackClick : =>

        Analytics.track 'cutout_take_another'
        
        @callback?()
        @trigger 'removeShareBox'
        null

    onShare: ( item ) =>

        switch item.currentTarget.id

            when "button_facebook"

                Analytics.track(@shareType + "_share_fb", @getFloodlight("Facebook"))

                Share.facebook(@templateVars.link, @oz().locale.get("share_#{@shareType}_facebook_default_message"))

            when "button_google"

                Analytics.track(@shareType + "_share_gplus", @getFloodlight("Google"))
                
                Share.plus @templateVars.link

            when "button_twitter"

                Analytics.track(@shareType + "_share_twitter", @getFloodlight("Twitter"))
                
                Share.twitter(@templateVars.link,@oz().locale.get("share_#{@shareType}_facebook_default_message"))

            when "button_renren"

                Analytics.track(@shareType + "_share_renren")

                Share.renren @templateVars.link

            when "button_weibo"

                Analytics.track(@shareType + "_share_weibo")

                Share.weibo @templateVars.link

        null

    getFloodlight : (vendor) =>

        switch @shareType
            when 'zoe'
                return "Google_OZ_Zeotrope_SocialClick_#{vendor}"

            when 'cutout'
                return "Google_OZ_HoleInFace_SocialClick_#{vendor}"

        null

            

    dispose: =>
        null