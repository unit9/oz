/*global Poof */
/*global Package */
/*global Import */
/*global Class */

Package('mjframe',
[
	Import('mjframe.Copy'),

	Class('public abstract RemoteCopy extends Copy',
	{
		_public:
		{
			loading : false,
			loaded : false,
			queuedHandlers : [],
			currentBackupIndex : 0,
			currentHandler : null,

			getRemoteJsonUrls : function()
			{
				return null;
			},

			load : function(handler)
			{
				if(this.loaded)
				{
					console.log('++ [cache] RemoteCopy');
					return handler(this._class._classInfo);
				} else if(this.loading)
				{
					this.queuedHandlers.push(handler);
				} else
				{
					this.loading = true;
					this.queuedHandlers.push(handler);
					var urls = this.getRemoteJsonUrls();
					if(urls && urls.length > this.currentBackupIndex)
					{
						this.currentHandler = handler;
						console.log('-- [load] RemoteCopy', urls[this.currentBackupIndex]);
						$.get(urls[this.currentBackupIndex ++], Poof.retainContext(this._this, this.onLoaded)).error(Poof.retainContext(this, this.onLoadError));
					}
				}
			},

			onLoaded : function(data)
			{
				this.loaded = true;
				this.loading = false;
				this.parseRemoteJson(data);
				for(var i = 0; i < this.queuedHandlers.length; i ++)
				{
					this.queuedHandlers[i](this._class._classInfo);
				}
				this.queuedHandlers = [];
			},

			onLoadError : function()
			{
				this.loading = false;
				this.load(this.currentHandler);
			},

			parseRemoteJson : function(data)
			{
				var copyObject;
				try
				{
					copyObject = JSON.parse(data);
				} catch(e) {}

				if(copyObject && copyObject.strings)
				{
					for(var name in copyObject.strings)
					{
						this[name] = copyObject.strings[name];
					}
				}
			}
		}
	})
]);
