class AppView extends Abstract

    tagName : 'div'
    mapmenu : null

    initialize: =>

        @setElement $('.container')

        @$el.css
            'background' : 'url("img/home-background.jpg") no-repeat center center fixed'
            'background-size' : 'cover'


        @mapmenu = new MapMenu
        @$el.append @mapmenu.$el
