class ErrorMessage extends Abstract

    tagName : 'div'

    initialize: =>
        @setElement $('body')

        @header = new Header
        @$el.append @header.$el

        container = $('<div class="errorContainer"/>')
        cont = $('<div/>')
        container.append cont

        warning = new SSAsset 'instructions_warning'
        warning.$el.addClass 'ssAsset'
        cont.append warning.$el

        # share_page_moderated_copy
        # share_page_expired_copy

        copy = $('<p/>')
        copy.html(@oz().locale.get('share_page_expired_copy'))
        cont.append copy

        bottom = new SSAsset 'breaker_down'
        bottom.$el.addClass 'ssAsset'
        cont.append bottom.$el

        @$el.append container

        @footer = new Footer
        @$el.append @footer.$el

    onEnterFrame: =>
        @

