class StringRow extends Backbone.View

    tagName    : 'div'
    id         : null
    string     : null
    
    fieldId         : null
    fieldString     : null
    fieldTranslated : null

    constructor : (id, string, english, needsTranslation = false) -> 


        @id = id
        @string = string

        # @string = (@string + '').replace(/[\\"']/g, '\\$&').replace(/\u0000/g, '\\0');

        maxChars = ""

        en = if english then english else @string

        if @id.indexOf("seo_") == -1 and @id.indexOf("_url") == -1 and en
            maxChars = "<br><b>max chars:</b> " + (en.length + en.length * .25).toFixed(0)

        @fieldId = $('<label>' + @id + maxChars + "</label>")

        if @string.length > 100

            @fieldString = $('<textarea rows="5" class="originalStringTextarea" type="text" disabled>'+en+'</textarea>')
            @fieldTranslated = $('<textarea rows="5" class="translatedStringTextarea" type="text">'+@string+'</textarea>')
        else 
            @fieldString = $('<input class="originalString" type="text" disabled placeholder="">') # '+en+'
            @fieldString.attr("placeholder", en)
            @fieldTranslated = $('<input class="translatedString" type="text" value="">') # '+@string+'
            @fieldTranslated.attr("value", @string)

        if needsTranslation
            @fieldTranslated.css {'border' : '1px solid red'}


        super()

    initialize : ->

        @$el.append @fieldId
        @$el.append @fieldString
        @$el.append @fieldTranslated
        @fieldTranslated.keyup @onChange

    onChange : (event) =>
        @trigger 'change', event

    node : =>
        [@id,@fieldTranslated.val()]