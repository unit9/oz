class AppView extends Backbone.View

    tagName : 'div'

    initialize: =>

        @setElement $('.container')

        @canvasTexture = document.createElement 'canvas'
        @canvasTexture.style.border = "1px solid #FF0000"
        @canvasTexture.width = 384
        @canvasTexture.height = 512

        @ctxTexture = @canvasTexture.getContext '2d'

        @canvasRef = document.createElement 'canvas'
        @canvasRef.id = 'canvasRef'
        @canvasRef.width = 7692
        @canvasRef.height = 360
        @ctxRef = @canvasRef.getContext '2d'

        @img = new Image()
        @img.onload = =>
            @ctxRef.scale(.2, .2)
            @ctxRef.drawImage(@img, 0, 0)
            @drawTexture()
        @img.src = "img/img.jpeg"

        @$el.append @canvasRef
        @$el.append @canvasTexture

    drawTexture : =>
        line = 0
        col = 0

        for i in [0...12]
        
            imgData = @ctxRef.getImageData i * 128, 0, 128, 72

            w = col * 128
            h = 28 + (128 * line)

            @ctxTexture.putImageData(imgData, w, h)

            if col == 2
                col = 0
                line++
            else 
                col++

        @