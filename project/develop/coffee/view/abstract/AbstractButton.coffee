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

        # Fix alignment button (Chrome Win / Chrome OSx)
        if navigator.appVersion.indexOf("Win") != -1
            @$el.css
                "padding" : "7px 20px 8px 20px"


        if @label?
            @$el.append @label

        @init()

        null

    init : =>
        null

    enable: =>

        @$el.css {
            "cursor" : "pointer"
            "pointer-events" : "auto"
        }
        @$el.removeClass "disabled"
        @$el.mouseover @onover
        @$el.mouseout @onout

        @$el.bind "click", @onclick

        null

    disable: =>

        @$el.css {
            "cursor" : "default"
            "pointer-events" : "none"
        }
        @$el.addClass "disabled"
        @$el.unbind "mouseover"
        @$el.unbind "mouseout"
        @$el.unbind "click"
        null

    onover: =>
        @$el.addClass "over"
        null

    onout: =>
        @$el.removeClass "over"
        null

    onclick: =>
        null

    changeLabel: ( label ) =>
        @$el.html label
        null

    dispose : =>
        n = $(@$el.children()[0]).attr('id') || $(@$el.children()[0]).attr('class') || @$el.html()
        null

    resume : =>
        null
        
    pause : =>
        null

    hide : (anim = false, callback = null) =>
        @visible = false

        if !anim
            @$el.css {opacity : 0}
        else 
            @$el.animate {opacity: 0}, 400, 'linear', callback

        null


    show : (anim = false, callback = null) =>
        @visible = true
        if !anim
            @$el.css {opacity : 1}
        else 
            @$el.animate {opacity: 1}, 400, 'linear', callback

        null
    
    oz : =>
        return (window || document).oz

    
