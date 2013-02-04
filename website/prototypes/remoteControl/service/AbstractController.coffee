class AbstractController extends Backbone.View

    service : null
    tagName : 'body'

    initialize : (socket) =>
        @service = socket
        @service.on ControllerEvents.SOCKET_OPEN  , @onSocketOpen
        @service.on ControllerEvents.SOCKET_CLOSE , @onSocketClose
        @service.on ControllerEvents.SOCKET_MSG   , @onSocketMessage
        

    onSocketOpen : (event) =>

        @

    onSocketClose : (event) =>

        @

    onSocketMessage : (event) =>

        @
         

    onJoinSession : () =>
        
        @