$ ->
    
    window.URL = (window.URL || window.webkitURL)
    navigator.getUserMedia = (navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia)

    $(document).ready ->

        console.log "* App ready"

        # Create michrophone
        mic = new Mic

        # Effects Controller
        effects =
        {
            available : {
                normal      : -1,
                delay       : 0,
                doubler     : 1,
                distortion  : 2,
                flange      : 3
            }
        }

        # Add and position dat.gui
        gui             = new dat.GUI { autoPlace: false }
        customContainer = $(".dat-gui")[0]
        customContainer.appendChild gui.domElement

        # Effects folder
        effectsF        = gui.addFolder "Choose an effect"
        effectsSelect   = effectsF.add effects, 'available', effects.available
        effectsSelect.listen()
        effectsF.open()

        # Delay effect
        delayF          = gui.addFolder "Delay"
        delayF.add mic, "delayTime", 0.15, 3

        # Doubler effect
        doublerF        = gui.addFolder "Doubler"
        doublerF.add mic, "doublerDelay", 0.1, 1

        # Distortion effect
        distortionF     = gui.addFolder "Distortion"
        distortionF.add mic, "distortionDrive", 0, 40

        # Flange effect
        flangeF         = gui.addFolder "Flange"
        flangeF.add mic, "flangeDelay", 0.001, 0.02, 0.001
        flangeF.add mic, "flangeDepth", 0.0005, 0.005, 0.00025
        flangeF.add mic, "flangeSpeed", 0.05, 5, 0.05
        flangeF.add mic, "flangeFeedback", 0, 1, 0.01

        # Change events
        effectsSelect.onChange ( value ) =>

            switch Number value
                when -1

                    console.log "Normal"
                    
                    delayF.close()
                    doublerF.close()
                    distortionF.close()
                    flangeF.close()


                when 0

                    console.log "Delay"

                    delayF.open()
                    doublerF.close()
                    distortionF.close()
                    flangeF.close()
                    

                when 1

                    console.log "Doubler"

                    delayF.close()
                    doublerF.open()
                    distortionF.close()
                    flangeF.close()

                when 2

                    console.log "Distortion"
                    delayF.close()
                    doublerF.close()
                    distortionF.open()
                    flangeF.close()

                when 3

                    console.log "Flange"
                    delayF.close()
                    doublerF.close()
                    distortionF.close()
                    flangeF.open()

                else

                    console.log "none"

            mic.changeEffect Number value
        
        # Default effect
        effects.available = 1
        doublerF.open()

        # Canvas simple visualizer
        $("canvas")[0].width = $(document).width()
        $("canvas")[0].height = $(document).height() - 122