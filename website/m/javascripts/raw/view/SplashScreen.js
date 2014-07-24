/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global SplashScreen */

Package('view',
[
	Import('mjframe.View'),

	Class('public singleton SplashScreen extends View',
	{
		_public_static:
		{
			EVENT_HIDDEN	: 'SplashScreen.Event.Hidden',
			EVENT_SHOWN		: 'SplashScreen.Event.Shown',

			SHOW_DELAY		: 1000,
			SHOW_TIME		: 1000,
			TRANSITION_TIME	: 2000
		},

		_public:
		{
			$contentDiv : null,

			SplashScreen : function()
			{
				this._super();
				this.init('splash', 'view.SplashScreen', 'SplashScreen');
			},

			compile : function()
			{
				this.$contentDiv = $('#splashContent').hide();
			},

			onReady : function()
			{
				this.$el.css('display', '');
			},

			show : function(direction)
			{
				Poof.suppressUnused(direction);
				setTimeout(Poof.retainContext(this, function()
				{
					this.$contentDiv.stop().fadeTo(SplashScreen.TRANSITION_TIME, 1, Poof.retainContext(this, this.onShown));
					setTimeout(Poof.retainContext(this, this.hide), SplashScreen.TRANSITION_TIME + SplashScreen.SHOW_TIME);
				}), SplashScreen.SHOW_DELAY);
			},

			hide : function(direction)
			{
				Poof.suppressUnused(direction);
				this.$contentDiv.fadeOut(SplashScreen.TRANSITION_TIME, Poof.retainContext(this, function()
				{
					this.$container.fadeOut(SplashScreen.TRANSITION_TIME, Poof.retainContext(this, this.onHidden));
				}));
			},

			onShown : function()
			{
				this.dispatch(SplashScreen.EVENT_SHOWN);
			},

			onHidden : function()
			{
				this.dispatch(SplashScreen.EVENT_HIDDEN);
			}
		}
	})
]);