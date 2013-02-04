/*global Poof */
/*global Package */
/*global Load */
/*global Import */
/*global Class */

/*global SplashScreen */
/*global ErrorView */
/*global Analytics */

Poof.loadCondition = function()
{
	return !Poof.concatenated;
	// return true;	// for debugging
};

Package('',
[
	/* load all libraries */
	Load('/m/javascripts/min/lib/jquery-1.8.3.min.js'),
	Load('/m/javascripts/min/lib/jquery.easing.1.3.min.js'),
	Load('/m/javascripts/min/lib/jQueryRotate.2.2.min.js'),
	Load('/m/javascripts/min/lib/jquery.ui.widget.min.js'),
	Load('/m/javascripts/min/lib/jquery.fileupload.min.js'),
	Load('/m/javascripts/min/lib/jquery.hittest.min.js'),
	Load('/m/javascripts/min/lib/BinaryAjax.min.js'),
	Load('/m/javascripts/min/lib/exif.min.js'),
	Load('/m/javascripts/min/lib/modernizr.custom.27513.min.js'),
	Load('/m/javascripts/min/lib/TweenLite.min.js'),

	/* import classes */
	Import('mjframe.Application'),
	Import('util.Detection'),
	Import('copy.OzMobileRemoteCopy'),
	Import('controller.PreloadController'),
	Import('controller.AnimationController'),
	Import('controller.OverlayController'),
	Import('controller.GestureController'),
	Import('util.MobileUtils'),
	Import('util.Analytics'),
	Import('page.HomePage'),

	Import('view.ErrorView'),
	Import('view.OrientationPrompt'),
	Import('view.SplashScreen'),
	Import('view.PreloaderCard'),

	Import('fx.Fx'),

	Class('public singleton OzMobileApplication extends Application',
	{
		_public:
		{
			debugMode : false,
			$wrapper : null,

			OzMobileApplication : function()
			{
				this._super();
				window.PLATFORM = 'mobile';	// force mobile

				this.initCore();

				if(window.location.search.indexOf('?debug=true') !== -1 || window.location.search.indexOf('&debug=true') !== -1)
				{
					this.initDebugMode();
				}

				this.initMobile();
				PreloadController.getInstance().on(PreloadController.EVENT_PRELOADER_COMPLETE, Poof.retainContext(this, this.onPreloaderPreloadComplete));
				PreloadController.getInstance().preloadPreloader();
			},

			initCore : function()
			{
				Analytics.getInstance().init();
				Detection.getInstance().detect();

				Copy.useSharedCopy = true;
				Copy.sharedCopyClass = OzMobileRemoteCopy;
				View.REMOVE_ON_HIDE = Detection.getInstance().android;
				AnimationController.getInstance().init();
				AnimationController.getInstance().start();
				LayoutAnimation.init();

				NavigationManager.getInstance().on(NavigationManager.EVENT_URL_CHANGE, Poof.retainContext(this, this.onUrlChange));

				return true;
			},

			initDebugMode : function()
			{
				this.debugMode = true;
			},

			initMobile : function()
			{
				MobileUtils.getInstance().hideAddressBar();
				MobileUtils.getInstance().preventElasticScrollingUp = true;
				MobileUtils.getInstance().preventElasticScrollingDown = true;
				GestureController.getInstance().enable();
			},

			initLayout : function()
			{
				this.$wrapper = $('#wrapper');
			},

			bindEvents : function()
			{
				SplashScreen.getInstance().on(SplashScreen.EVENT_SHOWN, Poof.retainContext(this, this.onSplashShown));
				SplashScreen.getInstance().on(SplashScreen.EVENT_HIDDEN, Poof.retainContext(this, this.onSplashHidden));
				PreloaderCard.getInstance().on(PreloaderCard.EVENT_COMPLETE, Poof.retainContext(this, this.onPreloadComplete));
			},

			onSplashShown : function()
			{
				this.$wrapper.css('z-index', '1').show();
				Fx.getInstance().showParticles();
			},

			onSplashHidden : function()
			{
				PreloaderCard.getInstance().show();
				PreloadController.getInstance().preloadMain();
			},

			onPreloaderPreloadComplete : function()
			{
				if((Detection.getInstance().iOS && Detection.getInstance().iOSVersion < 6) || (!Detection.getInstance().iOS && !Detection.getInstance().android && window.location.host !== 'oz.unit9'))
				{
					ErrorView.getInstance().showTyped(ErrorView.TYPE_CONFIGURATION);
					return false;
				}

				this.initLayout();
				this.bindEvents();

				SplashScreen.getInstance().show();
			},

			onPreloadComplete : function()
			{
				this.start();
				if(!Detection.getInstance().chrome)
				{
					ErrorView.getInstance().showTyped(ErrorView.TYPE_NOCHROME);
				}
				OrientationPrompt.getInstance();
			},

			onUrlChange : function(event)
			{
				Analytics.getInstance().trackGoogleAnalyticsPageView(event.data.url);
			}
		}
	})
]);