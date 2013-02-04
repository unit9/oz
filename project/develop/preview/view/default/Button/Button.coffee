class Button extends Backbone.View

	className: 'extra-page-button'
	tagName: 'a'

	initialize: (copy, link) =>
		@$el.text copy
		@$el.attr {
			'href': link,
			'target': '_blank'
		}



###
class Button extends Backbone.View

    className: 'extra-page-button'
    tagName: 'a'

    initialize: =>
        @$el.text 'Create your own'
        @$el.attr {
            'href': '/m/cutout',
            'target': '_blank'
        }

    setPosition: ->
        marginLeft = -Math.floor @$el.innerWidth() / 2
        @$el.css "margin-left", "#{marginLeft}px"

###