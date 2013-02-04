class Copyright extends Abstract

    className : 'copyright'

    init: =>
        @$el.empty()
        @$el.append "<a class='button_alpha_enabled' href='http://disney.com' target='_blank'>" + @oz().locale.get('copyright') + "</a>"
        null