class MobileSocket

    ws      : null
    ready   : false

    constructor :->
        _.extend @, Backbone.Events


    init : (host = "ws://svn520.dev.unit9.net:55432/ws") ->

        @ws = new WebSocket host
        @ws.onclose     = @onSocketClose
        @ws.onopen      = @onSocketOpen
        @ws.onmessage   = @onSocketMessage

        @


    onSocketClose : (event) =>

        @ready = false

        @trigger ControllerEvents.SOCKET_CLOSE

        @


    onSocketOpen : (event) =>

        @trigger ControllerEvents.SOCKET_OPEN

        @


    onSocketMessage : (event) =>

        @trigger ControllerEvents.SOCKET_MSG, event

        @

    sendMessage : ( msg ) =>

        @ws.send msg

        @
