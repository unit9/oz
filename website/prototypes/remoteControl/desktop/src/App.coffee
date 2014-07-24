$ ->

    window.debug = (str)->
        $("#debug").prepend(str + "<br>")

    window.generateCode =->
        $('#response').html(Math.round(Math.random() * 999999))

    $(window).load ->
        socket = new MobileSocket
        socket.init()
        controller = new DesktopController socket


    #generateCode()

    


    