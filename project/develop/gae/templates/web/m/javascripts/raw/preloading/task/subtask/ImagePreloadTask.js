/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global ImagePreloader */
/*global ImagePreloadTask */

Package('preloading.task.subtask',
[
	Import('util.Task'),
	Import('util.ImagePreloader'),

	Class('public ImagePreloadTask extends Task',
	{
		_public:
		{
			url : null,
			type : null,

			ImagePreloadTask : function(urls, weight)
			{
				if(typeof(weight) === 'undefined')
				{
					this.weight = 1;
				}

				if(typeof(urls) !== 'undefined' && typeof(urls.url) !== 'undefined')
				{
					this.url = urls.url;
					this.type = urls.type;
					this._super(null, 1);
				} else if(urls && urls.length === 1)
				{
					this.url = urls[0].url;
					this.type = urls[0].type;
					this._super(null, 1);
				} else if(urls && urls.length > 1)
				{
					var subtasks = [];
					for(var i = 0; i < urls.length; i ++)
					{
						subtasks.push(new ImagePreloadTask(urls[i], weight / urls.length));
					}
					this._super(subtasks);
				}
			},

			run : function()
			{
				if(this.url)
				{
					ImagePreloader.getInstance().loadUrl(this.url, this.type, Poof.retainContext(this, this.onImageLoadComplete));
				}
			},

			onImageLoadComplete : function()
			{
				this.notifyDone();
			}
		}
	})
]);