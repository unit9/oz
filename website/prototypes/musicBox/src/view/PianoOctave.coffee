class PianoOctave extends Backbone.View

    tagName   : 'div'
    className : 'octave'

    initialize : (octave) =>

        @$el.append (new PianoBlock ['c', 'd', 'e']      , octave).$el
        @$el.append (new PianoBlock ['f', 'g', 'a', 'b'] , octave).$el

        @$el.css
            width : 7 * 41