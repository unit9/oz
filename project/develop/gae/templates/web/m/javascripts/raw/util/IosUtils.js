/*global Poof */
/*global Package */
/*global Class */

/*global IosUtils */
/*global Detection */

Package('util',
[
	Class('public singleton IosUtils',
	{
		_public_static:
		{
			ADDRESS_BAR_HEIGHT : 60
		},

		_public:
		{
			preventElasticScrollingUp : false,
			preventElasticScrollingDown : false,
			touchStartPageY : null,

			IosUtils : function()
			{
				this.bindEvents();
			},

			bindEvents : function()
			{
				$(window).bind('orientationchange', Poof.retainContext(this, this.onOrientationChange));
				$(document).bind('touchstart', Poof.retainContext(this, this.onTouchStart));
				$(document).bind('touchmove', Poof.retainContext(this, this.onTouchMove));
			},

			hideAddressBar : function()
			{
				if(Detection.getInstance().iPhone && Detection.getInstance().safari)
				{
					$('#wrapper').height($(window).height() + IosUtils.ADDRESS_BAR_HEIGHT);
					window.scrollTo(0, 1);
				} else
				{
					$('#wrapper').height($(window).height());
				}
			},

			onOrientationChange : function(event)
			{
				Poof.suppressUnused(event);
				this.hideAddressBar();
			},

			onTouchStart : function(event)
			{
				this.touchStartPageY = event.originalEvent.pageY;
			},

			onTouchMove : function(event)
			{
				var delta = event.originalEvent.pageY - this.touchStartPageY;

				if((delta < 0 && this.preventElasticScrollingDown) || (delta > 0 && this.preventElasticScrollingUp))
				{
					event.preventDefault();
				}

				this.touchStartPageY = event.originalEvent.pageY;
			},

			/* Image */
			isImageSubsampled : function(img)
			{
				var iw = img.naturalWidth, ih = img.naturalHeight;
				if (iw * ih > 1048576)
				{
					var canvas = document.createElement('canvas');
					canvas.width = canvas.height = 1;
					var ctx = canvas.getContext('2d');
					ctx.drawImage(img, -iw + 1, 0);
					return ctx.getImageData(0, 0, 1, 1).data[3] === 0;
				}
				
				return false;
			},

			getImageVerticalSquash : function(img, iw, ih)
			{
				var canvas = document.createElement('canvas');
				canvas.width = 1;
				canvas.height = ih;
				var ctx = canvas.getContext('2d');
				ctx.drawImage(img, 0, 0);
				var data = ctx.getImageData(0, 0, 1, ih).data;
				// search image edge pixel position in case it is squashed vertically.
				var sy = 0;
				var ey = ih;
				var py = ih;
				while (py > sy)
				{
					var alpha = data[(py - 1) * 4 + 3];
					if (alpha === 0)
					{
						ey = py;
					} else
					{
						sy = py;
					}
					py = (ey + sy) >> 1;
				}
				return py / ih;
			}
		}
	})
]);