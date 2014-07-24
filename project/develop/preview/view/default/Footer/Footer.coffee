class Footer extends Backbone.View

    tagName : 'footer'
    
    initialize: =>

        @footerLogos = new FooterLogos
        @footerShare = new FooterShare
        @ratings = new Ratings

        @$el.append @footerLogos.$el
        @$el.append @footerShare.$el
        @$el.append @ratings.$el



        setTimeout @renderShare, 1000

        $(window).bind 'resize', @onWindowResize

    renderShare : =>
        twttr.widgets.load()
                    
        gapi.plusone.render 'g-plusone',
            size     : "medium"
            expandTo : 'top'


    onWindowResize: (e) =>
        @$el.css 'width', $('body').width()
