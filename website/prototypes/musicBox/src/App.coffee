$ -> 

    if window.webkitAudioContext || window.AudioContext
        window.audioContext = new webkitAudioContext() || AudioContext()
    else
        alert('Your browser does not support Web Audio API')
        return
   
    audioLib.generators 'Tune', Tune

    window.tunes = []
    window.sink  = Sink()
    window.sine  = (n) =>
        (1 - Math.sin(n)) * 0.5

    reverb = audioLib.Reverb sink.sampleRate, sink.channelCount, 0.0, 0, 0

    scale  = new Float32Array [
        130.82, # C2
        155.57, # D#2
        185.00, # F#2
        220.00, # A2
        261.63, # C3
        311.13,
        369.99,
        440.00,
        523.26,
        622.25,
        739.99,
        880.00
    ]

    i = 0
    
    app = new AppView

    window.sink.on 'audioprocess', (buffer, channelCount) =>

        for tune in window.tunes
            tune.append(buffer, channelCount)
    
        # reverb.append(buffer, channelCount)


    ###createVoice = =>
        # a = scale[~~(scale.length * sine(i * 1.75 * Math.sin(i * 0.2)))]
        a = Math.random() * 1000
        b = sine(i * 2.23)

        voice = audioLib.generators.Tune sink.sampleRate, a, b
        voices.push(voice)

        setTimeout(createVoice, 1000 + sine(i++) * 2000)

    createVoice()###