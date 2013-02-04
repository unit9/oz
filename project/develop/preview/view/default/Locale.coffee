class Locale

    lang : null
    data : null

    constructor : () ->
        _.extend @, Backbone.Events
        
    init : () =>
        @lang = (navigator.language || navigator.userLanguage).toLowerCase()

        $.ajax 
            url      : "/api/localisation/desktop/" + @lang
            dataType : "json"
            success  : @onSuccess
            error    : @loadBackup
            

    onSuccess : (event) =>
        d = null

        if event.responseText
            d = JSON.parse event.responseText
        else 
            d = event

        @data = d
        @trigger 'complete'


    loadBackup : =>
        $.ajax 
            url      : '/locale/en/strings.txt'
            dataType : 'text'
            complete : @onSuccess
            error    : => console.log 'error on loading backup'


    get : (id) =>
        return @data.strings[id] || ""