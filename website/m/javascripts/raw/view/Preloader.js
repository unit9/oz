/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global console */
/*global OverlayController */

Package('view',
[
	Import('mjframe.View'),
	Import('controller.OverlayController'),

	Class('public singleton Preloader extends View',
	{
		_public_static:
		{
			SPINNER_ROTATION_SPEED : 1.5 // full turns per second
		},

		_public:
		{
			$spinner : null,
			$progress : null,

			spinnerRotation : 0,
			lastFrameTime : 0,

			Preloader : function()
			{
				this._super();
				this.init('preloader', 'view.PreloaderView', 'Preloader');
			},

			onReady : function()
			{
				this.$el.css('display', '');
				OverlayController.getInstance().showPreloaderOverlay();
			},

			compile : function()
			{
				this._super();

				this.$spinner = $('.spinnerContainer');
				this.$progress = $('.preloaderContainer .text');
			},

			show : function(direction)
			{
				this.$container.fadeIn();
				this.startAnimation();
			},

			hide : function(direction)
			{
				this.stopAnimation();
				this.$container.fadeOut();
			},

			startAnimation : function()
			{
				AnimationController.getInstance().on(AnimationController.EVENT_FRAME, Poof.retainContext(this, this.onFrame));
			},

			stopAnimation : function()
			{
				AnimationController.getInstance().off(AnimationController.EVENT_FRAME);
			},

			setProgress : function(progress)
			{
				if(this.$progress)
				{
					this.$progress.text(Math.round(progress).toString());
				}
			},

			onFrame : function(event)
			{
				if(this.$spinner)
				{
					this.$spinner.rotate((this.spinnerRotation += (event.data.deltaTime * Preloader.SPINNER_ROTATION_SPEED * 360 / 1000)));
				}
			}
		}
	})
]);