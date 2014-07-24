/*global Poof */
/*global Package */
/*global Class */

/*global Task */

Package('util',
[
	Class('public abstract Task',
	{
		_public_static:
		{
			EVENT_PROGRESS	: 'Task.Event.Progress',
			EVENT_DONE		: 'Task.Event.Done'
		},

		_public:
		{
			ownWeight		: 0,		// this task sprcific weight
			ownProgress		: 0,		// this task specific progress
			subtasks		: [],

			weight			: 0,		// global weight
			progress		: 0,		// global progress
			done			: false,	// global done

			Task : function(subtasks, ownWeight)
			{
				this.ownWeight = ownWeight ? ownWeight : 0;
				this.subtasks = subtasks ? subtasks : [];

				this.recalculateWeight();
			},

			bindEvents : function()
			{
				for(var i = 0; i < this.subtasks.length; i ++)
				{
					this.subtasks[i].on(Task.EVENT_PROGRESS, Poof.retainContext(this, this.onSubtaskProgress));
					this.subtasks[i].on(Task.EVENT_COMPLETE, Poof.retainContext(this, this.onSubtaskDone));
				}
			},

			unbindEvents : function()
			{
				for(var i = 0; i < this.subtasks.length; i ++)
				{
					this.subtasks[i].off(Task.EVENT_PROGRESS);
					this.subtasks[i].off(Task.EVENT_COMPLETE);
				}
			},

			recalculateWeight : function()
			{
				this.weight = this.ownWeight;

				for(var i = 0; i < this.subtasks.length; i ++)
				{
					this.weight += this.subtasks[i].weight;
				}
			},

			recalculateProgress : function()
			{
				var weightDone = this.ownProgress * this.ownWeight;

				for(var i = 0; i < this.subtasks.length; i ++)
				{
					weightDone += this.subtasks[i].progress * this.subtasks[i].weight;
				}

				this.progress = weightDone / this.weight;
			},

			execute : function()
			{
				this.bindEvents();

				for(var i = 0; i < this.subtasks.length; i ++)
				{
					this.subtasks[i].execute();
				}

				this.run();
			},

			run : function()
			{
				// individual task implementation goes here
			},

			notifyProgress : function(progress)
			{
				this.ownProgress = progress;
				this.recalculateProgress();
				this.dispatch(Task.EVENT_PROGRESS, {progress: this.progress, weight: this.weight});
				
				if(this.progress === 1)
				{
					this.done = true;
					this.unbindEvents();
					this.dispatch(Task.EVENT_DONE, {progress: this.progress, weight: this.weight});
				}
			},

			notifyDone : function()
			{
				this.notifyProgress(1);
			},

			onSubtaskProgress : function(event)
			{
				Poof.suppressUnused(event);
				this.notifyProgress(this.progress);
			},

			onSubtaskDone : function(event)
			{
				Poof.suppressUnused(event);
				this.notifyProgress(this.progress);
			}
		}
	})
]);