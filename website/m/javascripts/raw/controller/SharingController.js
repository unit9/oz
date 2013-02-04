/*global Poof */
/*global Package */
/*global Class */

/*global MjConfig */
/*global SharingController */

Package('controller',
[
	Class('public singleton SharingController',
	{
		_public_static:
		{
			EVENT_LINK_READY : 'SharingController.Event.LinkReady'
		},

		_public:
		{
			SharingController : function()
			{
			},

			requestShareLink : function(info)
			{
				$.ajax({
					type: 'POST',
					url: MjConfig.getInstance().uploadUrl + (window.googleAppEngineRuntime ? '' : '/index.php'),
					contentType: "application/json; charset=utf-8",
					dataType: 'json',
					data: JSON.stringify(info),
					success: Poof.retainContext(this, function(response)
					{
						this.dispatch(SharingController.EVENT_LINK_READY, {url: window.location.protocol + '//' + window.location.host + MjConfig.getInstance().shareLinkBase.replace('{id}', response.result.id)});
					})
				});
			},

			shareLinkOnGoogle : function(link, message)
			{
				var shareUrl = 'https://plus.google.com/share?url={LINK}';

				shareUrl = shareUrl.replace('{LINK}', link);
				window.open(shareUrl, '_blank');
			},

			shareLinkOnFacebook : function(link, title, description)
			{
				var shareUrl = 'http://www.facebook.com/sharer.php?u={LINK}';
				shareUrl = shareUrl.replace('{LINK}', encodeURIComponent(link));
				shareUrl = shareUrl.replace('{TITLE}', encodeURIComponent(title));
				shareUrl = shareUrl.replace('{DESCRIPTION}', encodeURIComponent(description));
				console.log(shareUrl);
				
				window.open(shareUrl, '_blank');
			},

			shareOnTwitter : function(message)
			{
				var url = window.location.protocol + '//' + window.location.host;
				var shareUrl = 'http://twitter.com/intent/tweet?text={TEXT}&url={URL}';

				shareUrl = shareUrl.replace('{TEXT}', encodeURIComponent(message)).replace('{URL}', url);
				window.open(shareUrl, '_blank');
			}
		}
	})
]);