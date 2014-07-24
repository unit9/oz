class DesktopController extends AbstractController

    onSocketOpen : (event) =>

        console.log event

        @service.sendMessage JSON.stringify 
            action : 'connect'
            client : 'desktop'

        @

    onSocketClose : (event) =>

        $('#status').addClass('btn-danger')
        $('#status').removeClass('btn-success')
        $('#status').html('Offline')

        @

    onSocketMessage : (event) =>

        data = JSON.parse event.data

        console.log data

        if data.status
            @filterAction data.status, data.code
            return

        if data.action
            @filterMessage data.payload
            return
                

    filterAction : (status, code) =>

        switch status

            when 'connected'
                url = window.location.href.split("desktop").join("mobile") + "?" + Math.round(Math.random() * 99999)+ "/" + code
                console.log url
                $('#response').html "<img src='http://chart.apis.google.com/chart?cht=qr&chl="+url+"&chs=200x200'>"


    filterMessage : (resp) =>

        console.log resp, resp.mobile

        switch resp.mobile

            when 'connected'

                $('#status').removeClass('btn-danger')
                $('#status').addClass('btn-success')
                $('#status').html('Connected')

            when 'disconnected'

                $('#status').addClass('btn-danger')
                $('#status').removeClass('btn-success')
                $('#status').html('Offline')

            when "coordinates"

                #debug (resp.x + ", " + resp.y)

                t = parseFloat($('#box').css('top')) + (resp.x / 10)
                l = parseFloat($('#box').css('left')) + (resp.y / 10)

                t = Math.max( 0 , Math.min($(window).innerHeight() - 100, t))
                l = Math.max( 0 , Math.min($(window).innerWidth() - 100, l))

                $('#box').css
                    'top'  : t + "px",
                    'left' : l + "px"
                  

