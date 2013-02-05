/*global Package */
/*global Class */

/*global Detection */

Package('util',
[
	Class('public singleton Detection',
	{
		_public_static:
		{
			DETECTION_PROPERTIES : ['mobile', 'tablet', 'retina', 'iPhone', 'iPod', 'iPad', 'iOS', 'android', 'chrome', 'safari'],
			LOCALE_NAME_FIX : {
				ko_kr : 'ko',
				nb_no : 'no',
				da_dk : 'da',
				ja_jp : 'ja',
				sv_se : 'sv',
				vi_vn : 'vi',
				el_gr : 'el',
				cs_cz : 'cs',
				ca_es : 'ca',
				uk_ua : 'uk'
			}
		},

		_public:
		{
			mobile : false,
			tablet : false,
			retina : false,
			iPhone : false,
			iPod : false,
			iPad : false,
			iOS : false,
			iOSVersion : 0,
			iOSVersionSecondary : 0,
			android : false,
			androidVersion : 0,
			androidVersionSecondary : 0,
			chrome : false,
			safari : false,
			language : null,
			spriteUrls : [],

			detect : function()
			{
				this.tablet = $('.detection.tablet').is(':visible');
				this.mobile = !this.tablet;
				this.retina = $('.detection.retina').is(':visible');

				this.iPhone = navigator.userAgent.match(/iPhone/i) !== null;
				this.iPod = navigator.userAgent.match(/iPod/i) !== null;
				this.iPad = navigator.userAgent.match(/iPad/i) !== null;

				this.iOS = this.iPhone || this.iPod || this.iPad;
				this.android = navigator.userAgent.match(/Android/i) !== null;

				if(this.iOS)
				{
					var iOSVersion = navigator.userAgent.match(/OS \d_\d/i);
					if(iOSVersion)
					{
						this.iOSVersion = parseInt(iOSVersion[0].substring(3, 4), 10);
						this.iOSVersionSecondary = parseInt(iOSVersion[0].substring(5, 6), 10);
					}
				} else if(this.android)
				{
					var androidVersion = navigator.userAgent.match(/Android \d\.\d\.\d/i);
					if(androidVersion)
					{
						this.androidVersion = parseInt(androidVersion[0].substring(8, 9), 10);
						this.androidVersionSecondary = parseInt(androidVersion[0].substring(10, 11), 10);
					}
				}
				
				this.chrome = navigator.userAgent.match(/CriOS/i) !== null || navigator.userAgent.match(/Chrome/i) !== null;
				this.safari = navigator.userAgent.match(/Safari/i) !== null && !this.chrome;

				this.language = (navigator.language || navigator.userLanguage).toLowerCase();
				console.log('### LANGUAGE 0: ', this.language);

				var languageComponents = this.language.split('-');
				if(languageComponents.length === 2 && languageComponents[0] === languageComponents[1] && this.language !== 'pt-pt')
				{
					this.language = languageComponents[0];
				}

				var replacementKey = this.language.replace('-', '_');
				if(typeof(Detection.LOCALE_NAME_FIX[replacementKey]) === 'string')
				{
					this.language = Detection.LOCALE_NAME_FIX[replacementKey];
				}

				console.log('### LANGUAGE: ', this.language);

				var detection = this;
				if('getMatchedCSSRules' in window)
				{
					$('.sprite-url').each(function()
					{
						/**
						 * To prevent loading of the sprite image, the CSS detection rules overwrite the background-image rule
						 * with background-image: none; as a last-matching rule. So we can't just read .css('background-image')
						 * as this would return the last-matching rule (background-image: none). Instead, we're reading
						 * the last but one matching rule, which is the true background image URL.
						 */
						var fullCssRulesSet = window.getMatchedCSSRules($(this)[0]);
						if(fullCssRulesSet)
						{
							var urlRule = fullCssRulesSet[fullCssRulesSet.length - 2];
							var url = urlRule.style.backgroundImage;
							detection.spriteUrls.push(url.substring(4, url.length - 1));
						}
					});
				}

				this.addClasses();
			},

			addClasses : function()
			{
				var $html = $('html');

				for(var i = 0; i < Detection.DETECTION_PROPERTIES.length; i ++)
				{
					$html.addClass(this[Detection.DETECTION_PROPERTIES[i]] ? Detection.DETECTION_PROPERTIES[i] : '');
				}

				$html.addClass(this.iOS ? ('iOSVersion' + this.iOSVersion) : '');
				$html.addClass(this.iOS ? ('iOSVersionSecondary' + this.iOSVersionSecondary) : '');
				$html.addClass(this.android ? ('androidVersion' + this.androidVersion) : '');
				$html.addClass(this.android ? ('androidVersionSecondary' + this.androidVersionSecondary) : '');

				$html.addClass('lang-' + this.language);
			}
		}
	})
]);