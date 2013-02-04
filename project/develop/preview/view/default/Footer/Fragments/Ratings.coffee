class Ratings extends Backbone.View

    tagName : 'div'
    className : 'ratings'

    initialize : =>

        @pg = new SSAsset 'rating_block'



        @$copyright = $('<a/>') 
        @$copyright.text( @oz().locale.get 'menuRatings' )
        @$copyright.attr
            'href' : @oz().locale.get 'menuRatingsLink'

        @$el.append @pg.$el
        @$el.append @$copyright

    oz : =>
        return (window || document).oz