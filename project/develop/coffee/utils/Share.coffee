class Share

    @openWin : (url, w, h) =>

        left = ( screen.availWidth  - w ) >> 1
        top  = ( screen.availHeight - h ) >> 1

        window.open url, '', 'top='+top+',left='+left+',width='+w+',height='+h+',location=no,menubar=no'
        null

    @plus : ( url ) =>
        @openWin "https://plus.google.com/share?url=" + url, 650, 385
        null

    @facebook : ( url, copy) => 
        yourTextHere = encodeURIComponent(copy)
        @openWin "http://www.facebook.com/share.php?u=#{url}&t=#{yourTextHere}", 600, 300
        null

    @twitter : ( url , copy) =>
        yourTextHere = encodeURIComponent(copy)
        @openWin "http://twitter.com/intent/tweet/?text=#{yourTextHere}&url=#{url}", 600, 300
        null

    @renren : ( url ) => 
        @openWin "http://share.renren.com/share/buttonshare.do?link=" + url, 600, 300
        null

    @weibo : ( url ) => 
        @openWin "http://service.weibo.com/share/share.php?url=" + url + "&language=zh_cn", 600, 300
        null
