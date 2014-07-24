class LocalisedTexture

    title     : null
    canvas    : null
    ctx       : null
    flourish  : null
    diamond   : null
    wHalf : null
    icon : null

    ###
    Usage: 
        @oz().localeTexture.get 'section'
    ###

    constructor : ->
        @diamond = window.oz.baseAssets.get("diamond").result
        $('<p style="font-family: \"TradeGothic\"" />')
        null


    get : (section) =>

        @icon = window.oz.baseAssets.get("section_icon_#{section}").result

        @canvas = document.createElement 'canvas'
        @canvas.width = 1000
        @canvas.height = 1000
        @ctx = @canvas.getContext '2d'

        @wHalf = parseInt(@canvas.width) / 2

        @ctx.drawImage @diamond, (@wHalf - 4), 0
        @ctx.drawImage @icon, (@wHalf - 30), 15

        headerCopy = window.oz.locale.get section + "Title"
        @ctx.font = '46px TradeGothic'
        @ctx.save()
        @ctx.fillStyle = '#FFF'
        @ctx.textAlign = 'center'
        @ctx.textBaseline = 'top'
        textSize = @wrapText @ctx, headerCopy, (@wHalf), 88, 400, 46

        #subCopy = window.oz.locale.get section + "CTA"
        subCopy = "" 

        if subCopy.length > 0
            @ctx.font = '14px TradeGothic'
            @ctx.save()
            @ctx.fillStyle = '#FFF'
            @ctx.textAlign = 'center'
            @ctx.textBaseline = 'top'
            textSize = @wrapText @ctx, subCopy, (@wHalf), textSize, 400, 14
            
        @ctx.drawImage @diamond, (@wHalf - 4), textSize + 5

        return @trim()

    wrapText : (context, text, x, y, maxWidth, lineHeight) =>

        words = text.split(' ')
        line = ''
        nextLine = false

        for n in [0...words.length]
            word = words[n]
            br = false

            if word.indexOf("<br>") > -1
                word = word.replace('<br>', ' ')
                br = true
                testLine = line

            testLine = line + word + ' '
            
            metrics = context.measureText(testLine)
            testWidth = metrics.width

            if(testWidth > maxWidth or br)
                context.fillText(line, x, y)
                line = word + ' '
                y += lineHeight
            else
                line = testLine

        context.fillText(line, x, y)
        return y + lineHeight
      
    
    trim : () =>

        c      = @canvas
        copy   = document.createElement('canvas').getContext('2d')
        pixels = @ctx.getImageData(0, 0, c.width, c.height)
        l      = pixels.data.length
        
        bound = {
          top    : null
          left   : null
          right  : null
          bottom : null
        }

        for i in [0..l-1] by 4
            
            if (pixels.data[i+3] != 0)
              x = (i / 4) % c.width
              y = ~~((i / 4) / c.width)

              bound.top = y if (bound.top == null)
                
              if (bound.left == null)
                bound.left = x 
              else if (x < bound.left)
                bound.left = x
              
              if (bound.right == null)
                bound.right = x
              else if (bound.right < x)
                bound.right = x
              
              if (bound.bottom == null)
                bound.bottom = y
              else if (bound.bottom < y)
                bound.bottom = y


        bound.width = Math.max(bound.right - bound.left, 180)
        bound.height = Math.max(bound.bottom - bound.top, 145)
        
        trimWidth  = 1024
        trimHeight = 1024
        
        trimmed = @ctx.getImageData(bound.left, bound.top, trimWidth, trimHeight)

        copy.canvas.width = trimWidth
        copy.canvas.height = trimHeight
        copy.putImageData(trimmed, trimWidth / 2 - (bound.right - bound.left)/ 2, trimHeight / 2 - (bound.bottom - bound.top)/ 2)

        return {canvas: copy.canvas , bound: bound }
