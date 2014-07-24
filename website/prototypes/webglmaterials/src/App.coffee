$ ->

    $(document).ready ->

        console.log "* App ready"

        if !Detector.webgl
            Detector.addGetWebGLMessage()
        else
            scene3D = new Scene3D