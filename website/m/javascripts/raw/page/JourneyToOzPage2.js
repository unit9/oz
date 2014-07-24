/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global JourneyToOzScrollController */
/*global OverlayController */
/*global Modernizr */
/*global JourneyToOzPage2 */
/*global Analytics */

Package('page',
[
	Import('page.OzPageBase'),
	Import('controller.JourneyToOzScrollController'),

	Class('public singleton JourneyToOzPage2 extends OzPageBase',
	{
		_public_static:
		{
			INSTRUCTIONS_DISMISS_DELAY : 5000
		},

		_public:
		{
			$contentDiv : null,
			$introOverlay : null,
			$arrowLeft : null,
			$arrowRight : null,

			firstTime : true,

			JourneyToOzPage2 : function()
			{
				this._super();
				this.prevPage = '/cutout';
				this.nextPage = '/circus3';
				this.overscrollNavigationEnabled = true;
			},

			compile : function()
			{
				this._super();

				this.$content.addClass('JourneyToOzPage');
				this.$contentDiv = $('.JourneyToOzPage2 .content');
				this.$introOverlay = this.$content.find('.journeyIntroOverlay');
				this.$arrowLeft = $('.JourneyToOzPage2 .arrow-left');
				this.$arrowRight = $('.JourneyToOzPage2 .arrow-right');
			},

			bindEvents : function()
			{
				this.$introOverlay.bind(Modernizr.touch ? 'touchstart' : 'click', Poof.retainContext(this, this.onIntroOverlayClick));
				JourneyToOzScrollController.getInstance().on(JourneyToOzScrollController.EVENT_OVERSCROLL_UP, Poof.retainContext(this, this.onOverscrollUp));
				JourneyToOzScrollController.getInstance().on(JourneyToOzScrollController.EVENT_OVERSCROLL_DOWN, Poof.retainContext(this, this.onOverscrollDown));
			},

			onReady : function()
			{
				this._super();

				OverlayController.getInstance().showJourneyToOzOverlay();
				JourneyToOzScrollController.getInstance().init(this.$contentDiv, this.$arrowLeft, this.$arrowRight);

				if(this.firstTime)
				{
					this.firstTime = false;
					this.showIntroOverlay();
					this.hideIntroOverlayAtDelay(JourneyToOzPage2.INSTRUCTIONS_DISMISS_DELAY);
				}
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

			showIntroOverlay : function()
			{
				this.$introOverlay.show();
			},

			hideIntroOverlay : function()
			{
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.circus2page_useraction_instructionsdismiss);
				this.$introOverlay.fadeOut();
			},

			hideIntroOverlayAtDelay : function(delay)
			{
				setTimeout(Poof.retainContext(this, function()
				{
					if(this.$introOverlay.is(':visible') && parseFloat(this.$introOverlay.css('opacity')) === 1)
					{
						Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.circus2page_automatic_instructionsdismiss);
						this.$introOverlay.fadeOut();
					}
					this.$introOverlay.fadeOut();
				}), delay);
			},

			onIntroOverlayClick : function()
			{
				this.hideIntroOverlay();
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