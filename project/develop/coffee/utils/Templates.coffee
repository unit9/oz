class Templates

    templates : null

    constructor : (templates) ->

        _.extend @, Backbone.Events

        @parseXML templates
        
        null

    parseXML : (data) =>

        temp = []

        $(data).find('template').each (key, value) ->
            temp.push new TemplateModel
                id   : $(value).attr('id').toString()
                text : $.trim $(value).text()

        @templates = new CollectionTemplates temp
        null
        

    get : (id) =>

        t = @templates.where 
            id : id
        t = t[0].get 'text'

        return $.trim t
