/*global Package */
/*global Import */
/*global Class */

Package('',
[
	Import('mjframe.MjConfigBase'),

	Class('public singleton MjConfig extends MjConfigBase',
	{
		_public_static:
		{
			map:
			{
				configLocal: ['localhost', 'oz.unit9', 'm.oz.unit9', 'oz.unit9.com'],
				configDev: ['svn525.dev.unit9.net', '8.u9ozdev.appspot.com'],
				configTest: ['svn525.test.unit9.net'],
				configProd: ['.*']
			},

			configCommon:
			{
				defaultLocale: 'en',
				rootPath: '/m',
				templatesPath: '/m/templates/',
				shareLinkBase: '/preview/cutout/{id}',

				pages:
				[
					{className: 'page.HomePage', url: '/'},
					{className: 'page.JourneyToOzPage1', url: '/circus1'},
					{className: 'page.CutoutPage', url: '/cutout'},
					{className: 'page.JourneyToOzPage2', url: '/circus2'},
					{className: 'page.JourneyToOzPage3', url: '/circus3'},
					{className: 'page.JourneyToOzPage4', url: '/storm1'},
					{className: 'page.JourneyToOzPage5', url: '/storm2'},
					{className: 'page.ThankYouPage', url: '/welcometooz'},
					{className: 'page.FooterPage', url: '/footer'}
				]
			},

			configLocal:
			{
				debug: true,
				uploadUrl: '/api/image/add',
				googleAnalyticsAccount: 'UA-37917024-2'
			},

			configDev:
			{
				debug: true,
				uploadUrl: '/api/image/add',
				googleAnalyticsAccount: 'UA-37917024-1'
			},

			configTest:
			{
				debug: false,
				uploadUrl: '/api/image/add',
				googleAnalyticsAccount: 'UA-37524215-3'
			},

			configProd:
			{
				debug: false,
				uploadUrl: '/api/image/add',
				googleAnalyticsAccount: 'UA-37524215-3'
			},

			configDefault:
			{
				debug: false,
				uploadUrl: '/api/image/add',
				googleAnalyticsAccount: 'UA-37524215-3'
			}
		},

		_public:
		{
			MjConfig : function()
			{
				this._super();
			}
		}
	})
]);