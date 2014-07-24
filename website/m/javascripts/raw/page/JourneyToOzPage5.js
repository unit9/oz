/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global JourneyToOzScrollController */
/*global OverlayController */

Package('page',
[
	Import('page.OzPageBase'),
	Import('controller.JourneyToOzScrollController'),

	Class('public singleton JourneyToOzPage5 extends OzPageBase',
	{
		_public:
		{
			$contentDiv : null,
			$arrowLeft : null,
			$arrowRight : null,

			JourneyToOzPage5 : function()
			{
				this._super();
				this.prevPage = '/storm1';
				this.nextPage = '/welcometooz';
				this.overscrollNavigationEnabled = true;
			},

			compile : function()
			{
				this._super();

				this.$content.addClass('JourneyToOzPage');
				this.$contentDiv = $('.JourneyToOzPage5 .content');
				this.$arrowLeft = $('.JourneyToOzPage5 .arrow-left');
				this.$arrowRight = $('.JourneyToOzPage5 .arrow-right');
			},

			bindEvents : function()
			{
				JourneyToOzScrollController.getInstance().on(JourneyToOzScrollController.EVENT_OVERSCROLL_UP, Poof.retainContext(this, this.onOverscrollUp));
				JourneyToOzScrollController.getInstance().on(JourneyToOzScrollController.EVENT_OVERSCROLL_DOWN, Poof.retainContext(this, this.onOverscrollDown));
			},

			onReady : function()
			{
				this._super();

				OverlayController.getInstance().showJourneyToOzOverlay();
				JourneyToOzScrollController.getInstance().init(this.$contentDiv, this.$arrowLeft, this.$arrowRight);
			},

			onShow : function()
			{
				this._super();
				
				JourneyToOzScrollController.getInstance().enable();
			},

			deactivate : function()
			{
				this._super();
				JourneyToOzScrollController.getInstance().off(JourneyToOzScrollController.EVENT_OVERSCROLL_UP);
				JourneyToOzScrollController.getInstance().off(JourneyToOzScrollController.EVENT_OVERSCROLL_DOWN);
				JourneyToOzScrollController.getInstance().disable();
			},

			onOverscrollUp : function(event)
			{
				Poof.suppressUnused(event);
				this.goNext();
			},

			onOverscrollDown : function(event)
			{
				Poof.suppressUnused(event);
				this.goBack();
			}
		}
	})
]);