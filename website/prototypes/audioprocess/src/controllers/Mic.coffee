class Mic

    audioContext    : new webkitAudioContext
    javascriptNode  : null
    audioInput      : null
    outputMix       : null
    dryGain         : null
    wetGain         : null
    effectInput     : null
    loopID          : null
    analyser        : null
    currentEffect   : null

    # Canvas
    canvas          : document.getElementById "canvas"
    ctx             : canvas.getContext "2d"

    # Effects

    # Delay
    dtime           : null
    dregen          : null
    delayTime       : 0.15

    # Octave Doubler
    doubler         : null
    doublerDelay    : 0.100

    # Distortion
    waveshaper      : null
    distortionDrive : 5.0

    # Flange
    flangeDelay     : 0.005
    flangeDepth     : 0.002
    flangeFeedback  : 0.5
    flangeSpeed     : 0.25
    fldelay         : null
    fldepth         : null
    flfb            : null
    flspeed         : null


    constructor: ->

        console.log "* Mic"

        @audio = $('#media_device')[0]

        @setupAudio()

# -----------------------------------------------------
# Initiate / Stop the microphone
# -----------------------------------------------------

    setupAudio: =>

        @javascriptNode = @audioContext.createJavaScriptNode 2048, 1, 1
        @javascriptNode.connect @audioContext.destination

        @analyser = @audioContext.createAnalyser()
        @analyser.smoothingTimeConstant = 0.3
        @analyser.fftSize = 1024

        @getUserMedia()

    getUserMedia: =>

        navigator.getUserMedia { audio:true }, @onUserMediaSuccess, @onUserMediaError

    stop: =>

        console.log "Stop mic"

        # @audio.pause()
        # @audio.src = ""

# -----------------------------------------------------
# Callback from the audio streaming
# -----------------------------------------------------

    onUserMediaSuccess: (stream) =>

        input = @audioContext.createMediaStreamSource stream
        
        @audioInput = @convertToMono input

        # @audioInput.connect @audioContext.destination

        @outputMix = @audioContext.createGainNode()

        @dryGain = @audioContext.createGainNode()

        @wetGain = @audioContext.createGainNode()

        @effectInput = @audioContext.createGainNode()

        @audioInput.connect @dryGain
        
        # @audioInput.connect @analyser1

        @dryGain.connect @outputMix

        @wetGain.connect @outputMix

        @outputMix.connect @audioContext.destination

        @outputMix.connect @analyser

        @changeEffect 1

        @javascriptNode.onaudioprocess = @onaudioprocess

        @updateAnalysers()


    onUserMediaError: (error) =>

        console.error "Failed to get access to local media. Error code was " + error.code

    onMetaDataLoaded: (e) =>

        event = document.createEvent "Event"
        event.initEvent "micLoaded", true, true
        window.dispatchEvent event

# -----------------------------------------------------
# Audio Manipulation
# -----------------------------------------------------
    
    changeEffect: ( effect ) =>

        # Delay
        @dtime      = null
        @dregend    = null

        # Flange
        @fldelay    = null
        @fldepth    = null
        @flfb       = null
        @flspeed    = null

        # Current effect
        @currentEffect = effect

        if @currentEffectNode
            @currentEffectNode.disconnect()

        if @effectInput
            @effectInput.disconnect()

        switch effect

            when 0

                @currentEffectNode = @createDelay()

            when 1

                @currentEffectNode = @createDoubler()

            when 2

                @currentEffectNode = @createDistortion()

            when 3

                @currentEffectNode = @createFlange()

        @audioInput.connect @currentEffectNode

    convertToMono: ( input ) =>

        splitter = @audioContext.createChannelSplitter 2
        merger = @audioContext.createChannelMerger 2

        input.connect( splitter );
        splitter.connect merger, 0, 0
        splitter.connect merger, 0, 1
        
        merger

    onaudioprocess: =>

        # get the average, bincount is fftsize / 2
        array = new Uint8Array @analyser.frequencyBinCount
        @analyser.getByteFrequencyData array
        average = @getAverageVolume array

        # clear the current state
        @ctx.clearRect 0, 0, canvas.width, canvas.height
 
        # set the fill style
        @ctx.fillStyle = "#34ca85"
 
        # create the meters
        @ctx.fillRect 0, 0, canvas.width, average * 2


    getAverageVolume: ( array ) =>

        values = 0
        average = null
 
        length = array.length
 
        # get all the frequency amplitudes
        for i in [0..length - 1]
            values = values + array[i]

        average = values / length
        
        average

# -----------------------------------------------------
# Effects
# -----------------------------------------------------

    createDelay: =>

        delayNode = @audioContext.createDelayNode()
        delayNode.delayTime.value = @delayTime

        @dtime = delayNode

        gainNode = @audioContext.createGainNode()
        gainNode.gain.value = 0.55
        
        @dregen = gainNode

        gainNode.connect delayNode
        delayNode.connect gainNode
        delayNode.connect @wetGain

        delayNode

    createDoubler: =>

        effect = new Jungle @audioContext
        effect.output.connect @wetGain

        @doubler = effect
        
        effect.input

    createDistortion: =>

        if !@waveshaper
            @waveshaper = new WaveShaper @audioContext

        @waveshaper.output.connect @wetGain
        @waveshaper.setDrive @distortionDrive

        @waveshaper.input

    createFlange: =>

        delayNode = @audioContext.createDelayNode()
        delayNode.delayTime.value = parseFloat( @flangeDelay )   # document.getElementById("fldelay").value
        @fldelay = delayNode

        inputNode = @audioContext.createGainNode()      

        gain = @audioContext.createGainNode()
        gain.gain.value = parseFloat( @flangeDepth ) # document.getElementById("fldepth").value
        @fldepth = gain

        feedback = @audioContext.createGainNode()
        feedback.gain.value = parseFloat( @flangeFeedback ) # document.getElementById("flfb").value
        @flfb = feedback

        osc = @audioContext.createOscillator()
        osc.type = osc.SINE
        osc.frequency.value = parseFloat( @flangeSpeed ) # document.getElementById("flspeed").value
        @flspeed = osc

        osc.connect gain
        gain.connect(delayNode.delayTime);

        inputNode.connect @wetGain
        inputNode.connect delayNode
        delayNode.connect @wetGain
        delayNode.connect feedback
        feedback.connect inputNode

        osc.noteOn 0

        inputNode

# -----------------------------------------------------
# Request animation Frame
# -----------------------------------------------------

    updateAnalysers: ( time ) =>

        # Update settings based on Dat-gui
    
        # Delay effect
        if @currentEffect == 0
            @dtime.delayTime.value = @delayTime

        # Doubler effect
        if @currentEffect == 1
            @doubler.setDelay @doublerDelay

        # Distortion effect
        if @currentEffect == 2
            @waveshaper.setDrive @distortionDrive

        # Flange effect
        if @currentEffect == 3
            @fldelay.delayTime.value    = @flangeDelay
            @fldepth.gain.value         = @flangeDepth
            @flspeed.frequency.value    = @flangeSpeed
            @flfb.gain.value            = @flangeFeedback


        # Loop based on RAF
        @loopID = window.webkitRequestAnimationFrame @updateAnalysers

    cancelAnalyserUpdates: =>

        window.webkitCancelAnimationFrame @rafID
        @loopID = null
