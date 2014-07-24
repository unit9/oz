/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global NavigationManager */
/*global LayoutAnimation */
/*global GestureController */
/*global Analytics */

Package('page',
[
	Import('mjframe.Page'),
	Import('mjframe.NavigationManager'),
	Import('mjframe.LayoutAnimation'),
	Import('controller.GestureController'),

	Class('public OzPageBase extends Page',
	{
		_public:
		{
			nextPage : null,
			prevPage : null,
			overscrollNavigationEnabled : false,

			OzPageBase : function()
			{
				this._super();
			},

			bindEvents : function()
			{
				this._super();
			},

			activate : function()
			{
				this._super();

				GestureController.getInstance().on(GestureController.EVENT_SWIPE_UP, Poof.retainContext(this, this.onSwipeUp));
				GestureController.getInstance().on(GestureController.EVENT_SWIPE_DOWN, Poof.retainContext(this, this.onSwipeDown));
			},

			deactivate : function()
			{
				GestureController.getInstance().off(GestureController.EVENT_SWIPE_UP);
				GestureController.getInstance().off(GestureController.EVENT_SWIPE_DOWN);
			},

			canGoNext : function()
			{
				return true;
			},

			canGoBack : function()
			{
				return true;
			},

			goNext : function()
			{
				if(this.nextPage && this.canGoNext())
				{
					NavigationManager.getInstance().goTo(this.nextPage);
				}
			},

			goBack : function()
			{
				if(this.prevPage && this.canGoBack())
				{
					NavigationManager.getInstance().goTo(this.prevPage, null, LayoutAnimation.DIRECTION_BACKWARD);
				}
			},

			onSwipeUp : function(event)
			{
				Poof.suppressUnused(event);
				if(this.overscrollNavigationEnabled)
				{
					if(this.canGoNext())
					{
						Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.global_useraction_navigatedownslide);
					}

					this.goNext();
				}
			},

			onSwipeDown : function(event)
			{
				Poof.suppressUnused(event);
				if(this.overscrollNavigationEnabled)
				{
					if(this.canGoBack())
					{
						Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.global_useraction_navigateupslide);
					}

					this.goBack();
				}
			}
		}
	})
]);