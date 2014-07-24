/*global Poof */
/*global Package */
/*global Import */
/*global Class */
/*global ClassUtils */

/*global NavigationManager */
/*global PageManager */
/*global View */
/*global GenericLoader */
/*global LayoutAnimation */

Package('mjframe',
[
	Import('mjframe.NavigationManager'),
	Import('mjframe.View'),

	Class('public singleton PageManager',
	{
		_public_static:
		{
			EVENT_PAGE_CHANGE : 'PageManager.EventPageChange',

			DO_NOT_REDIRECT_FOR :
			[
				'/create/uploadcomputer_tab',
				'/create/uploadfacebook_tab',
				'/create/uploadinstagram_tab'
			]
		},

		_public:
		{
			initialized : false,
			pages : {},
			pagesByUrl : {},
			pagesByRegExp : {},
			activePages : [],
			activePopups : [],
			history : [],
			showingInProgress : false,
			queuedPage : null,

			init : function()
			{
				if(PageManager.initialized)
				{
					return;
				}

				NavigationManager.getInstance().on(NavigationManager.EVENT_URL_CHANGE, Poof.retainContext(this, this.onUrlChange));

				PageManager.initialized = true;
			},

			registerPage : function(pageName, className, url, useRegExp, popup, pageUrl)
			{
				if(!this.initialized)
				{
					this.init();
				}

				if(typeof(useRegExp) === 'undefined')
				{
					useRegExp = false;
				}

				if(typeof(popup) === 'undefined')
				{
					popup = false;
				}

				if(typeof(pageUrl) === 'undefined')
				{
					pageUrl = null;
				}

				var pageInfo = {pageName: pageName, className: className, url: url, useRegExp: useRegExp, popup: popup, pageUrl: pageUrl, instance: null};
				this.pages[pageName] = pageInfo;

				if(useRegExp)
				{
					this.pagesByRegExp[url] = pageInfo;
				} else
				{
					this.pagesByUrl[url] = pageInfo;
				}
			},

			getPageNameForUrl : function(url)
			{
				if(url in this.pagesByUrl)
				{
					// there is an explicit page for this URL
					return this.pagesByUrl[url];
				} else
				{
					// there is no explicit page for this URL, try to see if it matches any pattern
					for(var i in this.pagesByRegExp)
					{
						if(new RegExp(this.pagesByRegExp[i].url).test(url))
						{
							return this.pagesByRegExp[i];
						}
					}
				}

				return null;
			},

			getCurrentPage : function()
			{
				return this.activePages.length === 0 ? null : this.activePages[this.activePages.length - 1];
			},

			showPage : function(pageInfo, pageClass, requestUrl, pageData, direction, handler)
			{
				if(!(pageClass in window))
				{
					this.log('page ' + pageClass + ' is not loaded.');
					return;
				}

				if(direction === null || typeof(direction) === 'undefined')
				{
					direction = LayoutAnimation.DIRECTION_FORWARD;
				}

				var page = (ClassUtils.getClassByName(pageClass)).getInstance();
				page.pageInfo = pageInfo;

				if(this.activePages.indexOf(page) !== -1)
				{
					return;
				}

				if(requestUrl)
				{
					this.history.push({url: requestUrl, page: page});
				}

				if('GenericLoader' in window)
				{
					GenericLoader.getInstance().show();
				}
				
				this.showingInProgress = true;
				var self = this;

				page.on(View.EVENT_INIT, Poof.retainContext(this, function()
				{
					if('GenericLoader' in window)
					{
						GenericLoader.getInstance().hide();
					}

					var pageReadyHandler = function()
					{
						if(pageInfo.popup)
						{
							self.activePopups.push(page);
						} else
						{
							self.activePages.push(page);
						}

						page.on(View.EVENT_SHOW, function()
						{
							self.showingInProgress = false;
							page.off(View.EVENT_SHOW);
							self.showQueuedPage();
						});
						
						page.show(direction);

						if(typeof(handler) === 'function')
						{
							handler();
						}

						self.dispatch(PageManager.EVENT_PAGE_CHANGE, page);
					};

					if(pageInfo.popup)
					{
						if(self.activePages.length === 0)
						{
							this.showPageByInfo(this.getPageNameForUrl(pageInfo.pageUrl), null, null, LayoutAnimation.DIRECTION_FORWARD, function()
							{
								pageReadyHandler();
							});
						} else
						{
							pageReadyHandler();
						}
					} else
					{
						this.hideCurrentPage(direction);
						pageReadyHandler();
					}
				}));

				page.setRequestUrl(requestUrl);
				page.setPageData(pageData);
				page.init();
			},

			queuePage : function(pageInfo, requestUrl, pageData, direction)
			{
				this.queuedPage = {pageInfo: pageInfo, requestUrl: requestUrl, pageData: pageData, direction: direction};
			},

			showQueuedPage : function()
			{
				if(this.queuedPage)
				{
					this.showPageByInfo(this.queuedPage.pageInfo, this.queuedPage.requestUrl, this.queuedPage.pageData, this.queuedPage.direction);
					this.queuedPage = null;
				}
			},

			showPageByInfo : function(pageInfo, requestUrl, pageData, direction, handler)
			{
				this.hidePopups(false);

				if(pageInfo === null)
				{
					if(PageManager.DO_NOT_REDIRECT_FOR.indexOf(requestUrl) === -1)
					{
						window.console.warn('[PageManager] page ' + requestUrl + ' not found. Redirecting to root');
						NavigationManager.getInstance().goTo('/');
					} else
					{
						window.console.warn('[PageManager] page ' + requestUrl + ' not found, but not redirecting.');
					}
				} else
				{
					if('GenericLoader' in window)
					{
						GenericLoader.getInstance().show();
					}

					Import(pageInfo.className, Poof.retainContext(this, function(importInfo)
					{
						this.onPageReady(pageInfo, importInfo, requestUrl, pageData, direction, handler);
					}));
				}
			},

			hidePage : function(page, direction)
			{
				page.off(View.EVENT_INIT);
				page.deactivate();
				page.hide(direction);

				if(page.pageInfo.popup)
				{
					this.activePopups.splice(this.activePopups.indexOf(page), 1);
				} else
				{
					this.activePages.splice(this.activePages.indexOf(page), 1);
				}
			},

			hidePopups : function(redirect)
			{

				if(typeof(redirect) === 'undefined')
				{
					redirect = true;
				}

				var i, length;

				if(redirect)
				{
					if(this.history.length > 1)
					{

						var gone = false;
						for(i = 0, length = this.history.length - 2; i < length ; i ++)
						{

							if(!this.history[length - i].page.pageInfo.popup)
							{
								NavigationManager.getInstance().goTo(this.history[length - i].url);
								gone = true;
								break;
							}
						}

						if(!gone)
						{
							NavigationManager.getInstance().goTo( this.history[0].url );
						}
					} else
					{
						NavigationManager.getInstance().goTo(this.activePopups[this.activePopups.length - 1].pageInfo.pageUrl);
					}
				}

				for(i = 0, length = this.activePopups.length ;  i < length ; i ++)
				{
					this.hidePage(this.activePopups[i], LayoutAnimation.DIRECTION_FORWARD);
				}
			},

			hideCurrentPage : function(direction)
			{
				var currentPage = this.getCurrentPage();
				if(currentPage === null)
				{
					return;
				}

				this.hidePage(currentPage, direction);
			},

			onUrlChange : function(event)
			{
				var pageInfo = this.getPageNameForUrl(event.data.url);
				var requestUrl = event.data.url;
				var pageData = event.data.data;
				var direction = event.data.direction;

				if(this.showingInProgress)
				{
					this.queuePage(pageInfo, requestUrl, pageData, direction);
					return;
				}

				this.showPageByInfo(pageInfo, requestUrl, pageData, direction);
			},

			onPageReady : function(pageInfo, importInfo, requestUrl, pageData, direction, handler)
			{
				if ('GenericLoader' in window)
				{
					GenericLoader.getInstance().hide();
				}
				this.showPage(pageInfo, importInfo.className, requestUrl, pageData, direction, handler);
			}
		}
	})
]);
