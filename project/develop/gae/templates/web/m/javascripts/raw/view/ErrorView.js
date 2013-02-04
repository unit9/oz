/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global OzMobileRemoteCopy */
/*global Detection */
/*global Analytics */

Package('view',
[
	Import('mjframe.View'),

	Class('public singleton ErrorView extends View',
	{
		_public_static:
		{
			TYPE_NOCHROME : 'Error_nonChrome',
			TYPE_CONFIGURATION : 'Error_configurationNotSupported'
		},

		_public:
		{
			$copy : null,
			$getChromeButton : null,
			$continueButton : null,
			type : null,

			ErrorView : function()
			{
				this._super();
				this.init('error', 'view.ErrorView', 'ErrorView');
			},

			compile : function()
			{
				this._super();

				this.$copy = $('#error p');
				this.$getChromeButton = $('#errorButtonGetChrome');
				this.$continueButton = $('#errorButtonContinue');
			},

			bindEvents : function()
			{
				this._super();

				this.$getChromeButton.bind('click', Poof.retainContext(this, this.onGetChromeButtonClick));
				this.$continueButton.bind('click', Poof.retainContext(this, this.onContinueButtonClick));
			},

			onReady : function()
			{
				this._super();

				this.$el.css('display', '');
				if(this.type)
				{
					this.$copy.text(OzMobileRemoteCopy.getInstance()[this.type]);
				}

				if(this.type === ErrorView.TYPE_NOCHROME)
				{
					this.$getChromeButton.show();
					this.$continueButton.show();
				}
			},

			showTyped : function(type)
			{
				console.log('type', type);
				this.type = type;
				if(this.$copy)
				{
					this.$copy.text(OzMobileRemoteCopy.getInstance()[type]);
				}

				this.show();
			},

			show : function(direction)
			{
				this.$container.fadeIn();
			},

			hide : function(direction)
			{
				this.$container.fadeOut();
			},

			onGetChromeButtonClick : function(event)
			{
				event.preventDefault();
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.landingpage_useraction_clickgetchrome);
				if(Detection.getInstance().iOS)
				{
					window.location.href = 'itms-apps://itunes.apple.com/app/chrome/id535886823';
				} else
				{
					window.open('https://itunes.apple.com/us/app/chrome/id535886823', '_blank');
				}
			},

			onContinueButtonClick : function(event)
			{
				event.preventDefault();
				this.hide();
			}
		}
	})
]);