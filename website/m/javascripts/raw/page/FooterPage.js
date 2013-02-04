/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global OverlayController */
/*global NavigationManager */
/*global LayoutAnimation */
/*global Analytics */

Package('page',
[
	Import('page.OzPageBase'),
	Import('controller.OverlayController'),

	Class('public singleton FooterPage extends OzPageBase',
	{
		_public:
		{
			$goToTopButton : null,
			$termsButton : null,
			$privacyButton : null,

			FooterPage : function()
			{
				this._super();

				this.nextPage = null;
				this.prevPage = '/welcometooz';
				this.overscrollNavigationEnabled = true;
			},

			compile : function()
			{
				this._super();

				this.$goToTopButton = $('#goToTopButton');
				this.$termsButton = $('#footerTermsButton');
				this.$privacyButton = $('#footerPrivacyButton');
			},

			bindEvents : function()
			{
				this.$termsButton.bind('click', Poof.retainContext(this, this.onTermsButtonClick));
				this.$privacyButton.bind('click', Poof.retainContext(this, this.onPrivacyButtonClick));
				this.$goToTopButton.bind('click', Poof.retainContext(this, this.onGoToTopButtonClick));
			},

			onReady : function()
			{
				this._super();

				OverlayController.getInstance().showFooterOverlay();
			},

			onTermsButtonClick : function()
			{
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.footerpage_useraction_touchtermslink);
			},

			onPrivacyButtonClick : function()
			{
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.footerpage_useraction_touchprivacylink);
			},

			onGoToTopButtonClick : function()
			{
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.footerpage_useraction_touchbacktotop);
				NavigationManager.getInstance().goTo('/', null, LayoutAnimation.DIRECTION_BACKWARD);
			}
		}
	})
]);