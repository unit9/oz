class ThumbCutout extends Backbone.View

    fullImg : null
    thumb : null
    polaroid : null
    src : null

    initialize: (id) =>

        @setElement $('.wrapper')

        @fullImg = $('<div/>')
        @fullImg.addClass 'imgAnim'
        
        @thumb = $('.wrapper img')
        @fullImg.append @thumb

        @$el.append @fullImg

        @thumb.bind 'load', =>

            @polaroid = new Image
            @polaroid.onload = =>

                @thumb.addClass 'imgLoaded'
                
                @fullImg.append @polaroid
                @initAnimation()

            @polaroid.src = '/img/preview/cutout_polaroid.png'

        @src = ""

        if window.location.href.indexOf(':8888') > -1
            @src = "/img/preview/1.jpeg"
        else 
            @src = "/api/image/get/" + id


        @thumb.attr
            src : @src

        @fullImg.on 'webkitAnimationEnd', () =>
            $(document).trigger 'thumbTransitionEnded'

        null

    initAnimation: =>
        @fullImg.addClass 'img'
        null


