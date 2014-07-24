class AbstractButton extends Backbone.View

    el          : null
    id          : null
    label       : null
    template    : null
    templateVars: null
    tagName     : "button"
    className   : "abstractbutton"
    classButton : null
    classAnimated : null

    initialize: ->

        if @template
            tmpHTML = _.template @oz().templates.get @template
            @setElement tmpHTML @templateVars

        @$el.attr 'id', @id if @id
        @$el.addClass @className if @className
        @$el.addClass @classAnimated if @classAnimated

        if @label?
            @$el.append @label

        @init()

    init : =>

        @

    enable: =>

        @$el.css {"cursor" : "pointer"}
        @$el.removeClass "disabled"
        @$el.mouseover @onover
        @$el.mouseout @onout

        @$el.bind "click", @onclick

    disable: =>

        @$el.css {"cursor" : "default"}
        @$el.addClass "disabled"
        @$el.unbind "mouseover"
        @$el.unbind "mouseout"
        @$el.unbind "click"

    onover: =>

        @$el.addClass "over"

    onout: =>

        @$el.removeClass "over"

    onclick: =>

        @

    changeLabel: ( label ) =>

        @$el.html label

    dispose : =>
        n = $(@$el.children()[0]).attr('id') || $(@$el.children()[0]).attr('class') || @$el.html()
        @

    resume : =>

        @
        
    pause : =>

        @

    hide : (anim = false, callback = null) =>
        @visible = false

        if !anim
            @$el.css {opacity : 0}
        else 
            @$el.animate {opacity: 0}, 400, 'linear', callback


    show : (anim = false, callback = null) =>
        @visible = true
        if !anim
            @$el.css {opacity : 1}
        else 
            @$el.animate {opacity: 1}, 400, 'linear', callback
    
    oz : =>
        return (window || document).oz

    
