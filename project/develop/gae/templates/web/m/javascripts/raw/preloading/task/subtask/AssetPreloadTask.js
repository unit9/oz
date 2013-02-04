/*global Package */
/*global Import */
/*global Class */

/*global AssetPreloadTask */
/*global Detection */

Package('preloading.task.subtask',
[
	Import('preloading.task.subtask.ImagePreloadTask'),

	Class('public AssetPreloadTask extends ImagePreloadTask',
	{
		_public_static:
		{
			ASSETS_ROOT: '/m/images/simple/',

			resolveAssetUrl : function(assetName, extension, responsive)
			{
				return AssetPreloadTask.ASSETS_ROOT + assetName + (responsive === true ? ((Detection.getInstance().tablet ? '-tab' : '') + (Detection.getInstance().retina ? '-2x' : '')) : '') + '.' +  extension;
			}
		},

		_public:
		{
			AssetPreloadTask : function(assets, weight)
			{
				var urls = [];
				if(typeof(assets) === 'string')
				{
					urls.push({url: AssetPreloadTask.resolveAssetUrl(assets.name, assets.ext, assets.responsive), type: assets.type});
					this._super(urls, weight);
				} else if(assets)
				{
					for(var i = 0; i < assets.length; i ++)
					{
						urls.push({url: AssetPreloadTask.resolveAssetUrl(assets[i].name, assets[i].ext, assets[i].responsive), type: assets[i].type});
					}
					this._super(urls, 0);
				}
			}
		}
	})
]);