class StringRow extends Backbone.View

    tagName    : 'div'
    id         : null
    string     : null
    
    fieldId         : null
    fieldString     : null
    fieldTranslated : null

    constructor : (id, string) ->

        @id = id
        @string = string

        @fieldId = $('<label>' + @id + "</label>")
        @fieldString = $('<input class="originalString" type="text" disabled placeholder="'+@string+'">')
        @fieldTranslated = $('<input class="translatedString" type="text" value="'+@string+'">')

        super()

    initialize : ->

        @$el.append @fieldId
        @$el.append @fieldString
        @$el.append @fieldTranslated


    node : =>
        [@id,@fieldTranslated.val()]