class View extends Backbone.View

    data         : null
    buttonCreate : null
    rows         : null
    translated   : null
    localesList  : null
    locales      : null

    initialize : =>
        @setElement $('.container')

    parse : (str) =>
        @data = JSON.parse str

        @localesList = ['en', 'fr', 'it', 'es', 'nl']
        @locales = []

        for i in @localesList
            @locales.push "<option>" + i + "</option>"

        @locales = "<select class='localeSelect'>" + @locales.toString().split(",").join("") + "</select>"

        title = $('<span class="form-inline" />')
        title.append '<legend>Select locale</legend>'
        title.find('legend').append @locales

        @$el.append title
        
        @$el.append '<legend>List of Strings</legend>'

        @rows = []

        for k, v of @data.strings
            row = new StringRow k, v
            @rows.push row
            @$el.append row.$el

        @buttonCreate = $('<button class="btn btn-large btn-success" type="button">Create localised copy</button>')
        @buttonCreate.click @createTranslated

        @$el.append '<br>'
        @$el.append @buttonCreate
        @$el.append '<br><br><br><br>'

    createTranslated : =>

        @translated = {}

        @translated.lang = $('.localeSelect').val()
        @translated.strings = {}

        for i in @rows
            node = i.node()
            @translated.strings[node[0]] = node[1]

        uriContent = "data:application/octetstream;charset=utf-8;filename=string.txt;content-disposition=attachment," + encodeURIComponent(JSON.stringify @translated)
        
        newWindow=window.open(uriContent, 'string.txt')
