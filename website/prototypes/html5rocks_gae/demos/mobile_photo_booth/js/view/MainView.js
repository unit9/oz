Package('view', [
	
	Class('public singleton MainView', {
		
		_public: {

			$fileInput : null,
			$photoImg : null,
			$uploadOverlay : null,
			$frame : null,
			$photoGroup : null,

			MainView : function() {
				
				this.compile();

			},

			compile : function() {

				this.$fileInput = $('#file-input');
				this.$photoImg = $('.preview img');
				this.$uploadOverlay = $('.uploadOverlay');
				this.$frame = $('.frame');
				this.$photoGroup = $('.preview img, .frame');

			},

			setPhoto : function(url) {

				this.$photoImg.attr('src', url);
				this.setInitialPhotoPosition();

			},

			setInitialPhotoPosition : function() {

				if(this.$photoImg.width() > 0) {

					var scale = 0.3;
					var left = ($(window).width() - this.$photoImg.width() * scale) * 0.5;
					var top = ($(window).height() - this.$photoImg.height() * scale) * 0.5;
					var width = $(window).width() * scale;
					var rotation = 0;
					this.setPhotoValues(left, top, width, rotation);

				} else {

					setTimeout(Poof.retainContext(this, this.setInitialPhotoPosition), 10);

				}

			},

			setPhotoValues : function(left, top, width, rotation) {
				
				this.$photoGroup.width(width);
				this.$photoGroup.height(this.$photoImg.height());
				this.$photoGroup.css('left', left);
				this.$photoGroup.css('top', top);
				this.$photoGroup.rotate(rotation);

			},

			hideUploadOverlay : function() {

				this.$uploadOverlay.fadeOut();

			}
		}
	})
]);