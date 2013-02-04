/*global Package */
/*global Import */
/*global Class */

/*global RemoteCopyPreloadTask */
/*global AssetPreloadTask */
/*global TemplatePreFetchTask */
/*global ImagePreloader */

Package('preloading.task',
[
	Import('util.Task'),
	Import('preloading.task.subtask.RemoteCopyPreloadTask'),
	Import('preloading.task.subtask.AssetPreloadTask'),
	Import('preloading.task.subtask.TemplatePreFetchTask'),

	Class('public PreloaderPreloadTask extends Task',
	{
		_public:
		{
			PreloaderPreloadTask : function()
			{
				var subtasks = [
					new RemoteCopyPreloadTask(),

					new AssetPreloadTask([
						{name: 'logo/logo-oz', ext: 'png', type: ImagePreloader.TYPE_BACKGROUND, responsive: true},
						{name: 'preloader/preloader-card', ext: 'png', type: ImagePreloader.TYPE_BACKGROUND, responsive: true},
						{name: 'preloader/preloader-ornament-top', ext: 'png', type: ImagePreloader.TYPE_BACKGROUND, responsive: true},
						{name: 'preloader/preloader-ornament-bottom', ext: 'png', type: ImagePreloader.TYPE_BACKGROUND, responsive: true},
						{name: 'background/background-main', ext: 'jpg', type: ImagePreloader.TYPE_BACKGROUND, responsive: false},
						{name: 'fx/fx-particle', ext: 'png', type: ImagePreloader.TYPE_BACKGROUND, responsive: true}
					]),

					new TemplatePreFetchTask([
						'view.OrientationPrompt',
						'view.SplashScreen',
						'view.PreloaderCardView'
					])
				];

				this._super(subtasks);
			}
		}
	})
]);