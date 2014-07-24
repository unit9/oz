/*global Package */
/*global Class */

Package('mjframe',
[
	Class('public abstract LayoutAnimation',
	{
		_public_static:
		{
			EVENT_IN_COMPLETE	: 'LayoutAnimation.EventInComplete',
			EVENT_OUT_COMPLETE	: 'LayoutAnimation.EventOutComplete',

			DIRECTION_FORWARD	: 'LayoutAnimation.DirectionForward',
			DIRECTION_BACKWARD	: 'LayoutAnimation.DirectionBackward',

			firstTime : true,

			animations : [],	// {target, top, duration, time}

			init : function()
			{
				AnimationController.getInstance().on(AnimationController.EVENT_FRAME, Poof.retainContext(this, LayoutAnimation.update));
			},

			animate : function(target, top, duration, handler)
			{
				for(var i = 0; i < LayoutAnimation.animations.length; i ++)
				{
					if(LayoutAnimation.animations[i].target[0] === target[0])
					{
						LayoutAnimation.animations.splice(i, 1);
						break;
					}
				}
				console.log('animate', target);

				LayoutAnimation.animations.push({target: target, top: top, duration: duration, startTime: new Date().getTime(), handler: handler});
			},

			update : function()
			{
				var animation;
				var currentTop;
				var newTop;
				var distance;
				var currentTime;
				var progress;

				var currentIndex = 0;

				while(currentIndex < LayoutAnimation.animations.length)
				{
					animation = LayoutAnimation.animations[currentIndex];
					if(typeof(animation.currentTime) === 'undefined')
					{
						animation.currentTime = new Date().getTime() - animation.startTime;
					}

					progress = animation.currentTime / animation.duration;
					currentTop = animation.target.css('top').indexOf('%') === -1 ? parseFloat(animation.target.css('top'), 10) / $('#wrapper').height() * 100 : parseFloat(animation.target.css('top'), 10);
					distance = parseFloat(animation.top, 10) - currentTop;
					
					if(animation.currentTime >= animation.duration || Math.abs(distance) <= 1)
					{
						newTop = animation.top;
						if(typeof(animation.handler) === 'function')
						{
							animation.handler();
						}
						console.log('finish');
						LayoutAnimation.animations.splice(currentIndex, 1);
					} else
					{
						newTop = currentTop + distance * progress + (animation.top.indexOf('%') === -1 ? '' : '%');
						++currentIndex;
					}

					// console.log('-- animating ', animation.top, currentTop, animation.currentTime / animation.duration + '%', newTop);

					animation.target.css('top', newTop);
					animation.currentTime = new Date().getTime() - animation.startTime;
				}
			}
		},

		_public:
		{
			LayoutAnimation : function()
			{
			},

			init : function(content, direction)
			{

			},

			playIn : function(content, direction)
			{

			},

			playOut : function(content, direction)
			{

			}
		}
	})
]);