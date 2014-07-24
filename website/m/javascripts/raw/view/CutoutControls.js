/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global CutoutOverlayController */

Package('view',
[
	Import('mjframe.View'),

	Class('public singleton CutoutControls extends View',
	{
		_public_static:
		{
			BLICK_NAVIGATION_ON_ENTRY : true
		},

		_public:
		{
			$cutoutNavigation : null,
			$markersHorizontal : null,
			$arrowLeft : null,
			$arrowRight : null,
			currentIndex : -1,
			isOz : false,
			firstTime : true,
			fadeOutTimeoutId : -1,

			CutoutControls : function()
			{
				this._super();
				this.init('cutoutControls', 'view.CutoutControls', 'CutoutControls');
			},

			compile : function()
			{
				this._super();
				this.$cutoutNavigation = $('#cutoutNavigation');
				this.$markersHorizontal = this.$el.find('nav ul.horizontal li');
				this.$arrowLeft = this.$el.find('.arrow-left');
				this.$arrowRight = this.$el.find('.arrow-right');
			},

			bindEvents : function()
			{
				this._super();

				this.$arrowLeft.bind('click', Poof.retainContext(this, this.onLeftArrowClick));
				this.$arrowRight.bind('click', Poof.retainContext(this, this.onRightArrowClick));
			},

			onReady : function()
			{
				this._super();

				this.setCurrentIndex(this.currentIndex === -1 ? 0 : this.currentIndex);
			},

			show : function(direction)
			{
				Poof.suppressUnused(direction);
				this.$el.fadeIn();
			},

			hide : function(direction)
			{
				Poof.suppressUnused(direction);
				this.$el.fadeOut();
			},

			setCurrentIndex : function(index)
			{
				if(!this.$markersHorizontal)
				{
					return;
				}

				if(index !== this.currentIndex)
				{
					this.blinkMarkers();
				}

				this.currentIndex = index;

				this.$markersHorizontal.removeClass('selected');
				$(this.$markersHorizontal[index]).addClass('selected');

				if(index === 0)
				{
					this.$arrowLeft.fadeOut();
				} else
				{
					this.$arrowLeft.fadeIn();
				}

				if(index === this.$markersHorizontal.length - 1)
				{
					this.$arrowRight.fadeOut();
				} else
				{
					this.$arrowRight.fadeIn();
				}
			},

			blinkMarkers : function()
			{
				if(this.$cutoutNavigation)
				{
					var fadeInTime = 1000 - parseInt(this.$cutoutNavigation.css('opacity'), 10) * 1000;
					clearTimeout(this.fadeOutTimeoutId);
					this.$cutoutNavigation.fadeIn(fadeInTime);
					this.fadeOutTimeoutId = setTimeout(Poof.retainContext(this, function()
					{
						this.$cutoutNavigation.fadeOut();
					}), fadeInTime + 1500);

					this.firstTime = false;
				}
			},

			onLeftArrowClick : function(event)
			{
				event.preventDefault();
				CutoutOverlayController.getInstance().goToPrevious();
			},

			onRightArrowClick : function(event)
			{
				event.preventDefault();
				CutoutOverlayController.getInstance().goToNext();
			}
		}
	})
]);