$ ->

    window.debug = (str)->
        $("#debug").prepend(str + "<br>")

    window.getBrowser = ->
        standalone = window.navigator.standalone
        userAgent = window.navigator.userAgent.toLowerCase()
        safari = /safari/.test( userAgent )
        ios = /iphone|ipod|ipad/.test( userAgent )

        if( ios )
            
            if ( !standalone and safari )
                return 'browser'
                
            else if ( standalone and !safari )
                return 'standalone'
                
            else if ( !standalone and !safari )
                return 'uiwebview'
            
        else
            return 'not iOS'

        @

    $(window).load ->

        debug Modernizr.websockets
        
        if @getBrowser() != 'browser' and @getBrowser() != 'not iOS'
            $('#nonSupported').show()
            $('#interface').hide()
            return

        href = window.location.href
        lastSlash = href.lastIndexOf "/"
        code = href.substr lastSlash + 1, href.length

        if code
            $('#controllerCode').val(code)

        socket = new MobileSocket
        controller = new MobileController socket