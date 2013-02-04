/*global Poof */
/*global Package */
/*global Class */

Package('controller',
[
	Class('public singleton VideoController',
	{
		_public:
		{
			$video : null,

			VideoController : function()
			{
				this.$video = $('video');
				this.$video.bind('webkitendfullscreen', Poof.retainContext(this, this.onFullscreenEnd));
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