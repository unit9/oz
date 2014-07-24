class FooterLogos extends Backbone.View

	className: 'footer-logos'

	initialize: () =>
		# @ssLogo = new SSAsset 'logo_oz'
		# @ssChromeLogo = new SSAsset 'logo_chrome'
		# @ssGoogleLogo = new SSAsset 'logo_google'

		@logo_oz_asset = new SSAsset 'logo_oz'

		@logo_oz = $('<a/>')
		@logo_oz.append @logo_oz_asset.$el
		@logo_oz.attr {
			'class': 'logo_oz',
			'href': '/',
			'target': '_blank'
		}

		@logo_chrome_asset = new SSAsset 'logo_chrome'
		
		@logo_chrome = $('<a/>')
		@logo_chrome.append @logo_chrome_asset.$el
		@logo_chrome.attr {
			'class': 'logo_chrome',
			'href': ' http://www.chromeexperiments.com',
			'target': '_blank'
		}

		@logo_google_asset = new SSAsset 'logo_google'

		@logo_google = $('<a/>')
		@logo_google.append @logo_google_asset.$el
		@logo_google.attr {
			'class': 'logo_google',
			'href': 'http://google.com',
			'target': '_blank'
		}

		@$el.append @logo_oz
		@$el.append @logo_chrome
		@$el.append @logo_google
