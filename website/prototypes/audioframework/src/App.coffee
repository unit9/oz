App = this

$ ->

    $(document).ready ->

        console.log "* App ready"

        # AudioManager sounds
        sounds = [
            {
                "id"        : "audio01",
                "src"       : "sounds/between_the_walls.mp3",
                "params"    : {
                    "position"  : new THREE.Vector3(-1300, 50, 0),
                    "radius"    : 2000,
                    "volume"    : 1
                }
                
            },
            {
                "id"        : "audio02",
                "src"       : "sounds/center_of_the_world.mp3",
                "params"    : {
                    "position"  : new THREE.Vector3(800, 50, 1300),
                    "radius"    : 1900,
                    "volume"    : 1
                }
            },
            {
                "id"        : "audio03",
                "src"       : "sounds/flying_monkeys.mp3",
                "params"    : {
                    "position"  : new THREE.Vector3(1400, 50, -1200),
                    "radius"    : 1900,
                    "volume"    : 1
                }
            },
            {
                "id"        : "audio04",
                "src"       : "sounds/rebirth.mp3",
                "params"    : {
                    "position"  : new THREE.Vector3(3500, 50, 300),
                    "radius"    : 1200,
                    "volume"    : 1
                }
                
            },
        ]

        # AudioManager load events
        allAudioLoaded = ( sounds ) =>
            
            console.log "* All audio loaded."
            App.audioManager.off AudioManagerEvents.LOAD_COMPLETE, allAudioLoaded
            App.audioManager.off AudioManagerEvents.LOAD_PROGRESS, allAudioProgress

            $(".loading").fadeOut("fast");
            App.scene3D.addSounds()

        allAudioProgress = ( event ) =>

            w = (event.loaded * 300)
            $(".loading .loadbar .progressbar").css {"width": "#{w}px"}

        # Init app
        if !Detector.webgl
                Detector.addGetWebGLMessage()
            else

                # AudioManager instance
                App.audioManager = AudioManager.instance()
                App.audioManager.on AudioManagerEvents.LOAD_COMPLETE, allAudioLoaded
                App.audioManager.on AudioManagerEvents.LOAD_PROGRESS, allAudioProgress
                App.audioManager.load sounds

                App.scene3D = new Scene3D
             