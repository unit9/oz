class AudioManagerSingleton

    sounds      : {}
    failed      : []
    preloader   : null

    constructor: () ->

        console.log "* AudioManager ready"

        _.extend @, Backbone.Events

        # Loader
        @preloader = new AssetLoader
        @preloader.preload.installPlugin createjs.SoundJS # Install SoundsJS plugin
        @preloader.on PreloaderEvents.COMPLETE, @onFileComplete
        @preloader.on PreloaderEvents.PROGRESS, @onProgress
        @preloader.on PreloaderEvents.FAIL, @onFail

        @

# -----------------------------------------------------
# Audio Manager Methods
# -----------------------------------------------------

    load: ( sounds ) =>

        @preloader.loadFiles sounds

    play: ( id ) =>

        createjs.SoundJS.play id

    pause: ( id ) =>

        createjs.SoundJS.pause id

    resume: ( id ) =>

        createjs.SoundJS.resume id

    stop: ( id ) =>

        createjs.SoundJS.stop id

    volume: ( id, volume ) =>

        createjs.SoundJS.setVolume volume, id

    update: ( camera ) =>

        for id, audio of @sounds

            distance = @sounds[id].data.position.distanceTo camera.position

            if distance <= @sounds[id].data.radius

                @volume id, @sounds[id].data.volume * ( 1 - distance / @sounds[id].data.radius)

            else

                @volume id, 0


# -----------------------------------------------------
# Audio Loader Events
# -----------------------------------------------------

    onProgress: (event) =>

        @trigger AudioManagerEvents.LOAD_PROGRESS, event

    onFail: (event) =>

        @failed.push event.id
        @trigger AudioManagerEvents.LOAD_FAIL, event

    onFileComplete: (event) =>

        if event.target._numItems == event.target._numItemsLoaded
            
            for id, audio of event.target._loadedItemsById
                
                if @failed.indexOf id != 1
                    @sounds[id] = audio

                @failed = []

            @trigger AudioManagerEvents.LOAD_COMPLETE, @sounds

# -----------------------------------------------------
# Singleton by https://coderwall.com/p/wwmq6a
# -----------------------------------------------------

INSTANCE = undefined

AudioManager =
    instance: ->
        if INSTANCE is undefined
            INSTANCE = new AudioManagerSingleton()
        INSTANCE