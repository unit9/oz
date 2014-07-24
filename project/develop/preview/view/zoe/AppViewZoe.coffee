class AppViewZoe extends Backbone.View

	initialize : =>

		@setElement $('body')

		@header = new Header
		@$el.append @header.$el

		@thumb = new ThumbZoe 

		@wrapper = $('<div class="wrapper"/>')

		@$el.append @wrapper

		@containerThumb = @wrapper.append ('<div class="thumbContainer"><div class="thumbCell" style="margin-top: 25px;" /></div>')
		@container = @$el.append ('<div class="buttonContainer"><div class="buttonCell" /></div>')

		@button = new Button @oz().locale.get('zoetropeSharePageButton'), '/zoetrope'
		@footer = new Footer

		@container.find('.buttonCell').append @button.$el
		@containerThumb.find('.thumbCell').append @thumb.$el

		@$el.append @footer.$el		

		@thumb.init( @getImageId() )
		
		
	getImageId: () ->
		window.location.href.substr(window.location.href.lastIndexOf('/') + 1, window.location.href.length)

	oz: =>

		return (window || document).oz
