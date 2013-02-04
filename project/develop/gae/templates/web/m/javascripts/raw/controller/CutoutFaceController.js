/*global Package */
/*global Import */
/*global Class */

/*global CutoutFaceController */
/*global IosUtils */

Package('controller',
[
	Import('util.IosUtils'),

	Class('public singleton CutoutFaceController',
	{
		_public_static:
		{
			CUTOUT_MARGIN_H	: 0,
			CUTOUT_MARGIN_V	: 0,
			TO_RADIANS		: Math.PI / 180
		},

		_public:
		{
			$canvas : null,
			canvas : null,
			canvasAspectRatio : 1,
			context : null,
			photo : null,
			photoAspectRatio : 1,
			isPhotoSubsampled : false,
			photoVerticalSquash : 1,
			clipRadiusX : 0,
			clipRadiusY : 0,
			clipOriginX : 0,
			clipOriginY : 0,

			CutoutFaceController : function()
			{
			},

			init : function($canvas)
			{
				this.$canvas = $canvas;
				this.canvas = ($canvas && $canvas.length !== 0) ? $canvas[0] : null;
				this.context = this.canvas ? this.canvas.getContext('2d') : null;
				this.canvas.width = this.$canvas.width();
				this.canvas.height = this.$canvas.height();
				this.canvasAspectRatio = this.canvas.width / this.canvas.height;
				this.clipRadiusX = this.canvas.width * 0.5 - CutoutFaceController.CUTOUT_MARGIN_H;
				this.clipRadiusY = this.canvas.height * 0.5 - CutoutFaceController.CUTOUT_MARGIN_V;
				this.clipOriginX = this.canvas.width * 0.5 - this.clipRadiusX;
				this.clipOriginY = this.canvas.height * 0.5 - this.clipRadiusY;

				this.draw();
			},

			setPhoto : function(photo)
			{
				this.photo = photo;
				this.photoAspectRatio = photo.width / photo.height;

				this.isPhotoSubsampled = IosUtils.getInstance().isImageSubsampled(this.photo);
				this.photoVerticalSquash = IosUtils.getInstance().getImageVerticalSquash(this.photo, this.photo.width, this.photo.height);
				if(this.isPhotoSubsampled && this.photoVerticalSquash != 1)
				{
					this.photoVerticalSquash *= this.photo.width / this.photo.height;
				}
			},

			draw : function(offsetX, offsetY, width, height, rotation)
			{
				if(typeof(offsetX) === 'undefined')
				{
					offsetX = 0;
				}

				if(typeof(offsetY) === 'undefined')
				{
					offsetY = 0;
				}

				if(typeof(width) === 'undefined')
				{
					width = this.photo ? this.photo.width : 0;
				}

				if(typeof(height) === 'undefined')
				{
					height = this.photo ? this.photo.height : 0;
				}

				if(typeof(rotation) === 'undefined')
				{
					rotation = 0;
				}

				var x = offsetX + this.canvas.width * 0.5;
				var y = offsetY + this.canvas.height * 0.5;

				if(this.photo)
				{
					console.log(this.photo);
					// console.log($(this.photo).exif('Orientation'));
				}

				this.context.save();

				// clear the canvas
				this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);

				// clip user photo to eliptical shape
				this.context.save();
				this.context.beginPath();
				this.context.translate(this.clipOriginX, this.clipOriginY);
				this.context.scale(this.clipRadiusX, this.clipRadiusY);
				this.context.arc(1, 1, 1, 0, 2 * Math.PI, false);
				this.context.restore();
				this.context.clip();

				// black background
				this.context.fillStyle = '#000000';
				this.context.fillRect(0, 0, this.canvas.width, this.canvas.height);

				if(this.photo)
				{
					// draw user photo
					this.context.translate(x, y);
					this.context.rotate(rotation * CutoutFaceController.TO_RADIANS);
					this.context.drawImage(this.photo, -width * 0.5, -height * 0.5, width, height / this.photoVerticalSquash);
				}

				this.context.restore();
			}
		}
	})
]);