class PianoKey extends Backbone.View

    tagName : 'div'
    note    : null
    octave  : null

    initialize : ( type, note, octave) =>

        @note = @getNote note.toString().charAt(0)
        @note += 5 if note.length > 1
        @octave = octave + 1

        @note *= @octave

        @$el.addClass type
        @$el.mousedown @onMouseDown
        @$el.mouseup @onMouseUp
        @

    left : (x) =>
        @$el.css
            'margin-left' : x

    onMouseDown : (event) =>
        tune = audioLib.generators.Tune window.sink.sampleRate, @note, 1
        window.tunes.push tune


    onMouseUp : (event) =>
    # window.audio.stop()


    getNote : (n) =>

        switch n
            when 'c'
                return 100

            when 'd'
                return 150

            when 'e'
                return 200

            when 'f'
                return 250

            when 'g'
                return 300

            when 'a'
                return 350

            when 'b'
                return 400