class Tune

    sampleRate   : 44100
    frequency    : 440
    sample       : 0
    length       : 12
    samplesLeft  : null
    mix          : 0.5
    pan          : 0.5

    constructor : (sampleRate, frequency, pan, length) ->

        @sampleRate     = if isNaN(sampleRate) || sampleRate == null then @sampleRate else sampleRate
        @frequency      = if isNaN(frequency) || frequency == null then @frequency else frequency
        @pan            = if isNaN(pan) || pan == null then @pan else pan
        @length         = if isNaN(length) || length == null then @length else length

        @samplesLeft    = @length * @sampleRate
        @osc            = audioLib.Oscillator(@sampleRate, @frequency * 2)
        @lfo            = audioLib.Oscillator(@sampleRate, @frequency * 2.8)
        @envelope       = audioLib.ADSREnvelope(@sampleRate, 10, 100, 0.2, 2000, 10, @length * 1000)

        @lfo.waveShape  = 'sine'

        @envelope.triggerGate()


    generate : =>
        @lfo.generate()
        @osc.fm = @lfo.getMix()
        @osc.generate()
        @envelope.generate()

        @sample = @osc.getMix() * @envelope.getMix()

        if !--@samplesLeft
            @generate = @_generate

    _generate : =>

    getMix : (ch) =>
        # (if ch % 2 then @pan else 1 - @pan)
        @sample * @pan
        