$ ->
    
    window.URL = (window.URL || window.webkitURL)
    navigator.getUserMedia = (navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia)
    
    cam = null

    $(document).ready ->

        console.log "* App ready"

        cam = new Cam $("video")[0], false
        cam.start()

        $( cam ).bind "camReady", create3D

        if !Detector.webgl
            Detector.addGetWebGLMessage()

    create3D = ( event ) ->

        cam.startRender()

        video3d = new Video3D cam     