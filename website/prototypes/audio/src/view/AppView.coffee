class AppView extends Backbone.View

    tagName      : 'body'
    mic          : null
    filters      : null
    filtersComps : null

    initialize: =>

        @filters = [
            {
                name : 'Type',
                max  : 10,
                min  : 0,
                step : 1   
            }, 

            {
                name : 'Frequency',
                max  : 1,
                min  : 0,
                step : 0.01
            },

            {
                name : 'Q',
                max  : 1,
                min  : 0,
                step : 0.01
            },

            {
                name : 'Gain',
                max  : 1,
                min  : 0,
                step : 0.01
            }
        ]

        @filtersComps = []

        for i in [0..@filters.length - 1]
            filter = new FilterController @filters[i]
            filter.on 'change', @changeMicEffect
            @filtersComps.push filter

        @mic = new Mic
        
        @render()


    changeMicEffect : (event) =>

        effects = []

        for i in [0..@filtersComps.length - 1]
            effects.push 
                id      : @filtersComps[i].name
                value   : @filtersComps[i].val()
                enabled : @filtersComps[i].enabled()

        @mic.tweakEffect effects


    render : =>
        @mic.render()

        $('body').append @mic.$el

        for i in [0..@filtersComps.length - 1]
            $('body').append @filtersComps[i].$el
            @filtersComps[i].render()
