/*global Package */
/*global Class */

/*global ImagePreloader */

Package('util',
[
	Class('public singleton ImagePreloader',
	{
		_public_static:
		{
			TYPE_IMG : 'img',
			TYPE_BACKGROUND : 'background'
		},

		_public:
		{
			cache : {},
			$preloadContainer : null,

			ImagePreloader : function()
			{
				this.$preloadContainer = $('#preloader');
			},

			loadUrl : function(url, type, completeHandler)
			{
				if(type === ImagePreloader.TYPE_BACKGROUND)
				{
					var $bg = $('<div>').hide().css('background-image', 'url(' + url + ')');
					this.$preloadContainer.append($bg);
				} else
				{
					var $img= $('<img />').attr('src', url).hide();
					this.$preloadContainer.append($img);
				}

				console.log('-- [image] ' + url);

				var image = new Image();
				this.cache[this.generateKey(url)] = image;
				image.onload = completeHandler;
				image.src = url;
			},

			generateKey : function(url)
			{
				return encodeURIComponent(url);
			},

			getCached : function(url)
			{
				return this.cache[this.generateKey(url)];
			}
		}
	})
]);