/*global Package */
/*global Import */
/*global Class */

/*global Detection */
/*global ImagePreloader */
/*global ImagePreloadTask */
/*global AssetPreloadTask */
/*global TemplatePreFetchTask */

Package('preloading.task',
[
	Import('util.Task'),
	Import('util.Detection'),
	Import('preloading.task.subtask.ImagePreloadTask'),
	Import('preloading.task.subtask.AssetPreloadTask'),
	Import('preloading.task.subtask.TemplatePreFetchTask'),

	Class('public MainPreloadTask extends Task',
	{
		_public:
		{
			MainPreloadTask : function()
			{
				var sprites = [];
				for(var i = 0; i < Detection.getInstance().spriteUrls.length; i ++)
				{
					sprites.push({url: Detection.getInstance().spriteUrls[i], type: ImagePreloader.TYPE_BACKGROUND});
				}

				var subtasks = [
					new AssetPreloadTask([
						{name: 'cutout/cutout-overlay-1', ext: 'png', type: ImagePreloader.TYPE_BACKGROUND, responsive: true},
						{name: 'cutout/cutout-overlay-2', ext: 'png', type: ImagePreloader.TYPE_BACKGROUND, responsive: true},
						{name: 'cutout/cutout-overlay-3', ext: 'png', type: ImagePreloader.TYPE_BACKGROUND, responsive: true},
						{name: 'cutout/cutout-overlay-4', ext: 'png', type: ImagePreloader.TYPE_BACKGROUND, responsive: true},
						{name: 'cutout/cutout-overlay-5', ext: 'png', type: ImagePreloader.TYPE_BACKGROUND, responsive: true},
						{name: 'cutout/cutout-overlay-6', ext: 'png', type: ImagePreloader.TYPE_BACKGROUND, responsive: true},

						{name: 'journey/scene1', ext: 'jpg', type: ImagePreloader.TYPE_IMG, responsive: false},
						{name: 'journey/scene2', ext: 'jpg', type: ImagePreloader.TYPE_IMG, responsive: false},
						{name: 'journey/scene3', ext: 'jpg', type: ImagePreloader.TYPE_IMG, responsive: false},
						{name: 'journey/scene4', ext: 'jpg', type: ImagePreloader.TYPE_IMG, responsive: false},
						{name: 'journey/scene5', ext: 'jpg', type: ImagePreloader.TYPE_IMG, responsive: false},

						{name: 'background/background-error-2x', ext: 'jpg', type: ImagePreloader.TYPE_BACKGROUND, responsive: false},
						{name: 'decorative/ornament-error', ext: 'png', type: ImagePreloader.TYPE_BACKGROUND, responsive: true},
						{name: 'decorative/ornament-bottom-error', ext: 'png', type: ImagePreloader.TYPE_BACKGROUND, responsive: true},

						{name: 'background/background-video', ext: 'jpg', type: ImagePreloader.TYPE_BACKGROUND, responsive: true},
						{name: 'background/background-video-blurred', ext: 'jpg', type: ImagePreloader.TYPE_BACKGROUND, responsive: true}
					]),

					new TemplatePreFetchTask([
						'page.HomePage',
						'page.CutoutPage',
						'page.JourneyToOzPage1',
						'page.JourneyToOzPage2',
						'page.JourneyToOzPage3',
						'page.JourneyToOzPage4',
						'page.JourneyToOzPage5',
						'page.ThankYouPage',
						'page.FooterPage'
					])
				];

				if(sprites.length !== 0)
				{
					subtasks.push(new ImagePreloadTask(sprites));
				}

				this._super(subtasks);
			}
		}
	})
]);