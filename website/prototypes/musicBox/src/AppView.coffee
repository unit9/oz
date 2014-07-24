class AppView extends Backbone.View

    tagName : 'div'
    octaves : null
    piano   : null

    initialize : =>

        @setElement $('.container')

        @piano = $('<div class="piano"/>')
        @$el.append @piano

        @octaves = []

        for i in [0..2]
            octave = new PianoOctave i
            @piano.append octave.$el
            @octaves.push octave
        
