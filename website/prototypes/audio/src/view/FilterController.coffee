class FilterController extends Backbone.View

    tagName : 'div'

    input : null
    name  : null
    max   : null
    min   : null
    step  : null

    check : null

    initialize : (params) =>
        @name = params.name
        @max  = params.max
        @min  = params.min
        @step = params.step


    render: =>

        @$el.css
            'margin' : '25px'

        @$el.append '<label>'+@name+'<input style="margin-left:5px;margin-right:15px;float:left;" type="checkbox" checked="true" /></label>'
        @$el.append '<input id="filter_' + @name + '" type="range" min="'+@min+'" max="'+@max+'" step="'+@step+'"/>'

        @check = @$el.find('label').find('input')
        @check.bind 'change', @changeFilter
        
        @input = @$el.find('#filter_' + @name)
        @input.bind 'change', @changeFilter

    val : =>
        return @input.val()

    enabled : =>
        return Boolean(@check.attr('checked'))

    changeFilter : (event) =>
        @trigger "change"
