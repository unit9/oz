/*global Poof */
/*global Package */
/*global Class */

/*global Detection */
/*global MobileUtils */

Package('util',
[
	Class('public singleton MobileUtils',
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

			MobileUtils : function()
			{
				this.bindEvents();
			},

			bindEvents : function()
			{
				$(window).bind('orientationchange', Poof.retainContext(this, this.onOrientationChange));
				$(window).bind('resize', Poof.retainContext(this, this.onResize));
				$(document).bind('touchstart', Poof.retainContext(this, this.onTouchStart));
				$(document).bind('touchmove', Poof.retainContext(this, this.onTouchMove));
			},

			hideAddressBar : function()
			{
				if(Detection.getInstance().iPhone && Detection.getInstance().safari && false)	// currently it doesn't seem to work in the latest Safari anymore. Disabling for now, will look into that in more detail later
				{
					$('#wrapper').height($(window).height() + MobileUtils.ADDRESS_BAR_HEIGHT);
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

			onResize : function(event)
			{
				Poof.suppressUnused(event);
				this.hideAddressBar();
			},

			onTouchStart : function(event)
			{
				this.touchStartPageY = event.originalEvent.touches ? event.originalEvent.touches[0].pageY : event.originalEvent.pageY;
			},

			onTouchMove : function(event)
			{
				var pageY = event.originalEvent.touches ? event.originalEvent.touches[0].pageY : event.originalEvent.pageY;
				var delta = pageY - this.touchStartPageY;

				if((delta < 0 && this.preventElasticScrollingDown) || (delta > 0 && this.preventElasticScrollingUp))
				{
					event.preventDefault();
				}

				this.touchStartPageY = pageY;
			}
		}
	})
]);