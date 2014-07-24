class PianoBlock extends Backbone.View

    className  : 'pianoBlock'

    initialize : (notes, octave) =>

        for i in [0..notes.length - 1]
            note = new PianoKey 'pianoKey', notes[i], octave
            @$el.append note.$el
            note.left 41 * i

        for i in [0..notes.length - 2]
            note = new PianoKey 'pianoBlackKey', notes[i] + "S", octave
            @$el.append note.$el
            note.left 26 + 43 * i

        @$el.css
            width : (notes.length) * 40 + (notes.length)

    left : (x) =>
        @$el.css
            'margin-left' : x