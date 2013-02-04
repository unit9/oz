class Mic

    

    constructor: ->

        console.log "* Mic"

        frequencies =
            'A0': 27.5, 'A1': 55, 'A2': 110, 'A3': 220, 'A4': 440, 'A5': 880, 'A6': 1760, 'A7': 3520.00
            'A#0': 29.1352, 'A#1': 58.2705, 'A#2': 116.541, 'A#3': 233.082, 'A#4': 466.164, 'A#5': 932.328, 'A#6': 1864.66, 'A#7': 3729.31
            'B0': 30.8677, 'B1': 61.7354, 'B2': 123.471, 'B3': 246.942, 'B4': 493.883, 'B5': 987.767, 'B6': 1975.53, 'B7': 3951.07
            'C1': 32.7032, 'C2': 65.4064, 'C3': 130.813, 'C4': 261.626, 'C5': 523.251, 'C6': 1046.50, 'C7': 2093, 'C8': 4186.01
            'C#1': 34.6478, 'C#2': 69.2957, 'C#3': 138.591, 'C#4': 277.183, 'C#5': 554.365, 'C#6': 1108.73, 'C#7': 2217.46
            'D1': 36.7081, 'D2': 73.4162, 'D3': 146.832, 'D4': 293.665, 'D5': 587.330, 'D6': 1174.66, 'D7': 2349.32
            'D#1': 38.8909, 'D#2': 77.7817, 'D#3': 155.563, 'D#4': 311.127, 'D#5': 622.254, 'D#6': 1244.51, 'D#7': 2489.02
            'E1': 41.2034, 'E2': 82.4069, 'E3': 164.814, 'E4': 329.628, 'E5': 659.255, 'E6': 1318.51, 'E7': 2637.02
            'F1': 43.6563, 'F2': 87.3071, 'F3': 174.614, 'F4': 349.228, 'F5': 698.456, 'F6': 1396.91, 'F7': 2793.83
            'F#1': 46.2493, 'F#2': 92.4986, 'F#3': 184.997, 'F#4': 369.994, 'F#5': 739.989, 'F#6': 1479.98, 'F#7': 2959.96
            'G1': 48.9994, 'G2': 97.9989, 'G3': 195.998, 'G4': 391.995, 'G5': 783.991, 'G6': 1567.98, 'G7': 3135.96
            'G#1': 51.9131, 'G#': 103.826, 'G#3': 207.652, 'G#4': 415.305, 'G#5': 830.609, 'G#6': 1661.22, 'G#7': 3322.44

        window.AudioContext = (->
            window.AudioContext or
            window.mozAudioContext or
            window.webkitAudioContext or
            window.msAudioContext or
            window.oAudioContext)()

        if not window.AudioContext
            alert 'THIS TUNER REQUIRES THE LATEST BUILD OF CHROME CANARY (23/09/2012) ON MAC WITH "Web Audio Input" ENABLED IN chrome://flags.'

        navigator.getUserMedia = (->
            navigator.getUserMedia or
            navigator.mozGetUserMedia or
            navigator.webkitGetUserMedia or
            navigator.msGetUserMedia or
            navigator.oGetUserMedia)()

        if not navigator.getUserMedia
            alert 'THIS TUNER REQUIRES THE LATEST BUILD OF CHROME CANARY (23/09/2012) ON MAC WITH "Web Audio Input" ENABLED IN chrome://flags.'


        canvas = $('.tuner canvas')[0]
        $(window).resize ->
            canvas.height = $('.tuner').height()
            canvas.width = $('.tuner').width()
        $(window).trigger 'resize'

        context = canvas.getContext '2d'
        audioContext = new AudioContext()

        sampleRate = audioContext.sampleRate
        fftSize = 8192
        fft = new FFT(fftSize, sampleRate / 4)

        buffer = (0 for i in [0...fftSize])
        bufferFillSize = 2048
        bufferFiller = audioContext.createJavaScriptNode bufferFillSize, 1, 1
        bufferFiller.onaudioprocess = (e) ->
            input = e.inputBuffer.getChannelData 0
            for b in [bufferFillSize...buffer.length]
                buffer[b - bufferFillSize] = buffer[b]

            for b in [0...input.length]
                buffer[buffer.length - bufferFillSize + b] = input[b]

        gauss = new WindowFunction(DSP.GAUSS)

        lp = audioContext.createBiquadFilter()
        lp.type = lp.LOWPASS
        lp.frequency = 8000
        lp.Q = 0.1

        hp = audioContext.createBiquadFilter()
        hp.type = hp.HIGHPASS
        hp.frequency = 20
        hp.Q = 0.1


        success = (stream) ->

            maxTime = 0
            noiseCount = 0
            noiseThreshold = -Infinity
            maxPeaks = 0
            maxPeakCount = 0
    
            try

                src = audioContext.createMediaStreamSource stream
                src.connect lp
                lp.connect hp
                hp.connect bufferFiller
                bufferFiller.connect audioContext.destination

                process = ->

                    bufferCopy = (b for b in buffer)

                    gauss.process bufferCopy

                    downsampled = []

                    for s in [0...bufferCopy.length] by 4
                        downsampled.push bufferCopy[s]

                    upsampled = []


                    for s in downsampled
                        upsampled.push s
                        upsampled.push 0
                        upsampled.push 0
                        upsampled.push 0

                    fft.forward upsampled

                    if noiseCount < 10

                        noiseThreshold = _.reduce(fft.spectrum, 
                            ((max, next) ->
                                if next > max then next else max)
                            , noiseThreshold)
                        noiseThrehold = if noiseThreshold > 0.001 then 0.001 else noiseThreshold
                        noiseCount++

                    spectrumPoints = (x: x, y: fft.spectrum[x] for x in [0...(fft.spectrum.length / 4)])
                    spectrumPoints.sort (a, b) -> (b.y - a.y)

                    peaks = []
                    for p in [0...8]
                        if spectrumPoints[p].y > noiseThreshold * 5
                            peaks.push spectrumPoints[p]


                    if peaks.length > 0
                        for p in [0...peaks.length]
                            if peaks[p]?
                                for q in [0...peaks.length]
                                    if p isnt q and peaks[q]?
                                        if Math.abs(peaks[p].x - peaks[q].x) < 5
                                            peaks[q] = null
                        peaks = (p for p in peaks when p?)
                        peaks.sort (a, b) -> (a.x - b.x)

                        maxPeaks = if maxPeaks < peaks.length then peaks.length else maxPeaks
                        if maxPeaks > 0 then maxPeakCount = 0

                        peak = null

                        firstFreq = peaks[0].x * (sampleRate / fftSize)
                        if peaks.length > 1
                            secondFreq = peaks[1].x * (sampleRate / fftSize)
                            if 1.4 < (firstFreq / secondFreq) < 1.6
                                peak = peaks[1]
                            if peaks.length > 2
                                thirdFreq = peaks[2].x * (sampleRate / fftSize)
                                if 1.4 < (firstFreq / thirdFreq) < 1.6
                                    peak = peaks[2]

                            if peaks.length > 1 or maxPeaks is 1
                                if not peak?
                                    peak = peaks[0]

                                left = x: peak.x - 1, y: Math.log(fft.spectrum[peak.x - 1])
                                peak = x: peak.x, y: Math.log(fft.spectrum[peak.x])
                                right = x: peak.x + 1, y: Math.log(fft.spectrum[peak.x + 1])

                                interp = (0.5 * ((left.y - right.y) / (left.y - (2 * peak.y) + right.y)) + peak.x)
                                freq = interp * (sampleRate / fftSize)

                                [note, diff] = getPitch freq
                                display.draw note, diff
                    else
                        maxPeaks = 0
                        maxPeakCount++
                        if maxPeakCount > 20
                            display.clear()

                    render()

            catch e
                error e



            getPitch = (freq) ->

                minDiff = Infinity
                diff = Infinity
                
                for own key, val of frequencies
                    if Math.abs(freq - val) < minDiff
                        minDiff = Math.abs(freq - val)
                        diff = freq - val
                        note = key

                [note, diff]

            display =

                draw: (note, diff) ->

                    displayDiv = $('.tuner div')
                    displayDiv.removeClass()
                    displayDiv.addClass (if Math.abs(diff) < 0.25 then 'inTune' else 'outTune')
                    displayStr = ''
                    displayStr += if diff < -0.25 then '>&nbsp;' else '&nbsp;&nbsp;'
                    displayStr += note.replace(/[0-9]*/g, '')
                    displayStr += if diff > 0.25 then '&nbsp;<' else '&nbsp;&nbsp;'
                    displayDiv.html displayStr

                clear: ->
                    displayDiv = $('.tuner div')
                    displayDiv.removeClass()
                    displayDiv.html ''

            render = ->

                context.clearRect 0, 0, canvas.width, canvas.height
                newMaxTime = _.reduce buffer, ((max, next) -> if Math.abs(next) > max then Math.abs(next) else max), -Infinity
                maxTime = if newMaxTime > maxTime then newMaxTime else maxTime
                context.fillStyle = '#EEE'
                timeWidth = (canvas.width - 100) / (buffer.length)
                for s in [0...buffer.length]
                    context.fillRect timeWidth * s, canvas.height / 2, timeWidth, -(canvas.height / 2) * (buffer[s] / maxTime)
                context.fillStyle = '#F77'
                freqWidth = (canvas.width - 100) / (fft.spectrum.length / 4)
                for f in [10...(fft.spectrum.length / 4) - 10]
                    context.fillRect freqWidth * f, canvas.height / 2, freqWidth, -Math.pow(1e4 * fft.spectrum[f], 2)

            setInterval process, 100

        error = (e) ->
            console.log e
            console.log 'ARE YOU USING CHROME CANARY (23/09/2012) ON A MAC WITH "Web Audio Input" ENABLED IN chrome://flags?'


        navigator.getUserMedia audio: true, success, error








