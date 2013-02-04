/*global Package */
/*global Import */
/*global Class */

/*global Detection */
/*global OzMobileRemoteCopy */

Package('copy',
[
	Import('mjframe.RemoteCopy'),

	Class('public singleton OzMobileRemoteCopy extends RemoteCopy',
	{
		_public_static:
		{
			FORCED_LANGUAGE : null
		},

		_public:
		{
			getRemoteJsonUrls : function()
			{
				console.log('### COPY: ', '/api/localisation/mobile/' + (OzMobileRemoteCopy.FORCED_LANGUAGE ? OzMobileRemoteCopy.FORCED_LANGUAGE : Detection.getInstance().language));
				return ['/api/localisation/mobile/' + (OzMobileRemoteCopy.FORCED_LANGUAGE ? OzMobileRemoteCopy.FORCED_LANGUAGE : Detection.getInstance().language), '/locale/en/mstrings' + (OzMobileRemoteCopy.FORCED_LANGUAGE ? ('_' + OzMobileRemoteCopy.FORCED_LANGUAGE) : '') + '.txt'];
			}
		}
	})
]);
