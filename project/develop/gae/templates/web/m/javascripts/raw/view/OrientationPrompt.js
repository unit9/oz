/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global OrientationPrompt */
/*global Modernizr */
/*global Analytics */

Package('view',
[
	Import('mjframe.View'),

	Class('public singleton OrientationPrompt extends View',
	{
		_public_static:
		{
			ORIENTATION_PORTRAIT	: 1,
			ORIENTATION_LANDSCAPE	: 2
		},

		_public:
		{
			allowedOrientation: null,
			lastOrientation: 1,

			OrientationPrompt : function()
			{
				this._super();
				this.allowedOrientation = OrientationPrompt.ORIENTATION_PORTRAIT;
				this.init('orientationPrompt', 'view.OrientationPrompt', 'OrientationPrompt');
			},

			onReady : function()
			{
				this.$container.hide();
				this.$el.css('display', '');
				this.onOrientationChange(null);
			},

			bindEvents : function()
			{
				this._super();

				$(window).bind('orientationchange', Poof.retainContext(this, this.onOrientationChange));
			},

			show : function(direction)
			{
				Poof.suppressUnused(direction);
				this.$container.fadeIn();
			},

			hide : function(direction)
			{
				Poof.suppressUnused(direction);
				this.$container.fadeOut();
			},

			onOrientationChange : function(event)
			{
				Poof.suppressUnused(event);
				
				if(!Modernizr.touch)
				{
					return;
				}

				var orientation = (window.orientation === 0 || window.orientation === 180) ? OrientationPrompt.ORIENTATION_PORTRAIT : OrientationPrompt.ORIENTATION_LANDSCAPE;

				if(orientation === this.lastOrientation)
				{
					return;
				}

				this.lastOrientation = orientation;

				if(orientation === this.allowedOrientation)
				{
					Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.global_useraction_orientationchangeportrait);
					this.hide();
				} else
				{
					Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.global_useraction_orientationchangelandscape);
					this.show();
				}
			}
		}
	})
]);