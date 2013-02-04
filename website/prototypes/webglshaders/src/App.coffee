$ ->
    
    window.URL = (window.URL || window.webkitURL)
    navigator.getUserMedia = (navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia)
    
    cam = null
    shader = null

    $(document).ready ->

        console.log "* App ready"

        cam = new Cam $("video")[0], false
        cam.start()

        $( cam ).bind "camReady", create3D

        if !Detector.webgl

            Detector.addGetWebGLMessage()

        shader = getQueryString()["shader"]
        if shader == undefined
            shader = 1

    create3D = ( event ) ->

        cam.startRender()

        video3d = new Video3D cam, shader

    getQueryString = () ->

        result = {}
        queryString = location.search.substring(1)
        re = /([^&=]+)=([^&]*)/g
        m = null

        while (m = re.exec(queryString))
            result[decodeURIComponent(m[1])] = decodeURIComponent(m[2])

        result       