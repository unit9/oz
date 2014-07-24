/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global RotationController */

Package('controller',
[
	Class('public singleton RotationController',
	{
		_public_static:
		{
			EVENT_ROTATION : 'RotationController.Event.Motion',

			GYRO_MULTIPLIER : 8 * Math.PI / 180,
			GYRO_OFFSET_Y : 3
		},

		_public:
		{
			initialised : false,
			running : false,
			startCount : 0,
			lastFrameTime : 0,

			RotationController : function()
			{
			},

			bindEvents : function()
			{
				if(window.DeviceOrientationEvent)
				{
					$(window).bind('deviceorientation.rotationcontroller', Poof.retainContext(this, this.onDeviceOrientation));
				} else if(window.DeviceMotionEvent)
				{
					$(window).bind('devicemotion.rotationcontroller', Poof.retainContext(this, this.onDeviceMotion));
				}
			},

			unbindEvents : function()
			{
				$(window).unbind('deviceorientation.rotationcontroller');
				$(window).unbind('devicemotion.rotationcontroller');
			},

			start : function()
			{
				this.startCount ++;
				if(!this.running)
				{
					console.log('&&& STARTING');
					this.running = true;
					this.bindEvents();
				}
			},

			stop : function()
			{
				if(--this.startCount === 0)
				{
					console.log('&&& STOPPING');
					this.running = false;
					this.unbindEvents();
				}

				if(this.startCount < 0)
				{
					this.startCount = 0;
				}
			},

			applyRotation : function(rotation)
			{
				this.dispatch(RotationController.EVENT_ROTATION, {rotation: rotation});
			},

			onDeviceMotion : function(event)
			{
				var rotation = event.originalEvent.accelerationIncludingGravity;
				this.applyRotation(rotation);
			},

			onDeviceOrientation : function(event)
			{
				var gamma = event.originalEvent.gamma;
				var beta = event.originalEvent.beta;

				if(gamma > 90 || gamma < -90)
				{
					beta = 180 - beta;
					gamma = gamma < 0 ? -(180 + gamma) : -(gamma - 180);
				}

				if(beta > 80 && beta < 100)
				{
					gamma /= 5;
				}
					
				var rotation = {x: gamma * RotationController.GYRO_MULTIPLIER , y: -beta * RotationController.GYRO_MULTIPLIER + RotationController.GYRO_OFFSET_Y, z: 0};
				this.applyRotation(rotation);
			}
		}
	})
]);