/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global GestureController */
/*global Modernizr */
/*global Detection */

Package('controller',
[
	Import('util.TextUtil'),

	Class('public singleton GestureController',
	{
		_public_static:
		{
			EVENT_SWIPE_UP		: 'GestureController.Event.SwipeUp',
			EVENT_SWIPE_DOWN	: 'GestureController.Event.SwipeDown',

			MIN_SWIPE_LENGTH	: 40
		},

		_public:
		{
			enabled : false,
			startPos : {x: 0, y: 0},
			lastPos : {x: 0, y: 0},
			deltaPos : {x: 0, y: 0},
			absoluteDeltaPos : {x: 0, y: 0},
			dragging : false,

			GestureController : function()
			{
			},

			enable : function()
			{
				this.enabled = true;
				$(document).bind(Modernizr.touch ? 'touchstart.gesturecontroller' : 'mousedown.gesturecontroller', Poof.retainContext(this, this.onTouchStart));
				$(document).bind(Modernizr.touch ? 'touchend.gesturecontroller' : 'mouseup.gesturecontroller', Poof.retainContext(this, this.onTouchEnd));
				$(document).bind(Modernizr.touch ? 'touchmove.gesturecontroller' : 'mousemove.gesturecontroller', Poof.retainContext(this, this.onTouchMove));
			},

			disable : function()
			{
				this.enabled = false;
				$(document).unbind('touchstart.gesturecontroller');
				$(document).unbind('touchend.gesturecontroller');
				$(document).unbind('touchmove.gesturecontroller');
				$(document).unbind('mousedown.gesturecontroller');
				$(document).unbind('mouseup.gesturecontroller');
				$(document).unbind('mousemove.gesturecontroller');
			},

			registerStartValues : function(event)
			{
				var eventData = event.originalEvent;

				if(eventData.touches)
				{
					this.startPos = {x: eventData.touches[0].pageX, y: eventData.touches[0].pageY};
				} else
				{
					this.startPos = {x: eventData.pageX, y: eventData.pageY};
				}

				this.lastPos = {x: this.startPos.x, y: this.lastPos.y};
				this.absoluteDeltaPos = {x: 0, y: 0};
			},

			registerEndValues : function(event)
			{
				Poof.suppressUnused(event);
			},

			registerMoveValues : function(event)
			{
				var eventData = event.originalEvent;

				if(eventData.touches)
				{
					this.deltaPos = {x: eventData.touches[0].pageX - this.lastPos.x, y: eventData.touches[0].pageY - this.lastPos.y};
					this.absoluteDeltaPos = {x: eventData.touches[0].pageX - this.startPos.x, y: eventData.touches[0].pageY - this.startPos.y};
					this.lastPos = {x: eventData.touches[0].pageX, y: eventData.touches[0].pageY};
				} else
				{
					this.deltaPos = {x: eventData.pageX - this.lastPos.x, y: eventData.pageY - this.lastPos.y};
					this.absoluteDeltaPos = {x: eventData.pageX - this.startPos.x, y: eventData.pageY - this.startPos.y};
					this.lastPos = {x: eventData.pageX, y: eventData.pageY};
				}
			},

			onTouchStart : function(event)
			{
				this.registerStartValues(event);
				this.dragging = true;
			},

			onTouchEnd : function(event)
			{
				this.dragging = false;
				if(event)
				{
					this.registerEndValues(event);

					if(Math.abs(this.absoluteDeltaPos.y) > Math.abs(this.absoluteDeltaPos.x))
					{
						var dispatchEvent = null;

						if(this.absoluteDeltaPos.y > GestureController.MIN_SWIPE_LENGTH)
						{
							dispatchEvent = GestureController.EVENT_SWIPE_DOWN;
						} else if(this.absoluteDeltaPos.y < -GestureController.MIN_SWIPE_LENGTH)
						{
							dispatchEvent = GestureController.EVENT_SWIPE_UP;
						}

						if(dispatchEvent)
						{
							event.preventDefault();
							this.onGestureRecognised();
							this.dispatch(dispatchEvent);
						}
					}
				}
			},

			onTouchMove : function(event)
			{
				if(Detection.getInstance().android)
				{
					if(!this.dragging)
					{
						this.onTouchStart(event);
					}

					event.originalEvent.preventDefault();
				}

				if(this.dragging)
				{
					this.registerMoveValues(event);
				}
			},

			onGestureRecognised : function()
			{
				this.onTouchEnd(null);
			}
		}
	})
]);