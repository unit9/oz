/*global Package */
/*global Import */
/*global Class */
/*global ClassUtils */

Package('mjframe',
[
	Class('public Stylesheet',
	{
		_public_static:
		{
			baseImportPath : '',
			fileNameSuffix : '.css',

			load : function(url, handler, media)
			{
				var stylesheetUrl = url.replace('.', '/');
				while(stylesheetUrl.indexOf('.') !== -1)
				{
					stylesheetUrl = stylesheetUrl.replace('.', '/');
				}
				stylesheetUrl = this.baseImportPath + stylesheetUrl + this.fileNameSuffix;
				var stylesheetName = url.indexOf('.') === -1 ? url : url.substring(url.lastIndexOf('.') + 1, url.length);

				var head = document.getElementsByTagName('head')[0];
				var link = document.createElement('link');
				link.rel  = 'stylesheet';
				link.type = 'text/css';
				link.href = stylesheetUrl;
				link.media = (typeof(media) === 'undefined' || media === null) ? 'all' : media;

				head.appendChild(link);

				var checkLoaded = function()
				{
					var loaded = false;

					try
					{
						if('sheet' in link && 'cssRules' in link.sheet)
						{
							if(link.sheet.cssRules.length > 0)
							{
								loaded = true;
							}
						}
					} catch(e)
					{
					}

					try
					{
						if('styleSheet' in link && 'cssText' in link.styleSheet)
						{
							if(link.styleSheet.cssText.length > 0)
							{
								loaded = true;
							}
						}
					} catch(e)
					{
					}

					try
					{
						if('innerHTML' in link)
						{
							if(link.innerHTML.length > 0)
							{
								loaded = true;
							}
						}
					} catch(e)
					{
					}

					if(loaded)
					{
						if(typeof(handler) !== 'undefined' && handler !== null)
						{
							handler(stylesheetName);
						}
					} else
					{
						setTimeout(checkLoaded, 100);
					}
				};

				checkLoaded();
			}
		}
	})
]);