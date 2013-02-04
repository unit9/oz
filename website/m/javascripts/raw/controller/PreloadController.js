/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global PreloadController */
/*global Task */
/*global PreloaderPreloadTask */
/*global MainPreloadTask */
/*global PreloaderCard */
/*global Analytics */

Package('controller',
[
	Import('preloading.task.PreloaderPreloadTask'),
	Import('preloading.task.MainPreloadTask'),
	Import('view.PreloaderCard'),

	Class('public singleton PreloadController',
	{
		_public_static:
		{
			EVENT_PRELOADER_COMPLETE : 'PreloadController.EventPreloaderComplete',
			EVENT_MAIN_COMPLETE : 'PreloadController.EventMainComplete'
		},

		_public:
		{
			preloaderTask : null,
			mainTask : null,

			PreloadController : function()
			{
				this.setUpTasks();
				this.bindEvents();
			},

			setUpTasks : function()
			{
				this.preloaderTask = new PreloaderPreloadTask();
				this.mainTask = new MainPreloadTask();
			},

			bindEvents : function()
			{
				this.preloaderTask.on(Task.EVENT_DONE, Poof.retainContext(this, this.onPreloaderPreloadComplete));
				this.mainTask.on(Task.EVENT_PROGRESS, Poof.retainContext(this, this.onMainPreloadProgress));
				this.mainTask.on(Task.EVENT_DONE, Poof.retainContext(this, this.onMainPreloadComplete));
			},

			preloadPreloader : function()
			{
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.preloader_automatic_loadingstart);
				this.preloaderTask.execute();
			},

			preloadMain : function()
			{
				this.mainTask.execute();
			},

			onPreloaderPreloadComplete : function()
			{
				this.dispatch(PreloadController.EVENT_PRELOADER_COMPLETE);
			},

			onMainPreloadProgress : function(event)
			{
				PreloaderCard.getInstance().setProgress(event.data.progress);
			},

			onMainPreloadComplete : function()
			{
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.preloader_automatic_loadingfinish);
				PreloaderCard.getInstance().hide();
				this.dispatch(PreloadController.EVENT_MAIN_COMPLETE);
			}
		}
	})
]);