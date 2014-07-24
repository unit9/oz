Package('', [
	
	/* load all libraries */
	Load('/demos/mobile_photo_booth/js/lib/jquery-1.9.0.min.js'),
	Load('/demos/mobile_photo_booth/js/lib/jquery.ui.widget.js'),
	Load('/demos/mobile_photo_booth/js/lib/jquery.fileupload.js'),
	Load('/demos/mobile_photo_booth/js/lib/jQueryRotate.2.2.js'),

	/* import classes */
	Import('view.MainView'),
	Import('controller.UploadController'),

	Class('public singleton PhotoBoothApplication', {
		
		_public: {
			
			PhotoBoothApplication : function() {
				
				UploadController.getInstance().initWithFileInput(MainView.getInstance().$fileInput);
				this.bindEvents();

			},

			bindEvents : function() {

				UploadController.getInstance().on(UploadController.EVENT_UPLOAD_COMPLETE, Poof.retainContext(this, this.onPhotoUploadComplete));

			},

			onPhotoUploadComplete : function(event) {

				MainView.getInstance().setPhoto('/api/image/?id=' + event.data.id);
				MainView.getInstance().hideUploadOverlay();
				
			}
		}
	})
]);