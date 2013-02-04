/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global Modernizr */
/*global JourneyToOzScrollController */
/*global Detection */
/*global GestureController */
/*global TweenLite */
/*global Analytics */

Package('controller',
[
	Import('util.TextUtil'),

	Class('public singleton JourneyToOzScrollController',
	{
		_public_static:
		{
			PANNING_SPEED			: 1,

			EVENT_OVERSCROLL_UP		: 'JourneyToOzScrollController.Event.OverscrollUp',
			EVENT_OVERSCROLL_DOWN	: 'JourneyToOzScrollController.Event.OverscrollDown',

			EXPLORE_EVENTS_BY_ID	: ['circus1page_useraction_explore', 'circus2page_useraction_explore', 'circus3page_useraction_explore', 'storm1page_useraction_explore', 'storm2page_useraction_explore']
		},

		_public:
		{
			$container : null,
			$img : null,
			$arrowLeft : null,
			$arrowRight : null,
			$scrollContainer : null,

			enabled : false,
			ready : false,
			journeyId : null,
			exploreEventLogged : false,
			minX : 0,
			maxX : 0,
			startPos : {x: 0, y: 0},
			lastPos : {x: 0, y: 0},
			deltaPos : {x: 0, y: 0},
			destPos : {x: 0, y: 0},
			currentPos : {x: 0, y: 0},
			dragging : false,
			scrollingMode : false,
			scrollContainer : null,

			JourneyToOzScrollController : function()
			{
			},

			init : function($container, $arrowLeft, $arrowRight)
			{
				this.ready = false;
				this.enabled = false;
				this.dragging = false;

				this.$container = $container;
				this.$img = this.$container.find('img');
				this.$arrowLeft = $arrowLeft;
				this.$arrowRight = $arrowRight;

				this.journeyId = parseInt($container.parent().attr('class').match(new RegExp('JourneyToOzPage\\d'))[0].match(new RegExp('\\d'))[0], 10);
				this.exploreEventLogged = false;

				var updateMinX = Poof.retainContext(this, function()
				{
					if(this.$img.width() > 0)
					{
						this.minX = this.$container.width() - this.$img.width();
						this.ready = true;
						this.$container.css('left', 0);
						if(this.scrollContainer && typeof(this.scrollContainer.scrollLeft) !== 'undefined')
						{
							this.scrollContainer.scrollLeft = 0;
						}
					} else
					{
						setTimeout(updateMinX, 10);
					}
				});

				updateMinX();

				this.$arrowLeft.css('opacity', 0);

				this.startPos = {x: 0, y: 0};
				this.lastPos = {x: 0, y: 0};
				this.deltaPos = {x: 0, y: 0};
				this.destPos = {x: 0, y: 0};
				this.currentPos = {x: 0, y: 0};
			},

			enable : function(scroll)
			{
				this.enabled = true;

				if(Detection.getInstance().android)
				{
					this.$scrollContainer = this.$img.parent();
					this.scrollContainer = this.$scrollContainer[0];
					scroll = true;
				}

				if(scroll)
				{
					this.scrollingMode = true;
					this.$scrollContainer.css('overflow-x', 'auto').css('overflow-y', 'hidden');
					this.maxX = this.scrollContainer.scrollWidth - $(window).width();
				}

				$(document).bind(Modernizr.touch ? 'touchstart.journey' : 'mousedown.journey', Poof.retainContext(this, this.onTouchStart));
				$(document).bind(Modernizr.touch ? 'touchend.journey' : 'mouseup.journey', Poof.retainContext(this, this.onTouchEnd));
				$(document).bind(Modernizr.touch ? 'touchmove.journey' : 'mousemove.journey', Poof.retainContext(this, this.onTouchMove));
			},

			disable : function()
			{
				this.enabled = false;
				this.dragging = false;
				$(document).unbind('touchstart.journey');
				$(document).unbind('touchend.journey');
				$(document).unbind('touchmove.journey');
				$(document).unbind('mousedown.journey');
				$(document).unbind('mouseup.journey');
				$(document).unbind('mousemove.journey');
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

				this.containerStartPosition = {x: this.$container.position().left, y: this.$container.position().top};
			},

			registerEndValues : function(event)
			{
				Poof.suppressUnused(event);
			},

			registerMoveValues : function(event)
			{
				var eventData = event.originalEvent;
				event.preventDefault();

				if(eventData.touches)
				{
					this.deltaPos = {x: eventData.touches[0].pageX - this.lastPos.x, y: eventData.touches[0].pageY - this.lastPos.y};
					this.lastPos = {x: eventData.touches[0].pageX, y: eventData.touches[0].pageY};
				} else
				{
					this.deltaPos = {x: eventData.pageX - this.lastPos.x, y: eventData.pageY - this.lastPos.y};
					this.lastPos = {x: eventData.pageX, y: eventData.pageY};
				}
			},

			applyPosition : function()
			{
				if(this.scrollingMode)
				{
					this.currentPos.x -= this.deltaPos.x;

					if(this.currentPos.x < 0)
					{
						this.currentPos.x = 0;
					} else if(this.currentPos.x > this.maxX)
					{
						this.currentPos.x = this.maxX;
					}

					TweenLite.to(this.scrollContainer, 1, {scrollLeft: this.currentPos.x, onUpdate: Poof.retainContext(this, function()
					{
						var leftArrowOpacity = Math.min(this.currentPos.x * 0.01, 1);
						var rightArrowOpacity = Math.min((this.maxX - this.currentPos.x) * 0.01, 1);
						this.$arrowLeft.css('opacity', leftArrowOpacity);
						this.$arrowRight.css('opacity', rightArrowOpacity);
					})});
				} else
				{
					if(this.$container)
					{
						this.destPos.x += this.deltaPos.x * JourneyToOzScrollController.PANNING_SPEED;

						if(this.destPos.x > 0)
						{
							this.destPos.x = 0;
						} else if(this.destPos.x < this.minX)
						{
							this.destPos.x = this.minX;
						}

						TweenLite.to(this.currentPos, 1, {x: this.destPos.x, onUpdate: Poof.retainContext(this, function()
						{
							var leftArrowOpacity = Math.min(0 - this.currentPos.x * 0.01, 1);
							var rightArrowOpacity = Math.min((this.currentPos.x - this.minX) * 0.01, 1);
							this.$arrowLeft.css('opacity', leftArrowOpacity);
							this.$arrowRight.css('opacity', rightArrowOpacity);
							this.$container.css('left', this.currentPos.x);
						})});
					}
				}
			},

			onTouchStart : function(event)
			{
				if(!this.ready)
				{
					return;
				}

				if(this.scrollingMode)
				{
					GestureController.getInstance().onTouchStart(event);
				}
				
				this.registerStartValues(event);
				this.dragging = true;
			},

			onTouchEnd : function(event)
			{
				if(this.scrollingMode)
				{
					GestureController.getInstance().onTouchEnd(event);
				}
				
				this.dragging = false;
				this.registerEndValues(event);
			},

			onTouchMove : function(event)
			{
				if(this.dragging)
				{
					if(!this.exploreEventLogged)
					{
						this.exploreEventLogged = true;
						Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS[JourneyToOzScrollController.EXPLORE_EVENTS_BY_ID[this.journeyId - 1]]);
					}

					if(this.scrollingMode)
					{
						GestureController.getInstance().onTouchMove(event);
					}
					
					this.registerMoveValues(event);
					this.applyPosition();
				}
			}
		}
	})
]);