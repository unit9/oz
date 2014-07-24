class Header extends Backbone.View

	className: 'header'
	tagName : 'span'

	initialize: () ->

		@img_flourish = new SSAsset 'breaker_up'

		@$cellContainer = $('<div/>')
		@$cellContainer.attr 'class', 'innerFooterCenter'

		@$sentence = $('<span/>') 
		@$sentence.text @oz().locale.get 'homeTitle'

		@img_flourish2 = new SSAsset 'breaker_down'

		@$cellContainer.append @img_flourish.$el
		@$cellContainer.append @$sentence
		@$cellContainer.append @img_flourish2.$el
		@$el.append @$cellContainer

	oz : =>
		return (window || document).oz