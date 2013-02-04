/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global TemplatePreFetchTask */
/*global Template */

Package('preloading.task.subtask',
[
	Import('util.Task'),
	Import('mjframe.Template'),

	Class('public TemplatePreFetchTask extends Task',
	{
		_public:
		{
			url : null,

			TemplatePreFetchTask : function(templates, weight)
			{
				if(typeof(templates) === 'string')
				{
					this.url = templates;
					this._super(null, 1);
				} else if(templates && templates.length === 1)
				{
					this.url = templates[0];
					this._super(null, weight);
				} else if(templates)
				{
					var subtasks = [];
					for(var i = 0; i < templates.length; i ++)
					{
						subtasks.push(new TemplatePreFetchTask(templates[i], weight / templates.length));
					}
					this._super(subtasks, 0);
				}
			},

			run : function()
			{
				if(this.url)
				{
					Template.preFetch(this.url, Poof.retainContext(this, this.onTemplateLoadComplete));
				}
			},

			onTemplateLoadComplete : function()
			{
				this.notifyDone();
			}
		}
	})
]);