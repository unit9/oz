class ShareMenu extends Abstract

    className : 'share_menu'
    soundEnabled: true

    sound_label : "SOUND"
    sound_label_on: "ON"
    sound_label_off: "OFF"

    render : =>

        if @oz().locale.get("sound_button_label") && @oz().locale.get("sound_button_label") != ""
            @sound_label = @oz().locale.get("sound_button_label")

        if @oz().locale.get("sound_button_on") && @oz().locale.get("sound_button_on") != ""
            @sound_label_on = @oz().locale.get("sound_button_on")

        if @oz().locale.get("sound_button_off") && @oz().locale.get("sound_button_off") != ""
            @sound_label_off = @oz().locale.get("sound_button_off")

        # SOUND
        @sound = $("<div class='sound'>#{@sound_label} <span>#{@sound_label_on}</span></div>")
        @sound.bind "mousedown", @toogleSound # After we have the Sound Manager ok, maybe we can call directly the sound manager method here
        @disableSound()
        @$el.append @sound

        require ["http://platform.twitter.com/widgets.js", "//apis.google.com/js/plusone.js"], @onLibLoaded
    
    rerender :=>

        if @oz().locale.lang.indexOf("zh") == -1

            @$googleBtn = $('<div/>')
            @$googleBtn.attr
                "id" : 'g-plusone'
                'class': 'g-plusone'
                'data-size': 'medium'
            
            @$facebookContainer = $("<div class='facebookShare'></div>")
            @$facebookBtn = $('<iframe/>')
            @$facebookBtn.attr
                'class': 'fb-like'
                'src': "//www.facebook.com/plugins/like.php?send=false&layout=button_count&href=" + document.location.origin
                'scrolling' : "no" 
                "frameborder" : "0"
            @$facebookBtn.css
                'width' : '100px'

            @$facebookContainer.css
                'margin-left' : '20px'


            @$twitterContainer = $("<div class='twitterShare'></div>")
            @$twitterBtn = $('<a/>')
            @$twitterBtn.attr 
                'class': 'twitter-share-button'
                'href': 'https://twitter.com/share'
                'data-lang': @oz().locale.lang
                'data-size': 'small'
                'data-hashtags' : @oz().locale.get 'seo_twtter_hashtag'
                'data-text'     : @oz().locale.get 'seo_twtter_default_text'
                'data-via'      : @oz().locale.get 'seo_twitter_handle'

            @$el.prepend @$twitterContainer
            @$twitterContainer.append @$twitterBtn

            @$el.prepend @$facebookContainer
            @$facebookContainer.append @$facebookBtn

            @$el.prepend @$googleBtn
            
            twttr.widgets.load()
                    
            gapi?.plusone.render 'g-plusone',
                size     : "medium"
                expandTo : 'top'

            @$googleBtn.css
                'width'         : '50px !important'                

        else 
            @addWeibo()
            @addRenRen()

        @$el.append $("<div class='clearfix'></div>")

    onLibLoaded : =>

        @rerender()

    addRenRen : =>
        p = []
        w = 130
        h = 20
        lk = {url:'' || window.location.href, title:'' || document.title, description:'', image:''}
        
        p.push(k + "=" + encodeURIComponent(v || '')) for k, v of lk

        @renren = $("<iframe scrolling=\"no\" frameborder=\"0\" allowtransparency=\"true\" src=\"http://www.connect.renren.com/like/v2?#{p.join("&")}\" style='width:#{w}px; height:#{h}px;'/>")
        @$el.prepend @renren


    addWeibo : =>
        _w = 72 
        _h = 24
        params = {
            url    : window.location.href
            type   : '2'
            count  : '1'
            appkey : ''
            title  : ''
            pic    : ''
            ralateUid : ''
            language : 'zh_cn'
            rnd : new Date().valueOf()
        }

        temp = []
        temp.push(k + '=' + encodeURIComponent( v || '' ) ) for k, v of params

        @weibo = $('<iframe class="weibo_share" allowTransparency="true" frameborder="0" scrolling="no" src="http://hits.sinajs.cn/A1/weiboshare.html?' + temp.join('&') + '" width="'+ _w+'" height="'+_h+'"/>')
        @weibo.css
            "-webkit-transform" : "scale(.85)"
            "margin-top": "-2px"

        @$el.prepend @weibo

    hideSoundButton : =>
        @sound?.css {display : 'none'}

    showSoundButton : =>
        @sound?.css {display : ''}

    enableSound: =>
        @sound?.css { opacity: 1, visibility: "visible" }

    disableSound: =>
        @sound?.css { opacity: 0, visibility: "hidden" }

    toogleSound: =>

        Analytics.track 'menu_click_toggle_sound'

        @soundEnabled = !@soundEnabled
        
        if @soundEnabled

            SoundController.send "sound_on"
            SoundController.resume true
            
            @sound.find("span").html @sound_label_on

        else

            @sound.find("span").html @sound_label_off

            SoundController.paused true

