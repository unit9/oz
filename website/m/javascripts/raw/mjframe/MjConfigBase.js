/*global Package */
/*global Class */

Package('mjframe',
[
	Class('public MjConfigBase',
	{
		/**
		 * Template
		 *
		_public_static:
		{
			configLocal:
			{
				debug: true,

				pages:
				[
					{className: 'page.YourClassName', url: '/some/url'},
					{className: 'page.YourOtherClassName', url: '^/regexp/url([/][\\d]*)?$', useRegExp: true},
					{className: 'popup.YourPopup', url: '/popuppage', popup: true, pageUrl: '/'}
				]
			},

			configProd:
			{
				debug: false,

				pages:
				[

				]
			},

			configDefault:
			{
				debug: false,

				pages:
				[

				]
			}
		},
		*/

		_public:
		{
			MjConfigBase : function()
			{
				var commonConfig = this._class.configCommon;
				var envConfig = this.getEnvConfig();
				var name;
				
				if(envConfig)
				{
					for(name in commonConfig)
					{
						this[name] = commonConfig[name];
					}

					for(name in envConfig)
					{
						this[name] = envConfig[name];
					}
				}
			},

			getEnvConfig : function()
			{
				var configDeterminant = window.location.host;

				if('map' in this._class)
				{
					for(var name in this._class.map)
					{
						for(var i = 0; i < this._class.map[name].length; i ++)
						{
							if(new RegExp(this._class.map[name][i]).test(configDeterminant))
							{
								return this._class[name];
							}
						}
					}
				}

				return null;
			}
		}
	})
]);