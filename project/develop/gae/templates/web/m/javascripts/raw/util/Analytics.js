/*global Package */
/*global Class */

/*global MjConfig */
/*global Analytics */

Package('util',
[
	Class('public singleton Analytics',
	{
		_public_static:
		{
			FLOOD_CATEGORIES_BY_TAG:
			{
				test: 'test'
			},

			// Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.page_type_action);

			GA_EVENTS:
			{
				preloader_automatic_loadingstart : {category: 'Preloader', action: 'Automatic', label: 'Start Loading'},
				preloader_automatic_loadingfinish : {category: 'Preloader', action: 'Automatic', label: 'Finish Loading'},
				preloader_useraction_flipcard : {category: 'Preloader', action: 'User Action', label: 'Flip Card'},
				
				landingpage_useraction_checkterms : {category: 'Landing Page', action: 'User Action', label: 'Check Terms'},
				landingpage_useraction_uncheckterms : {category: 'Landing Page', action: 'User Action', label: 'Uncheck Terms'},
				landingpage_useraction_opentermslink : {category: 'Landing Page', action: 'User Action', label: 'Open Terms Link'},
				landingpage_useraction_clickenter : {category: 'Landing Page', action: 'User Action', label: 'Click Enter'},
				landingpage_useraction_clickgetchrome : {category: 'Landing Page', action: 'User Action', label: 'Click Get Chrome'},
				landingpage_useraction_openchromeexperimentlink : {category: 'Landing Page', action: 'User Action', label: 'Open Chrome Experiment Link'},
				landingpage_useraction_opengooglelink : {category: 'Landing Page', action: 'User Action', label: 'Open Google Link'},
				landingpage_useraction_openpglink : {category: 'Landing Page', action: 'User Action', label: 'Open PG Link'},
				
				circus1page_automatic_instructionsdismiss : {category: 'Circus 1 Page', action: 'Automatic', label: 'Instructions Dismiss'},
				circus1page_useraction_instructionsdismiss : {category: 'Circus 1 Page', action: 'User Action', label: 'Instructions Dismiss'},
				circus1page_useraction_explore : {category: 'Circus 1 Page', action: 'User Action', label: 'Explore'},
				
				cutoutpage_automatic_instructionsdismiss : {category: 'Cutout Page', action: 'Automatic', label: 'Instructions Dismiss'},
				cutoutpage_useraction_instructionsdismiss : {category: 'Cutout Page', action: 'User Action', label: 'Instructions Dismiss'},
				cutoutpage_useraction_touchupload : {category: 'Cutout Page', action: 'User Action', label: 'Touch Upload'},
				cutoutpage_automatic_uploadstart : {category: 'Cutout Page', action: 'User Action', label: 'Upload Start'},
				cutoutpage_automatic_uploadfinish : {category: 'Cutout Page', action: 'User Action', label: 'Upload Finish'},
				cutoutpage_useraction_touchedit : {category: 'Cutout Page', action: 'User Action', label: 'Touch Edit'},
				cutoutpage_useraction_touchshare : {category: 'Cutout Page', action: 'User Action', label: 'Touch Share'},
				cutoutpage_useraction_touchreupload : {category: 'Cutout Page', action: 'User Action', label: 'Touch Reupload'},
				cutoutpage_useraction_touchsharegoogle : {category: 'Cutout Page', action: 'User Action', label: 'Touch Share Google'},
				cutoutpage_useraction_touchsharefacebook : {category: 'Cutout Page', action: 'User Action', label: 'Touch Share Facebook'},
				cutoutpage_useraction_touchsharetwitter : {category: 'Cutout Page', action: 'User Action', label: 'Touch Share Twitter'},
				cutoutpage_useraction_touchsharelink : {category: 'Cutout Page', action: 'User Action', label: 'Touch Share Link'},
				cutoutpage_useraction_touchshareclose : {category: 'Cutout Page', action: 'User Action', label: 'Touch Share Close'},
				cutoutpage_useraction_changecutout : {category: 'Cutout Page', action: 'User Action', label: 'Change Cutout'},
				
				circus2page_automatic_instructionsdismiss : {category: 'Circus 2 Page', action: 'Automatic', label: 'Instructions Dismiss'},
				circus2page_useraction_instructionsdismiss : {category: 'Circus 2 Page', action: 'User Action', label: 'Instructions Dismiss'},
				circus2page_useraction_explore : {category: 'Circus 2 Page', action: 'User Action', label: 'Explore'},
				
				circus3page_useraction_explore : {category: 'Circus 3 Page', action: 'User Action', label: 'Explore'},
				
				storm1page_automatic_instructionsdismiss : {category: 'Storm 1 Page', action: 'Automatic', label: 'Instructions Dismiss'},
				storm1page_useraction_instructionsdismiss : {category: 'Storm 1 Page', action: 'User Action', label: 'Instructions Dismiss'},
				storm1page_useraction_explore : {category: 'Storm 1 Page', action: 'User Action', label: 'Explore'},

				storm2page_useraction_explore : {category: 'Storm 2 Page', action: 'User Action', label: 'Explore'},
				
				welcometoozpage_useraction_watchtrailer : {category: 'Welcome To Oz Page', action: 'User Action', label: 'Watch Trailer'},
				welcometoozpage_useraction_setupreminder : {category: 'Welcome To Oz Page', action: 'User Action', label: 'Setup Reminder'},
				welcometoozpage_useraction_touchshare : {category: 'Welcome To Oz Page', action: 'User Action', label: 'Touch Share'},
				welcometoozpage_useraction_touchsharegoogle : {category: 'Welcome To Oz Page', action: 'User Action', label: 'Touch Share Google'},
				welcometoozpage_useraction_touchsharefacebook : {category: 'Welcome To Oz Page', action: 'User Action', label: 'Touch Share Facebook'},
				welcometoozpage_useraction_touchsharetwitter : {category: 'Welcome To Oz Page', action: 'User Action', label: 'Touch Share Twitter'},
				welcometoozpage_useraction_touchsharelink : {category: 'Welcome To Oz Page', action: 'User Action', label: 'Touch Share Link'},
				welcometoozpage_useraction_touchshareclose : {category: 'Welcome To Oz Page', action: 'User Action', label: 'Touch Share Close'},
				
				footerpage_useraction_touchtermslink : {category: 'Footer Page', action: 'User Action', label: 'Touch Terms Link'},
				footerpage_useraction_touchprivacylink : {category: 'Footer Page', action: 'User Action', label: 'Touch Privacy Link'},
				footerpage_useraction_touchbacktotop : {category: 'Footer Page', action: 'User Action', label: 'Touch Back To Top'},
				
				global_useraction_navigateupslide : {category: 'Global', action: 'User Action', label: 'Navigate Up Slide'},
				global_useraction_navigatedownslide : {category: 'Global', action: 'User Action', label: 'Navigate Down Slide'},
				global_useraction_navigateuparrow : {category: 'Global', action: 'User Action', label: 'Navigate Up Arrow'},
				global_useraction_navigatedownarrow : {category: 'Global', action: 'User Action', label: 'Navigate Down Arrow'},
				global_useraction_orientationchangelandscape : {category: 'Global', action: 'User Action', label: 'Orientation Change Landscape'},
				global_useraction_orientationchangeportrait : {category: 'Global', action: 'User Action', label: 'Orientation Change Portrait'}
			}
		},

		_public:
		{
			initialised : false,

			Analytics : function()
			{
			},

			init : function()
			{
				this.setUpGoogleAnalytics(MjConfig.getInstance().googleAnalyticsAccount);
			},

			setUpGoogleAnalytics : function(account)
			{
				if(this.initialised)
				{
					return;
				}

				this.initialised = true;

				window._gaq = window._gaq || [];
				window._gaq.push(['_setAccount', account]);
				window._gaq.push(['_trackPageview']);

				(function() {
					var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
					ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
					var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
				})();
			},

			trackGoogleAnalyticsPageView : function(page)
			{
				window._gaq.push(['_trackPageview', page]);
			},

			trackGoogleAnalyticsEvent : function(event)
			{
				this.log('tracking event:', JSON.stringify(event));
				window._gaq.push(['_trackEvent', event.category, event.action, event.label, event.value]);
			},

			trackFloodLight : function(tag)
			{
				var old = $('#floodLightTrack');
				if(old.length !== 0)
				{
					old.remove();
				}

				var axel = Math.random();
				var a = axel * 10000000000000;
				var cat = Analytics.FLOOD_CATEGORIES_BY_TAG[tag];
				var track = $('<img id="floodlightTrack" />');
				track.attr('width', 1);
				track.attr('height', 1);
				track.attr('style', 'visibility:hidden; position: absolute; top:0; left:0');
				track.attr('src', 'http://3944448.fls.doubleclick.net/activityi;src=3944448;type=googl379;cat={cat};ord={a}?'.replace('{cat}', cat).replace('{a}', a));

				$('body').prepend(track);
			}
		}
	})
]);