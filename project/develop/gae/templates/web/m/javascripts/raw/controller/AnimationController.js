/*global Poof */
/*global Package */
/*global Load */
/*global Import */
/*global Class */

/*global console */

/*global AnimationController */

Package('controller',
[
	Class('public singleton AnimationController',
	{
		_public_static:
		{
			EVENT_FRAME : 'AnimationController.Event.Frame'
		},

		_public:
		{
			initialised : false,
			running : false,
			lastFrameTime : 0,

			AnimationController : function()
			{
				this.init();
			},

			init : function()
			{
				if(this.initialised)
				{
					return;
				}

				this.initAnimationFrame();
			},

			initAnimationFrame : function()
			{
				window.requestAnimationFrameProxy = (function()
				{
					return  window.requestAnimationFrame	||
					window.webkitRequestAnimationFrame		||
					window.mozRequestAnimationFrame			||
					window.oRequestAnimationFrame			||
					window.msRequestAnimationFrame			||
					function(callback)
					{
						window.setTimeout(callback, 1000 / 60);
					};
				})();
			},

			start : function()
			{
				this.running = true;
				window.requestAnimationFrameProxy(Poof.retainContext(this, this.onFrame));
			},

			stop : function()
			{
				this.running = false;
				this.lastFrameTime = 0;
			},

			onFrame : function()
			{
				if(this.running)
				{
					this.dispatch(AnimationController.EVENT_FRAME, {deltaTime: this.lastFrameTime === 0 ? 0 : (new Date().getTime() - this.lastFrameTime)});
					window.requestAnimationFrameProxy(Poof.retainContext(this, this.onFrame));
					this.lastFrameTime = new Date().getTime();
				}
			}
		}
	})
]);