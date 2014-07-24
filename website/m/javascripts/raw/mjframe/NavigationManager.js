/*global Poof */
/*global Package */
/*global Class */

/*global NavigationManager */
/*global MjConfig */

Package('mjframe',
[
	Class('public singleton NavigationManager',
	{
		_public_static:
		{
			EVENT_BROWSER_INCOMPATIBLE		: 'NavigationManager.EventBrowserIncompatible',
			EVENT_URL_CHANGE				: 'NavigationManager.EventUrlChange'
		},

		_public:
		{
			active : false,
			currentPageData : null,
			currentDirection : null,

			init : function()
			{
				if(this.supportsHistory())
				{
					this.initHistoryMode();
				} else if(this.supportsHash())
				{
					this.initHashMode();
				} else
				{
					this.dispatch(NavigationManager.EVENT_BROWSER_INCOMPATIBLE);
				}
			},

			activate : function()
			{
				this.active = true;
			},

			deactivate : function()
			{
				this.activate = false;
			},

			supportsHash : function()
			{
				return 'onhashchange' in window;
			},

			supportsHistory : function()
			{
				return 'history' in window && 'pushState' in window.history && !window.navigator.userAgent.match(/Android/i);
			},

			goTo : function(pageName, pageData, direction)
			{
				if(this.getCurrentPage() === pageName)
				{
					return false;
				}

				if(this.supportsHistory())
				{
					return this.goToHistory(pageName, pageData, direction);
				} else if(this.supportsHash())
				{
					return this.goToHash(pageName, pageData, direction);
				}
			},

			getCurrentPage : function()
			{
				var page = window.location.toString().substring(window.location.toString().indexOf(window.location.host) + window.location.host.length, window.location.toString().length);
				
				if(page.indexOf(MjConfig.getInstance().rootPath) === 0)
				{
					page = page.substring(MjConfig.getInstance().rootPath.length, page.length);
				}

				while(page.indexOf('/') === 0)
				{
					page = page.substring(1, page.length);
				}
				while(page.indexOf('#') !== -1)
				{
					page = page.replace('#', '');
				}
				while(page.lastIndexOf('/') === page.length - 1 && page !== '')
				{
					page = page.substring(0, page.length - 1);
				}

				page = page.indexOf('?') === -1 ? page : page.substring(0, page.indexOf('?'));

				return page === '' ? '/' : (page.indexOf('/') === 0 ? page : ('/' + page));
			},

			/* BELOW SHOULD BE PRIVATE. FIXME: moop.js */
			goToHash : function(pageName, pageData, direction)
			{
				pageName = NavigationManager.getInstance().parsePageName(pageName);
				if(pageName === null || typeof(pageName) === 'undefined')
				{
					return;
				}
				this.currentPageData = pageData;
				this.currentDirection = direction;
				window.console.log('!!!!GOTO-HASH::: !!!: ' + this.getCurrentPage() + " : "+ pageName, direction);
				window.location.href = window.location.protocol + '//' + window.location.host + MjConfig.getInstance().rootPath + '/#' + pageName;
			},

			goToHistory : function(pageName, pageData, direction)
			{
				var page = NavigationManager.getInstance().parsePageName(pageName);
				if(page === null || typeof(page) === 'undefined')
				{
					return;
				}

				page = MjConfig.getInstance().rootPath + (page.indexOf('/') === 0 ? page : ('/' + page));
				page = page.replace('//', '/');
				if(page.indexOf('/') === 0)
				{
					page = page.substring(1, page.length);
				}

				this.currentPageData = pageData;
				this.currentDirection = direction;

				window.console.log(pageName);
				try
				{
					window.history.pushState(pageData, '', '/' + page);
				} catch(e)
				{
					return this.goToHash(pageName, pageData);
				}
				
				window.console.log('!!!!GOTO-HISTORY::: !!!: ' + this.getCurrentPage() + " : "+ pageName, direction);
				
				NavigationManager.getInstance().onUrlChange();
			},

			parsePageName : function(pageName)
			{
				var currentPage = NavigationManager.getInstance().getCurrentPage();
				if(currentPage === '/' && pageName.indexOf('/') !== 0)
				{
					pageName = '/' + pageName;
				}

				if(pageName === null || typeof(pageName) === 'undefined')
				{
					return null;
				}

				if(pageName.lastIndexOf('/') === pageName.length - 1 && pageName !== '/')
				{
					pageName = pageName.substring(0, pageName.length - 1);
				}

				if(pageName.indexOf('/') === 0)
				{
					return pageName.substring(1, pageName.length);
				} else
				{
					return currentPage + (currentPage === '/' ? '' : '/') + pageName;
				}
			},

			initHistoryMode : function()
			{
				window.addEventListener('popstate', Poof.retainContext(this, this.onPopState));
			},

			initHashMode : function()
			{
				window.onhashchange = Poof.retainContext(this, this.onHashChange);
			},

			onHashChange : function(event)
			{
				Poof.suppressUnused(event);
				var newHash = window.location.hash.substring(1, window.location.hash.length);
				if(this.currentPage !== newHash)
				{
					NavigationManager.getInstance().onUrlChange(newHash);
				}
			},

			onPopState : function(event)
			{
				Poof.suppressUnused(event);
				NavigationManager.getInstance().onUrlChange();
			},

			onUrlChange : function()
			{
				if(this.active)
				{
					NavigationManager.getInstance().dispatch(NavigationManager.EVENT_URL_CHANGE, {url: NavigationManager.getInstance().getCurrentPage(), data: this.currentPageData, direction: this.currentDirection});
				}
			}
		}
	})
]);