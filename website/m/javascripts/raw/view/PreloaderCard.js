/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global PreloaderCard */
/*global AnimationController */
/*global ThreeUtil */
/*global TweenLite */
/*global Power4 */
/*global RotationController */
/*global OzMobileRemoteCopy */

Package('view',
[
	Import('mjframe.View'),
	Import('util.ThreeUtil'),
	Import('controller.RotationController'),

	Class('public singleton PreloaderCard extends View',
	{
		_public_static:
		{
			ACCELERATION_MULTIPLER_X : -6.5,
			ACCELERATION_MULTIPLER_Y : -6.5,
			ACCELERATION_OFFSET_X : 0,
			ACCELERATION_OFFSET_Y : 6,
			ACCELERATION_EASE_TIME : 0.5,

			EVENT_COMPLETE : 'PreloaderCard.Event.Complete'
		},

		_public:
		{
			ready : false,
			shown : false,
			showOnceReady : false,
			hideOnceShown : false,
			cardProperties : {posX: 0, posY: 0, posZ: 0, rotX: 90, rotY: -360, rotZ: 0, opacity: 0},
			cardFlipAngle : 0,
			accelerationControlled : false,
			hints : [],
			currentHintIndex : 0,

			$card : null,
			$progress : null,
			$hint : null,

			PreloaderCard : function()
			{
				this._super();
				this.init('preloader', 'view.PreloaderCardView', 'PreloaderCard');
			},

			compile : function()
			{
				this._super();

				this.$card = $('.preloaderContainer .container3d');
				this.$progress = $('.preloaderContainer .progress');
				this.$hint = this.$content.find('.hints p');
			},

			onReady : function()
			{
				this.ready = true;

				this.initView();
				this.$el.css('display', '');

				if(!this.shown && this.showOnceReady)
				{
					this.showReady();
				}

				this.hints = [OzMobileRemoteCopy.getInstance().Hint_explore, OzMobileRemoteCopy.getInstance().Hint_uncover, OzMobileRemoteCopy.getInstance().Hint_complete, OzMobileRemoteCopy.getInstance().Hint_reveal];
				this.$hint.text(this.hints[0]);
			},

			show : function(direction)
			{
				Poof.suppressUnused(direction);
				if(this.ready)
				{
					this.showReady();
				} else
				{
					this.showOnceReady = true;
				}
			},

			hide : function(direction)
			{
				Poof.suppressUnused(direction);

				if(this.shown)
				{
					setTimeout(Poof.retainContext(this, this.animateOut), 2000);
				} else
				{
					this.hideOnceShown = true;
				}
			},

			initView : function()
			{
				ThreeUtil.getInstance().setPerspective(this.$card, 250);
				this.$card.css('opacity', 0);
			},

			showReady : function()
			{
				this.shown = true;

				this.$container.fadeIn();
				this.startAnimation();
				this.animateIn();
			},

			startAnimation : function()
			{
				AnimationController.getInstance().on(AnimationController.EVENT_FRAME + '#preloader', Poof.retainContext(this, this.onFrame));
				RotationController.getInstance().on(RotationController.EVENT_ROTATION + '#preloader', Poof.retainContext(this, this.onDeviceRotation));
				RotationController.getInstance().start();
				this.$container.bind('click', Poof.retainContext(this, this.onCardClick));
			},

			stopAnimation : function()
			{
				AnimationController.getInstance().off(AnimationController.EVENT_FRAME + '#preloader');
				RotationController.getInstance().off(RotationController.EVENT_ROTATION + '#preloader');
				RotationController.getInstance().stop();
				this.$container.off('click');
			},

			animateIn : function()
			{
				TweenLite.to(this.cardProperties, 1, {opacity: 1});
				TweenLite.to(this.cardProperties, 2, {rotX: 0, rotY: 0, ease: Power4.easeInOut, onComplete: Poof.retainContext(this, this.onAnimateInComplete)});
			},

			animateOut : function()
			{
				this.accelerationControlled = false;
				TweenLite.to(this.cardProperties, 1, {opacity: 0, delay: 1});
				TweenLite.to(this.cardProperties, 2, {rotX: 270, rotY: 0, ease: Power4.easeInOut, onComplete: Poof.retainContext(this, this.onAnimateOutComplete)});
			},

			setProgress : function(progress)
			{
				if(this.$progress)
				{
					this.$progress.text('45');
					this.$progress.text(Math.min(Math.round(progress * 100), 99).toString() + '%');
				}
			},

			applyRotation : function(rotation)
			{
				var destRotationX = (rotation.y + PreloaderCard.ACCELERATION_OFFSET_Y) * PreloaderCard.ACCELERATION_MULTIPLER_X;
				var destRotationY = (rotation.x + PreloaderCard.ACCELERATION_OFFSET_X) * PreloaderCard.ACCELERATION_MULTIPLER_Y;
				TweenLite.to(this.cardProperties, PreloaderCard.ACCELERATION_EASE_TIME, {rotX: destRotationX, rotY: destRotationY});
			},

			nextHint : function()
			{
				this.$hint.fadeOut(null, Poof.retainContext(this, function()
				{
					this.currentHintIndex = (this.currentHintIndex + 1) % this.hints.length;
					this.$hint.text(this.hints[this.currentHintIndex]);
				})).fadeIn();
			},

			onCardClick : function(event)
			{
				event.preventDefault();
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.preloader_useraction_flipcard);
				TweenLite.to(this.cardProperties, 1, {rotZ: (this.cardFlipAngle += 180), ease: Power4.easeInOut});
				this.nextHint();
			},

			onTweenUpdate : function()
			{
				this.$card.css('opacity', this.cardProperties.opacity);
			},

			onAnimateInComplete : function()
			{
				this.accelerationControlled = true;

				if(this.hideOnceShown)
				{
					setTimeout(Poof.retainContext(this, this.hide), 1000);
				}
			},

			onAnimateOutComplete : function()
			{
				this.stopAnimation();
				this.$container.fadeOut();
				this.dispatch(PreloaderCard.EVENT_COMPLETE);
			},

			onDeviceRotation : function(event)
			{
				if(this.accelerationControlled)
				{
					this.applyRotation(event.data.rotation);
				}
			},

			onFrame : function(event)
			{
				Poof.suppressUnused(event);
				this.$card.css('opacity', this.cardProperties.opacity);
				ThreeUtil.getInstance().rotate(this.$card, this.cardProperties.rotX, this.cardProperties.rotY, this.cardProperties.rotZ);
			}
		}
	})
]);