/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global PageManager */
/*global Analytics */

Package('view',
[
	Import('mjframe.View'),

	Class('public singleton HeaderViewSimple extends View',
	{
		_public:
		{
			$arrowScrollUp : null,

			HeaderViewSimple : function()
			{
				this._super();
				this.init('headerSimple', 'view.HeaderViewSimple', 'HeaderSimple');
			},

			compile : function()
			{
				this._super();

				this.$arrowScrollUp = $('#arrowScrollUp');
			},

			bindEvents : function()
			{
				this._super();

				this.$arrowScrollUp.bind('click', Poof.retainContext(this, this.onArrowScrollUpClick));
			},

			show : function(direction)
			{
				Poof.suppressUnused(direction);
				this.$el.fadeIn();
			},

			hide : function(direction)
			{
				Poof.suppressUnused(direction);
				this.$el.fadeOut();
			},

			onArrowScrollUpClick : function(event)
			{
				event.preventDefault();
				if(PageManager.getInstance().getCurrentPage().canGoBack())
				{
					Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.global_useraction_navigateuparrow);
				}
				PageManager.getInstance().getCurrentPage().goBack();
			}
		}
	})
]);