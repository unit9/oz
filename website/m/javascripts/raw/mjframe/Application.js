/*global Package */
/*global Import */
/*global Class */

/*global Copy */
/*global NavigationManager */
/*global PageManager */
/*global Modernizr */
/*global Template */
/*global MjConfig */

Package('mjframe',
[
	Import('MjConfig'),
	Import('mjframe.Copy'),
	Import('mjframe.NavigationManager'),
	Import('mjframe.PageManager'),
	Import('mjframe.Template'),

	Class('public abstract Application',
	{
		_public:
		{
			config : null,
			locale : null,

			Application : function()
			{
				this.config = window.config = MjConfig.getInstance();
				this.registerPages(this.config.pages);
				this.setLocale(this.config.defaultLocale);
				window.PLATFORM = Modernizr.touch ? 'mobile' : 'desktop';
				Template.baseImportPath = this.config.templatesPath;
			},

			start : function() {
				NavigationManager.getInstance().activate();
				NavigationManager.getInstance().onUrlChange();
			},

			setLocale : function(locale)
			{
				this.locale = locale;
				this.dispatch(Copy.EVENT_LOCALE_CHANGE, locale);
			},

			registerPages : function(pages)
			{
				NavigationManager.getInstance().init();

				for(var i = 0; i < pages.length; i ++)
				{
					PageManager.getInstance().registerPage(pages[i].pageName, pages[i].className, pages[i].url, 'useRegExp' in pages[i] ? pages[i].useRegExp : false, 'popup' in pages[i] ? pages[i].popup : false, 'pageUrl' in pages[i] ? pages[i].pageUrl : null);
				}
			}
		}
	})
]);
