/*global Poof */
/*global Package */
/*global Class */

/*global Template */

Package('mjframe',
[
	Class('public Template',
	{
		_public_static:
		{
			baseImportPath : '',
			fileNameSuffix : '.html',
			cache : {},

			preFetch : function(url, completeHandler)
			{
				var url = Template.resolveUrl(url);

				$.get(url, Poof.retainContext(this, Poof.retainContext(this, function(data)
				{
					this.onTemplateLoadComplete(url, data);
					completeHandler(data);
				})));
			},

			resolveUrl : function(name)
			{
				var templateUrl = name.replace('.', '/');
				while(templateUrl.indexOf('.') !== -1)
				{
					templateUrl = templateUrl.replace('.', '/');
				}
				return this.baseImportPath + templateUrl + this.fileNameSuffix;
			},

			generateKey : function(url)
			{
				return encodeURIComponent(url);
			},

			load : function(url, targetDiv, handler, async)
			{
				if(typeof(async) === 'undefined')
				{
					async = true;
				}

				var targetDivObject = typeof(targetDiv) === 'string' ? document.getElementById(targetDiv) : targetDiv;
				if(!targetDivObject)
				{
					window.console.warn('cannot find targetDivObject (Template.js). Possible error');
					return;
				}

				var templateName = url.indexOf('.') === -1 ? url : url.substring(url.lastIndexOf('.') + 1, url.length);
				var templateUrl = Template.resolveUrl(url);

				var onDone = function(templateHtml)
				{
					targetDivObject.innerHTML = templateHtml;
					targetDivObject.setAttribute("class", 'template ' + templateName); //For Most Browsers
					targetDivObject.setAttribute("className", 'template ' + templateName); //For IE; harmless to other browsers.

					if(typeof(handler) !== 'undefined')
					{
						handler(templateName);
					}
				};

				var cacheKey = this.generateKey(templateUrl);
				if(typeof(this.cache[cacheKey]) !== 'undefined')
				{
					console.log('++ [cache] ' + url);
					return onDone(this.cache[cacheKey]);
				}

				console.log('-- [load] ', templateUrl);
				$.get(templateUrl, Poof.retainContext(this, onDone));

				return true;
			},

			onTemplateLoadComplete : function(url, data)
			{
				this.cache[this.generateKey(url)] = data;
			}
		}
	})
]);