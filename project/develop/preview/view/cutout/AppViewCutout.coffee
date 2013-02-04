class AppViewCutout extends Backbone.View

    initialize : =>

        @setElement $('body')

        console.log "LKASJDLKJSAD"

        @header = new Header
        @$el.append @header.$el

        if window.location.href.indexOf(':8888') > -1
            @thumb = new ThumbCutout '1.jpeg'
        else 
            @thumb = new ThumbCutout @getImageId()

        @container = @$el.append ('<div class="buttonContainer"><div class="buttonCell" /></div>')

        @button = new Button @oz().locale.get('cutoutSharePageButton'), '/cutout'
        @footer = new Footer

        @container.find('.buttonCell').prepend @button.$el
        @$el.append @footer.$el
    
    getImageId: () ->
        window.location.href.substr(window.location.href.lastIndexOf('/') + 1, window.location.href.length)

    oz: =>
        return (window || document).oz
