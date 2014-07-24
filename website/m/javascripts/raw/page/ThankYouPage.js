/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global OverlayController */
/*global VideoController */
/*global SharingController */
/*global OzMobileRemoteCopy */
/*global FooterViewSimple */
/*global HeaderViewSimple */
/*global Detection */
/*global Analytics */

Package('page',
[
	Import('page.OzPageBase'),
	Import('controller.OverlayController'),
	Import('controller.VideoController'),

	Class('public singleton ThankYouPage extends OzPageBase',
	{
		_public:
		{
			$reminderButton : null,
			$watchTrailerButton : null,
			$shareButton : null,
			$shareOverlay : null,
			$shareCloseButton : null,
			$shareGoogleButton : null,
			$shareFacebookButton : null,
			$shareTwitterButton : null,
			$link : null,

			ThankYouPage : function()
			{
				this._super();

				this.prevPage = '/storm2';
				this.nextPage = '/footer';
				this.overscrollNavigationEnabled = true;
			},

			compile : function()
			{
				this._super();

				this.$reminderButton = $('#reminderButton');
				this.$watchTrailerButton = $('#watchTrailerButton');
				this.$shareButton = $('#globalShareButton');
				this.$shareOverlay = $('#globalShareOverlay');
				this.$shareCloseButton = $('#globalShareCloseButton');
				this.$shareGoogleButton = $('#globalShareGoogleButton');
				this.$shareFacebookButton = $('#globalShareFacebookButton');
				this.$shareTwitterButton = $('#globalShareTwitterButton');
				this.$link = $('#globalShareLinkInput');
			},

			bindEvents : function()
			{
				this._super();

				this.$reminderButton.bind('click', Poof.retainContext(this, this.onReminderButtonClick));
				this.$watchTrailerButton.bind('click', Poof.retainContext(this, this.onWatchTrailerButtonClick));
				this.$shareButton.bind('click', Poof.retainContext(this, this.onShareButtonClick));
				this.$shareCloseButton.bind('click', Poof.retainContext(this, this.onShareCloseButtonClick));
				this.$shareGoogleButton.bind('click', Poof.retainContext(this, this.onShareGoogleButtonClick));
				this.$shareFacebookButton.bind('click', Poof.retainContext(this, this.onShareFacebookButtonClick));
				this.$shareTwitterButton.bind('click', Poof.retainContext(this, this.onShareTwitterButtonClick));
				this.$link.bind('mouseup, touchend', Poof.retainContext(this, this.onShareLinkInputUp));
				this.$link.bind('change, keydown, keyup', Poof.retainContext(this, this.onShareLinkInputChange));
			},

			onReady : function()
			{
				this._super();

				OverlayController.getInstance().showThankYouOverlay();
			},

			deactivate : function()
			{
				this._super();
				VideoController.getInstance().stopVideo();
			},

			showShareOverlay : function()
			{
				FooterViewSimple.getInstance().hide();
				HeaderViewSimple.getInstance().hide();
				this.$shareOverlay.fadeIn();
			},

			hideShareOverlay : function()
			{
				FooterViewSimple.getInstance().show();
				HeaderViewSimple.getInstance().show();
				this.$shareOverlay.fadeOut();
			},

			onReminderButtonClick : function(event)
			{
				event.preventDefault();

				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.welcometoozpage_useraction_setupreminder);
				
				if(Detection.getInstance().chrome && Detection.getInstance().iOS)
				{
					window.location.href = 'webcal://' + window.location.host + '/api/reminder/' + Detection.getInstance().language;
				} else
				{
					window.location.href = '/api/reminder/' + Detection.getInstance().language;
				}
			},

			onWatchTrailerButtonClick : function(event)
			{
				event.preventDefault();
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.welcometoozpage_useraction_watchtrailer);
				VideoController.getInstance().playVideo();
			},

			onShareButtonClick : function(event)
			{
				event.preventDefault();
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.welcometoozpage_useraction_touchshare);
				this.showShareOverlay();
			},

			onShareCloseButtonClick : function(event)
			{
				event.preventDefault();
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.welcometoozpage_useraction_touchshareclose);
				this.hideShareOverlay();
			},

			onShareGoogleButtonClick : function(event)
			{
				event.preventDefault();
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.welcometoozpage_useraction_touchsharegoogle);
				SharingController.getInstance().shareLinkOnGoogle(this.$link.val());
			},

			onShareFacebookButtonClick : function(event)
			{
				event.preventDefault();
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.welcometoozpage_useraction_touchsharefacebook);
				SharingController.getInstance().shareLinkOnFacebook(this.$link.val(), 'DISNEY OZ', OzMobileRemoteCopy.getInstance().Share_facebook);
			},

			onShareTwitterButtonClick : function(event)
			{
				event.preventDefault();
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.welcometoozpage_useraction_touchsharetwitter);
				SharingController.getInstance().shareOnTwitter(OzMobileRemoteCopy.getInstance().Share_twitter);
			},

			onShareLinkInputUp : function(event)
			{
				event.preventDefault();
				event.stopPropagation();
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.welcometoozpage_useraction_touchsharelink);
				this.$link[0].setSelectionRange(0, 9999);
			},

			onShareLinkInputChange : function(event)
			{
				event.preventDefault();
				event.stopPropagation();
				this.$link.val(window.location.protocol + '//' + window.location.host);
			}
		}
	})
]);