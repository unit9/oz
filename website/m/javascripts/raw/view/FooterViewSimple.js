/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global PageManager */
/*global Analytics */

Package('view',
[
	Import('mjframe.View'),

	Class('public singleton FooterViewSimple extends View',
	{
		_public:
		{
			$arrowScrollDown : null,

			FooterViewSimple : function()
			{
				this._super();
				this.init('footerSimple', 'view.FooterViewSimple', 'FooterSimple');
			},

			compile : function()
			{
				this._super();

				this.$arrowScrollDown = $('#arrowScrollDown');
			},

			bindEvents : function()
			{
				this._super();

				this.$arrowScrollDown.bind('click', Poof.retainContext(this, this.onArrowScrollDownClick));
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

			onArrowScrollDownClick : function(event)
			{
				event.preventDefault();
				if(PageManager.getInstance().getCurrentPage().canGoNext())
				{
					Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.global_useraction_navigatedownarrow);
				}
				PageManager.getInstance().getCurrentPage().goNext();
			}
		}
	})
]);