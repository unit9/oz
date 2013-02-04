class Analytics

    @tags : null
    @started : false
    @tagsFlood : null 

    @GA_ACCOUNT : '37524215-3'

    @start : =>
        window._gaq = window._gaq or [['_setAccount',"UA-#{@GA_ACCOUNT}"],['_trackPageview']]
        @tags = JSON.parse window.oz.baseAssets.get('trackingTags').result
        @tagsFlood = JSON.parse window.oz.baseAssets.get('trackingTagsFloodlight').result
        @started = true        
        null

    @track : (param, floodlight) =>

        if !@started
            @start()

        if param
            tag = []
            tag.push '_trackEvent'
            v = @tags[param]
            if v?
                for i in [0...v.length]
                    tag.push v[i]

                # TODO: uncomment these lines
                #console.log "[Analytics]: " + tag
                window._gaq.push tag

        if floodlight
            @trackFloodlight floodlight

        null

    @trackFloodlight : (tag) =>

        i = $('#floodlightTrack')
        i.remove() if i.length > 0

        axel = Math.random() + ""
        a = axel * 10000000000000

        cat = @tagsFlood[tag].cat

        iframe = $('<img id="floodlightTrack" />')
        iframe.attr
            src : "http://3944448.fls.doubleclick.net/activityi;src=3944448;type=googl379;cat=#{cat};ord=#{a}?"
            width : 1
            height : 1
            style : "visibility:hidden; position: absolute; top:0; left:0"

        $('body').prepend iframe

        null
