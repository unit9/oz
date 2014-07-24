/*global Package */
/*global Import */
/*global Class */

/*global OzMobileRemoteCopy */

Package('preloading.task.subtask',
[
	Import('util.Task'),
	Import('copy.OzMobileRemoteCopy'),

	Class('public RemoteCopyPreloadTask extends Task',
	{
		_public:
		{
			RemoteCopyPreloadTask : function()
			{
				this._super(null, 1);
			},

			run : function()
			{
				OzMobileRemoteCopy.getInstance().load(Poof.retainContext(this, this.onRemoteCopyLoadComplete));
			},

			onRemoteCopyLoadComplete : function()
			{
				this.notifyDone();
			}
		}
	})
]);