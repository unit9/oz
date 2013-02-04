class Mic extends Backbone.View

    tagName : "audio"
    ctx     : null
    source  : null
    biquad  : null

    render : =>

        navigator.getUserMedia audio: true, @onStreamSuccess, @onStreamFail


    onStreamSuccess : (stream) =>

        @ctx = new webkitAudioContext

        # create source
        @source = @ctx.createMediaStreamSource( stream )

        # Create the filter
        @biquad = @ctx.createBiquadFilter()

        # Create the audio graph.
        @source.connect @biquad
        @biquad.connect @ctx.destination

        @


    tweakEffect : (effects) =>

        for i in [0..effects.length - 1]
            item = effects[i]

            console.log item
            
            switch item.id
                when "Type"
                    console.log "type", item.enabled, item.value
                    @biquad.type = if item.enabled then item.value else 1

                when "Frequency"
                    minValue = 40
                    maxValue = @ctx.sampleRate/2
                    numberOfOctaves=Math.log(maxValue/minValue)/Math.LN2
                    multiplier=Math.pow(2,numberOfOctaves*(item.value-1.0))
                    @biquad.frequency.value = if item.enabled then maxValue*multiplier else 0

                when "Q"
                    @biquad.Q.value = if item.enabled then item.value * 100 else 0

                when "Gain"
                    @biquad.gain.value = if item.enabled then item.value * 100 else 0


        @

    onStreamFail : =>

        @

