class ThumbZoe extends Backbone.View

    tagName : 'div'
    # bg      : null
    currentFrame : 0
    totalFrames : 0
    ratio : 1.777777778
    imgRatio : 0
    __w   : 0

    initialize:  =>
        @

    init : (id) =>

        @bg = new Image
        @bg.onload = (img) =>

            @__w = document.width
            @imgRatio = @bg.width / @bg.height

            if @__w > 600
                @__w = 600

            ###@bg.height = Math.round( @__w / @ratio )
            @bg.width = Math.round( @bg.height * @imgRatio )###

            @$el.append @bg
            @$spriteSheet = @$el.find('img:first-child')

            @$el.css
                'height' : @bg.height
                'width'  : @__w
                'margin-left' : '18px';

            # @overlay = new Image
            # $(@overlay).css {opacity : .3}
            # @$el.append @overlay
            # @overlay.src = '/img/zoetrope/zoetrope_canvas_texture.png'

            @totalFrames = Math.round(@bg.width / @__w)

            setInterval @animate, 150


            @loadComplete()
        
        if window.location.href.indexOf(':8888') > -1 or window.location.href.indexOf('unit9') > -1
            @bg.src = "/api/image/get/example.jpeg"
        else 
            @bg.src = "/api/image/get/" + id


    animate : =>
        @currentFrame++

        if(@currentFrame >= @totalFrames)
            @currentFrame = 0

        @$spriteSheet.css
            'margin-left' : (-@currentFrame * @__w) + 'px'

    getHeight : =>
        return @bg.height

    getWidth : =>
        return @__w

    loadComplete: =>

