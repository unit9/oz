class MobileController extends AbstractController

    initialize : (socket) =>

        super socket

        $('#connectButton').click @submit

        @


    onSocketOpen : (event) =>

        console.log event

        @service.sendMessage JSON.stringify 
            action : 'connect', 
            client : 'mobile',
            code   : $('#controllerCode').val()

        @

    onSocketClose : (event) =>

        $('#status').addClass('btn-danger')
        $('#status').removeClass('btn-success')
        $('#status').html('Offline')

        @service.sendMessage JSON.stringify
            action : 'send', 
            message: 
                'mobile' : 'disconnected'

        $(window).unbind 'deviceorientation', @onDeviceMotion

        @

    onSocketMessage : (event) =>

        data = JSON.parse event.data
        console.log data
        
        switch data.status
            when 'connected' 
                @onJoinSession()

            when 'send'
                if data.message.indexOf('mobile:') > -1
                    return

                console.log data
        @


    onJoinSession : () =>
        
        $('#status').removeClass('btn-danger')
        $('#status').addClass('btn-success')
        $('#status').html('Connected')

        @service.sendMessage JSON.stringify
            action : 'send', 
            message: 
                'mobile' : 'connected'

        $(window).bind 'deviceorientation', @onDeviceMotion


    onDeviceMotion : (event) =>

        evt = event.originalEvent
        @sendDeviceMotion evt.beta, evt.gamma


    sendDeviceMotion : ( xx, yy ) =>

        debug (xx + ", " + yy)

        @service.sendMessage JSON.stringify
            action : 'send'
            message: 
                'mobile' : 'coordinates',
                'x'      : xx,
                'y'      : yy,
        

    submit : (evt) =>

        evt.preventDefault()
        evt.stopPropagation()

        @service.init()

