/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global OverlayController */
/*global Detection */
/*global Analytics */

Package('page',
[
	Import('page.OzPageBase'),

	Class('public singleton HomePage extends OzPageBase',
	{
		_public:
		{
			$checkbox : null,
			$checkboxToggle : null,
			$termsLink : null,
			$enterButton : null,
			$logoChromeExperiment : null,
			$logoGoogle : null,
			$ratingBlock : null,
			$homeContainer : null,

			aggreed : false,
			firstTime : true,

			HomePage : function()
			{
				this._super();
			},

			compile : function()
			{
				this._super();

				this.prevPage = null;
				this.nextPage = '/circus1';
				
				this.overscrollNavigationEnabled = true;

				this.$checkbox = $('#termsCheckbox');
				this.$checkboxToggle = this.$checkbox.find('.checkbox');
				this.$termsLink = this.$checkbox.find('a').attr('href', '/tou.html').attr('target', '_blank');
				this.$downloadChromeButton = $('#downloadChromeButton');
				this.$enterButton = $('#enterButton');
				this.$logoChromeExperiment = $('.logoChromeExperiment');
				this.$logoGoogle = $('.logoGoogle');
				this.$ratingBlock = $('.logoPg');
				this.$homeContainer = this.$content.find('.homeContainer');

				setTimeout(Poof.retainContext(this, function()
				{
					this.onResize();
				}), 1);
			},

			bindEvents : function()
			{
				this._super();

				this.$checkbox.bind('click', Poof.retainContext(this, this.onTermsCheckboxClick));
				this.$downloadChromeButton.bind('click', Poof.retainContext(this, this.onDownloadChromeButtonClick));
				this.$termsLink.bind('click', Poof.retainContext(this, this.onTermsLinkClick));
				this.$enterButton.bind('click', Poof.retainContext(this, this.onEnterButtonClick));
				this.$logoChromeExperiment.unbind('click').bind('click', Poof.retainContext(this, this.onChromeExperimentClick));
				this.$logoGoogle.unbind('click').bind('click', Poof.retainContext(this, this.onGoogleClick));
				this.$ratingBlock.unbind('click').bind('click', Poof.retainContext(this, this.onRatingClick));
			},

			onReady : function()
			{
				this._super();

				OverlayController.getInstance().showHomeOverlay();
				this.setAgreed(this.agreed);
				this.firstTime = false;
			},

			canGoNext : function()
			{
				return this.$enterButton.hasClass('enabled');
			},

			setAgreed : function(agreed)
			{
				this.agreed = agreed;
				if(this.agreed)
				{
					if(!this.firstTime)
					{
						Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.landingpage_useraction_checkterms);
					}
					this.$checkboxToggle.addClass('selected');
					this.$enterButton.removeClass('disabled').addClass('enabled');
				} else
				{
					if(!this.firstTime)
					{
						Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.landingpage_useraction_uncheckterms);
					}
					this.$checkboxToggle.removeClass('selected');
					this.$enterButton.removeClass('enabled').addClass('disabled');
				}
			},

			onTermsCheckboxClick : function(event)
			{
				Poof.suppressUnused(event);
				this.setAgreed(!this.agreed);
			},

			onTermsLinkClick : function(event)
			{
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.landingpage_useraction_opentermslink);
				event.stopPropagation();
			},

			onDownloadChromeButtonClick : function(event)
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

			onEnterButtonClick : function(event)
			{
				event.preventDefault();
				if(this.canGoNext())
				{
					Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.landingpage_useraction_clickenter);
				}
				this.goNext();
			},

			onChromeExperimentClick : function(event)
			{
				event.preventDefault();
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.landingpage_useraction_openchromeexperimentlink);
				window.open('http://www.chromeexperiments.com', '_blank');
			},

			onGoogleClick : function(event)
			{
				event.preventDefault();
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.landingpage_useraction_opengooglelink);
				window.open('http://www.google.com', '_blank');
			},

			onRatingClick : function(event)
			{
				event.preventDefault();
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.landingpage_useraction_openpglink);
				window.open('http://www.mpaa.org', '_blank');
			},

			onResize : function(event)
			{
				Poof.suppressUnused(event);
				this.$homeContainer.css('margin-top', -this.$homeContainer.height() * 0.5);
			}
		}
	})
]);