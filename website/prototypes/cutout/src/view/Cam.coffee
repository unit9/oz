class Cam extends Backbone.View

    tagName : "canvas"
    cutout  : null
    ctx     : null

    initialize :=>

        @

    setBackground : ->
        @cutout = new Image()
        @cutout.onload = =>
            @ctx.drawImage @cutout, 0, 0

        @cutout.src = "images/cutout.png"

        @

    render :=>
        @$el.attr 'width', 566
        @$el.attr 'height', 800
        @$el.css
            position : 'absolute'


        @ctx = @el.getContext '2d'
        @ctx.translate 566, 0
        @ctx.scale -1, 1

        @setBackground()
        @

    renderVideo : (video) =>
        
        @ctx.drawImage video, 0, 140
        @ctx.drawImage @cutout, 0, 0
