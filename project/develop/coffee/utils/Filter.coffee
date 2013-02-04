class Filter

    @getPixels: (img) =>

        c = @getCanvas img.width, img.height
        ctx = c.getContext "2d"
        ctx.drawImage img, 0, 0

        ctx.getImageData 0, 0, c.width, c.height

    @getCanvas: (w, h) =>

        c = document.createElement "canvas"
        c.width = w
        c.height = h
        
        c

    @filterImage: (filter, image, var_args) =>

        args = [@getPixels(image)]

        for i in [2...arguments.length]
            args.push arguments[i]

        filter.apply null, args

    @saturation: (pixels, saturation) =>

        d = pixels.data

        for i in [0...d.length] by 4

            r = d[i]
            g = d[i+1]
            b = d[i+2]

            average = (r + g + b) / 3.0           

            if saturation > 0.0
                r += (average - r) * (1.0 - 1.0 / (1.001 - saturation))
                g += (average - g) * (1.0 - 1.0 / (1.001 - saturation))
                b += (average - b) * (1.0 - 1.0 / (1.001 - saturation))
            else
                r += (average - r) * (-saturation)
                g += (average - g) * (-saturation)
                b += (average - b) * (-saturation)

            d[i] = r
            d[i+1] = g
            d[i+2] = b

        pixels

    @brightnessContrast: (pixels, brightness, contrast) =>

        d = pixels.data

        for i in [0...d.length] by 4

            r = d[i]
            g = d[i+1]
            b = d[i+2]

            r += brightness
            g += brightness
            b += brightness
            
            if contrast > 0.0
                r = (r - 0.5) / (1.0 - contrast) + 0.5
                g = (g - 0.5) / (1.0 - contrast) + 0.5
                b = (b - 0.5) / (1.0 - contrast) + 0.5
            else
                r = (r - 0.5) * (1.0 + contrast) + 0.5
                g = (g - 0.5) * (1.0 + contrast) + 0.5
                b = (b - 0.5) * (1.0 + contrast) + 0.5

            d[i] = r
            d[i+1] = g
            d[i+2] = b

        pixels