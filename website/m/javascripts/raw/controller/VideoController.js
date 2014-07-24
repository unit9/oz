/*global Poof */
/*global Package */
/*global Class */

/*global Detection */
/*global VideoController */

Package('controller',
[
	Class('public singleton VideoController',
	{
		_public_static:
		{
			LOCALISED_VIDEOS: ['de', 'es-419', 'fr', 'it', 'pt-br', 'da', 'nl', 'no'],
			DEFAULT_LOCALE: 'en-us'
		},

		_public:
		{
			$video : null,

			VideoController : function()
			{
				this.$video = $('video');
				this.$video.bind('webkitendfullscreen', Poof.retainContext(this, this.onFullscreenEnd));

				this.$video.attr('src', '/m/videos/' + this.getLocalisedVideoName() + '.mp4');
			},

			getLocalisedVideoName : function()
			{
				var videoLocale = VideoController.LOCALISED_VIDEOS.indexOf(Detection.getInstance().language) === -1 ? VideoController.DEFAULT_LOCALE : Detection.getInstance().language;
				return 'exclusive_' + videoLocale;
			},

			playVideo : function()
			{
				this.$video[0].play();
				if(this.$video[0].webkitEnterFullscreen)
				{
					this.$video[0].webkitEnterFullscreen();
				}
			},

			stopVideo : function()
			{
				this.$video[0].pause();
			},

			onFullscreenEnd : function()
			{
				this.stopVideo();
			}
		}
	})
]);