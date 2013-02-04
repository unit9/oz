/*global Package */
/*global Import */
/*global Class */

/*global LayoutAnimationSlideIn */
/*global Copy */
/*global View */
/*global NavigationManager */

Package('mjframe',
[
	Import('mjframe.View'),
	Import('mjframe.NavigationManager'),
	Import('mjframe.animation.LayoutAnimationSlideIn'),

	Class('public abstract Page extends View',
	{
		_public_static:
		{
			DELAY_EXTRA_SHORT : 0,
			DELAY_SHORT : 0,
			DELAY_LONG : 1000
		},

		_public:
		{
			name : null,
			requestUrl : null,
			data : null,
			active : false,
			deactivated : false,
			pageInfo : null,
			showDelayForward : 0,
			showDelayBackward : 0,
			allowedOrientation : 'portrait',

			urlChangeHandler : null,

			Page : function()
			{
				this.name = this._class._classInfo.name;
				this.animation = new LayoutAnimationSlideIn();
				window.main.on(Copy.EVENT_LOCALE_CHANGE, Poof.retainContext(this, this.onCopyLocaleChange));
			},

			activate : function()
			{
				this.active = true;
			},

			deactivate : function()
			{
				this.deactivated = true;
				this.active = false;
			},

			init : function(containerId, templateUrl)
			{
				containerId = null;	// supress CodeKit warnings
				templateUrl = null;	// supress CodeKit warnings

				this._super('page', 'page.' + this._class._classInfo.name, this._class._classInfo.name);
			},

			show : function(direction)
			{
				var self = this;

				var showFunction = function()
				{
					self.deactivated = false;
					self._super(direction);	
				};

				var showDelay = direction === LayoutAnimation.DIRECTION_FORWARD ? this.showDelayForward : this.showDelayBackward;

				if(showDelay === 0)
				{
					showFunction();
				} else
				{
					setTimeout(showFunction, showDelay);
				}
			},

			setShowDelay : function(delayForward, delayBackward)
			{
				if(typeof(delayForward) === 'undefined')
				{
					delayForward = 0;
				}

				if(typeof(delayBackward) === 'undefined')
				{
					delayBackward = 0;
				}

				this.showDelayForward = delayForward;
				this.showDelayBackward = delayBackward;
			},

			bindEvents : function()
			{
				//this._super();
				this.urlChangeHandler = NavigationManager.getInstance().on(NavigationManager.EVENT_URL_CHANGE, Poof.retainContext(this, this.onUrlChange));
			},

			setRequestUrl : function(requestUrl)
			{
				this.requestUrl = requestUrl;
			},

			setPageData : function(data)
			{
				this.data = data;
			},

			destroy : function()
			{
				this._super();
			},

			/* EVENTS */
			onReady : function()
			{
				this.dispatch(View.EVENT_INIT);
			},

			onShow : function()
			{
				this._super();
				this.activate();
			},

			onCopyLocaleChange : function(event)
			{
				event = null;	// supress CodeKit warnings;
				window.console.log('locale change');
			},

			onMouseWheel : function(e)
			{
				if(!this.active)
				{
					return;
				}

				e = window.event || e;
				var delta = Math.max(-5, Math.min(5, (e.wheelDelta || -e.detail)));

				if(typeof(this.onScroll) === 'function')
				{
					this.onScroll(-delta);
				}
			},

			onUrlChange : function(event)
			{
				NavigationManager.getInstance().off(NavigationManager.EVENT_URL_CHANGE, this.urlChangeHandler);
			},

			onResize : function(event)
			{
				$('.pixel-width').height($('body').width());
				$('.pixel-height').height($('body').height());

				console.log('pixel height', $('body').height());
			}
		}
	})
]);
