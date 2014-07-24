$ ->

    angleX = 0
    angleY = 0
    clicked = false
    flipped = false

    $(window).mousemove (event) ->

        if clicked == true 
            return

        x = (((event.clientX - ($(window).innerWidth() / 2) )) / 40) 
        y = (((event.clientY - ($(window).innerHeight() / 2) )) / 35)

        angleX += (x - angleX)
        angleY += (y - angleY)

        angleX = angleX % 360
        angleY = angleY % 360

        angleX *= -1 if flipped == true

        $('#card').css 
            'left' : (($(window).innerWidth() - 229) >> 1) + 'px'
            'top' : ((($(window).innerHeight() - 90) - 334) >> 1) + 'px'
            'transform' : 'perspective( 334px ) rotateY( '+angleX+'deg ) rotateX( '+angleY+'deg )'


    $(window).click ->

        clicked = true
        
        $('#card').transition
            perspective : '334px'
            rotateY : '-90deg'
        , 300, 'in', ->

            $('#card #cardImgBack').css 
                display : (if flipped == true then 'none' else 'block')
                'transform' : 'rotateY(-180deg)'

            $('#card').transition
                perspective : '334px'
                rotateY : '-180deg'

            , 300, 'out', ->

                $('#card #cardImgBack').css 
                    display : (if flipped == true then 'none' else 'block')

                angleX = -180

                flipped = !flipped
                clicked = false
