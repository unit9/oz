class Ratings extends Abstract

    className : 'ratings'
    mpaa      : null

    init : =>
        @mpaa = new SSAsset 'interface', 'rating_block'
        @addChild @mpaa
        @mpaa.center()

        link = $("<span>#{@oz().locale.get('menuRatings')}</span>")
        link.addClass 'button_alpha_enabled'

        @$el.append link

        @$el.bind 'click', =>
            Analytics.track 'menu_click_mpaa'
            window.open @oz().locale.get 'menuRatingsLink'

    dispose : =>
        return