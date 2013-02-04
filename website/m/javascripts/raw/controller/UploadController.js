/*global Package */
/*global Import */
/*global Class */

/*global MjConfig */
/*global UploadController */
/*global alert */

Package('controller',
[
	Import('view.StatsView'),

	Class('public singleton UploadController',
	{
		_public_static:
		{
			EVENT_UPLOAD_START : 'UploadController.Event.UploadStart',
			EVENT_UPLOAD_PROGRESS : 'UploadController.Event.UploadProgress',
			EVENT_UPLOAD_COMPLETE : 'UploadController.Event.UploadComplete',

			ACCEPT_FILE_TYPES: /(\.|\/)(gif|jpe?g|png)$/i
		},

		_public:
		{
			$fileInput : null,
			fileId : -1,

			UploadController : function()
			{
			},

			init : function($fileInput)
			{
				var self = this;
				this.$fileInput = $fileInput;

				this.$fileInput.fileupload(
				{
					dataType: 'json',
					autoUpload : true,

					add : function(e, data)
					{
						if(data.files.length === 0 || (data.files[0].size === 0 && data.files[0].name === "" && data.files[0].fileName === ""))
						{
							return self.onNoFileSelected();
						} else if(data.files.length > 1)
						{
							return self.onMultipleFilesSelected();
						}

						if(!data.files[0].name.match(UploadController.ACCEPT_FILE_TYPES))
						{
							return self.onFileTypeNotSupported();
						}

						data.url = MjConfig.getInstance().uploadUrl + (window.googleAppEngineRuntime ? '' : '/index.php');
						data.submit();
						self.onUploadStart();
					},

					progress : function(e, data)
					{
						self.onUploadProgress(data.loaded / data.total);
					},

					done: function(e, data)
					{
						self.fileId = data.result.result.id;
						self.onUploadComplete(data);
					}
				});
			},

			onNoFileSelected : function()
			{
				// do nothing in this case
			},

			onMultipleFilesSelected : function()
			{
				alert('Please select only one file.');
			},

			onFileTypeNotSupported : function()
			{
				alert('Please select a photo.');
			},

			onUploadStart : function()
			{
				this.dispatch(UploadController.EVENT_UPLOAD_START);
			},

			onUploadProgress : function(progress)
			{
				this.dispatch(UploadController.EVENT_UPLOAD_PROGRESS, {progress: progress});
			},

			onUploadComplete : function(data)
			{
				this.dispatch(UploadController.EVENT_UPLOAD_COMPLETE, {id: data.result.result.id, url: data.result.result.uri});
			}
		}
	})
]);