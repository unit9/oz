/*global Poof */
/*global Package */
/*global Class */

/*global CutoutOverlayController */
/*global CutoutControls */
/*global Modernizr */
/*global TweenLite */
/*global Power3 */
/*global Detection */
/*global Analytics */

Package('controller',
[
	Class('public singleton CutoutOverlayController',
	{
		_public_static:
		{
			EVENT_OVERSCROLL_UP			: 'CutoutOverlayController.Event.OverscrollUp',
			EVENT_OVERSCROLL_DOWN		: 'CutoutOverlayController.Event.OverscrollDown',

			SCROLLING_SPEED				: 1,
			MIN_DRAG_DISTANCE_TO_CHANGE	: 40,			// pixels
			SNAP_TO_AXIS				: true,
			OVERSCROLL_ENABLED			: false,
			OVERSCROLL_LENGTH			: 40,			// pixels
			OVERLAY_ASPECT_RATIO		: 660 / 960,
			MIN_MOVE_DELAY				: 0
		},

		_public:
		{
			$overlaysContainer : null,
			$overlays : null,
			$selectedOverlay : null,
			
			enabled : false,
			selectedOverlayIndex : 0,
			dragging : false,
			contentStartX : -1,
			dragStartX : -1,
			dragStartY : -1,
			lastTouchX : -1,
			lastTouchY : -1,
			overlayTween : null,
			overlaysTweenProperties : {marginLeft: 0, marginTop: 0},
			tweenInProgress : false,
			lastMoveTime : -1,

			CutoutOverlayController : function()
			{
			},

			initFromContainer : function($container)
			{
				this.$overlaysContainer = $container;
				this.$overlays= $container.find('.overlay');

				this.initOverlayPositions();
				this.bindEvents();
			},

			initOverlayPositions : function()
			{
				this.snapToIndex(this.selectedOverlayIndex, true);
			},

			bindEvents : function()
			{
				this.$overlaysContainer.bind(Modernizr.touch ? 'touchstart' : 'mousedown', Poof.retainContext(this, this.onOverlaysTouchDown));
				$(window).bind(Modernizr.touch ? 'touchend' : 'mouseup', Poof.retainContext(this, this.onOverlaysTouchUp));
				$(window).bind(Modernizr.touch ? 'touchmove' : 'mousemove', Poof.retainContext(this, this.onOverlaysTouchMove));
			},

			enable : function()
			{
				this.enabled = true;
			},

			disable : function()
			{
				this.enabled = false;
			},

			getSelectedId : function()
			{
				return this.selectedOverlayIndex + 1;
			},

			getOverlaySize : function()
			{
				var windowAspectRatio = $('#wrapper').width() / $('#wrapper').height();
				var width;
				var height;

				if(windowAspectRatio > CutoutOverlayController.OVERLAY_ASPECT_RATIO)
				{
					width = $('#wrapper').width();
					height = width / CutoutOverlayController.OVERLAY_ASPECT_RATIO;
				} else
				{
					height = $('#wrapper').height();
					width = height * CutoutOverlayController.OVERLAY_ASPECT_RATIO;
				}

				return {width: width, height: height};
			},

			canInteract : function()
			{
				return this.enabled;
			},

			goToNext : function()
			{
				if(this.selectedOverlayIndex < this.$overlays.length - 1)
				{
					this.snapToIndex(this.selectedOverlayIndex + 1);
				}
			},

			goToPrevious : function()
			{
				if(this.selectedOverlayIndex > 0)
				{
					this.snapToIndex(this.selectedOverlayIndex - 1);
				}
			},

			snap : function()
			{
				var left = -parseInt(this.$overlaysContainer.css('margin-left'), 10) - (this.$selectedOverlay.width() * (this.selectedOverlayIndex + 1));

				if(left > CutoutOverlayController.MIN_DRAG_DISTANCE_TO_CHANGE && this.selectedOverlayIndex < this.$overlays.length - 1)
				{
					this.snapToIndex(this.selectedOverlayIndex + 1);
					Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.cutoutpage_useraction_changecutout);
				} else if(left < -CutoutOverlayController.MIN_DRAG_DISTANCE_TO_CHANGE && this.selectedOverlayIndex > 0)
				{
					this.snapToIndex(this.selectedOverlayIndex - 1);
					Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.cutoutpage_useraction_changecutout);
				} else
				{
					this.snapToIndex(this.selectedOverlayIndex);
				}
			},

			snapToIndex : function(index, immediate)
			{
				var $newSelectedOverlay = $(this.$overlays[index]);
				this.overlaysTweenProperties.marginLeft = parseInt(this.$overlaysContainer.css('margin-left'), 10);
				this.overlaysTweenProperties.marginTop = parseInt(this.$overlaysContainer.css('margin-top'), 10);

				if(this.overlayTween)
				{
					this.overlayTween.kill();
				}

				if(immediate === true)
				{
					this.overlaysTweenProperties = {marginLeft: -$newSelectedOverlay.position().left, marginTop: 0};
					this.onOverlaysTweenUpdate();
				} else
				{
					this.tweenInProgress = true;
					this.overlayTween = TweenLite.to(this.overlaysTweenProperties, 0.6, {marginLeft: -$newSelectedOverlay.position().left, marginTop: 0, ease: Power3.easeOut, onUpdate: Poof.retainContext(this, this.onOverlaysTweenUpdate), onComplete : Poof.retainContext(this, this.onOverlaysTweenComplete)});
				}

				this.selectOverlayIndex(index);
			},

			selectOverlayIndex : function(index)
			{
				this.selectedOverlayIndex = index;
				this.$selectedOverlay = $(this.$overlays[index]);
				CutoutControls.getInstance().setCurrentIndex(index);
			},

			onOverlaysTouchDown : function(event)
			{
				if(!this.dragging && this.canInteract())
				{
					this.dragging = true;
					
					var pageX = event.originalEvent.touches ? event.originalEvent.touches[0].pageX : event.originalEvent.pageX;
					var pageY = event.originalEvent.touches ? event.originalEvent.touches[0].pageY : event.originalEvent.pageY;
					this.contentStartX = parseInt(this.$overlaysContainer.css('margin-left'), 10);
					this.dragStartX = this.lastTouchX = pageX;
					this.dragStartY = this.lastTouchY = pageY;
					
					if(this.overlayTween)
					{
						this.overlayTween.kill();
					}

					this.lastMoveTime = new Date().getTime() - CutoutOverlayController.MIN_MOVE_DELAY;
				}

				return true;
			},

			onOverlaysTouchUp : function(event)
			{
				Poof.suppressUnused(event);

				if(this.dragging && this.canInteract())
				{
					this.dragging = false;
					this.snap();
				}

				return true;
			},

			onOverlaysTouchMove : function(event)
			{
				if(Detection.getInstance().android)
				{
					if(!this.dragging)
					{
						this.onOverlaysTouchDown(event);
					}

					event.originalEvent.preventDefault();
				}

				if(this.dragging && this.canInteract())
				{
					if(Detection.getInstance().android || true)
					{
						if(new Date().getTime() - this.lastMoveTime < CutoutOverlayController.MIN_MOVE_DELAY)
						{
							return;
						}

						this.lastMoveTime = new Date().getTime();
					}

					var pageX = event.originalEvent.touches ? event.originalEvent.touches[0].pageX : event.originalEvent.pageX;
					var pageY = event.originalEvent.touches ? event.originalEvent.touches[0].pageY : event.originalEvent.pageY;
					var globalDistX = pageX - this.dragStartX;
					var globalDistY = pageY - this.dragStartY;

					if(Math.abs(globalDistX) > Math.abs(globalDistY))
					{
						var deltaX = (pageX - this.dragStartX) * CutoutOverlayController.SCROLLING_SPEED;
						var newX = this.contentStartX + deltaX;

						this.$overlaysContainer.css('margin-left', newX);
						
						this.lastTouchX = pageX;
						this.lastTouchY = 0;
					}
				}

				return true;
			},

			onOverlaysTweenUpdate : function()
			{
				this.$overlaysContainer.css('margin-left', this.overlaysTweenProperties.marginLeft);
				this.$overlaysContainer.css('margin-top', this.overlaysTweenProperties.marginTop);
			},

			onOverlaysTweenComplete : function()
			{
				this.tweenInProgress = false;
			}
		}
	})
]);