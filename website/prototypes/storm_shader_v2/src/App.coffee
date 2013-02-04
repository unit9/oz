App = this

$ ->

    $(document).ready ->

        console.log "* App ready"

        # Init app
        if !Detector.webgl
                Detector.addGetWebGLMessage()
            else
                App.scene3D = new Scene3D
             