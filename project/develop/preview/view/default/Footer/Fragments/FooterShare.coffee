class FooterShare extends Backbone.View

    className: 'footer-share'

    initialize: () =>

        @lang = (navigator.language || navigator.userLanguage).toLowerCase()

        if @lang.indexOf("zn") == -1

            @$googleBtn = $('<div/>')
            @$googleBtn.attr
                "id" : 'g-plusone'
                'class': 'g-plusone'
                'align': 'right'
                'data-size': 'medium'

            @$facebookBtn = $('<iframe/>')
            @$facebookBtn.attr 
                'class': 'fb-like'
                'src': "//www.facebook.com/plugins/like.php?send=false&layout=button_count&href=" + document.location.origin
                'scrolling' : "no" 
                "frameborder" : "0"

            @$twitterBtn = $('<a/>')
            @$twitterBtn.attr
                'class': 'twitter-share-button'
                'href': 'https://twitter.com/share'
                'data-via': 'unit9'
                'data-lang': @lang
                'data-size': 'small'
                'data-hashtags' : @oz().locale.get 'seo_twtter_hashtag'
                'data-text'     : @oz().locale.get 'seo_twtter_default_text'
                'data-via'      : @oz().locale.get 'seo_twitter_handle'

            @$el.append @$googleBtn
            @$el.append @$twitterBtn
            @$el.append @$facebookBtn

        else
            @addWeibo()
            @addRenRen()
            

    addRenRen : =>
        p = []
        w = 130
        h = 20
        lk = {url:'' || window.location.href, title:'' || document.title, description:'', image:''}
        
        p.push(k + "=" + encodeURIComponent(v || '')) for k, v of lk

        @renren = $("<iframe scrolling=\"no\" frameborder=\"0\" allowtransparency=\"true\" src=\"http://www.connect.renren.com/like/v2?#{p.join("&")}\" style='width:#{w}px; height:#{h}px;'/>")
        @$el.append @renren


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

        @$el.append @weibo
    

    oz : =>

        return (window || document).oz
