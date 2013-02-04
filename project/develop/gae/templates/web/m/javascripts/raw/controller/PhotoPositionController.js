/*global Poof */
/*global Package */
/*global Class */

/*global Modernizr */
/*global PhotoPositionController */
/*global CutoutOverlayController */
/*global Detection */

Package('controller',
[
	Class('public singleton PhotoPositionController',
	{
		_public_static:
		{
			INITIAL_PHOTO_HEIGHT : 0.3,		// * $(window).height()
			INITIAL_PHOTO_OFFSET_TOP: 0.5,	// * $(window).height()
			MIN_PHOTO_WIDTH : 0.2,			// * $(window).height()
			MIN_PHOTO_HEIGHT : 0.2,			// * $(window).height()
			MAX_PHOTO_WIDTH : 0.9,			// * $(window).height()
			MAX_PHOTO_HEIGHT : 0.9			// * $(window).height()
		},

		_public:
		{
			photo : null,
			$frame : null,
			// $canvas : null,
			$photo : null,

			enabled : false,
			isDragging : false,
			photoAspectRatio : null,
			controlModePosition : false,
			controlModeScale : false,
			controlModeRotation : false,

			startPos1 : {x: 0, y: 0},
			startPos1b : {x: 0, y: 0},
			startPos2 : {x: 0, y: 0},
			lastPos1 : {x: 0, y: 0},
			lastPos2 : {x: 0, y: 0},
			photoStartPosition : {x: 0, y: 0},
			photoStartSize : {width: 0, height: 0},
			photoStartMargins : {left: 0, top: 0},
			photoStartRotation : 0,
			numTouches : 0,

			left : 0,
			top : 0,
			width : 0,
			height : 0,
			rotation : 0,

			PhotoPositionController : function()
			{
			},

			// init : function(photo, $frame, $canvas)
			init : function(photo, $frame, $photo)
			{
				this.photo = photo;
				this.$frame = $frame;
				// this.$canvas = $canvas;
				this.$photo = $photo;
				this.$frame.hide();
				this.$photo.hide();
			},

			updateData : function()
			{
				this.photoAspectRatio = null,
				this.controlModePosition = false,
				this.controlModeScale = false,
				this.controlModeRotation = false,

				this.startPos1 = {x: 0, y: 0};
				this.startPos1b = {x: 0, y: 0};
				this.startPos2 = {x: 0, y: 0};
				this.lastPos1 = {x: 0, y: 0};
				this.lastPos2 = {x: 0, y: 0};
				this.photoStartPosition = {x: 0, y: 0};
				this.photoStartSize = {width: 0, height: 0};
				this.photoStartMargins = {left: 0, top: 0};
				this.photoStartRotation = 0;
				this.numTouches = 0;

				this.updateAspectRatio();
			},

			enable : function()
			{
				this.enabled = true;
				$(document).bind(Modernizr.touch ? 'touchstart.reposition' : 'mousedown.reposition', Poof.retainContext(this, this.onTouchStart));
				$(document).bind(Modernizr.touch ? 'touchend.reposition' : 'mouseup.reposition', Poof.retainContext(this, this.onTouchEnd));
				$(document).bind(Modernizr.touch ? 'touchmove.reposition' : 'mousemove.reposition', Poof.retainContext(this, this.onTouchMove));
			},

			disable : function()
			{
				this.enabled = false;
				$(document).unbind('touchstart.reposition');
				$(document).unbind('touchend.reposition');
				$(document).unbind('touchmove.reposition');
				$(document).unbind('mousedown.reposition');
				$(document).unbind('mouseup.reposition');
				$(document).unbind('mousemove.reposition');
			},

			getPositionInfoObject : function()
			{
				var overlayHeight;
				var overlayWidth;

				if($('#wrapper').width() / $('#wrapper').height() > CutoutOverlayController.OVERLAY_ASPECT_RATIO)
				{
					overlayWidth = $('#wrapper').width();
					overlayHeight = overlayWidth / CutoutOverlayController.OVERLAY_ASPECT_RATIO;
				} else
				{
					overlayHeight = $('#wrapper').height();
					overlayWidth = overlayHeight * CutoutOverlayController.OVERLAY_ASPECT_RATIO;
				}
				
				return {
					position:
					{
						left: (parseInt(this.$frame.css('left'), 10) + parseInt(this.$frame.css('margin-left'), 10) - ($('#wrapper').width() - overlayWidth) * 0.5) / overlayWidth,
						top: (parseInt(this.$frame.css('top'), 10) + parseInt(this.$frame.css('margin-top'), 10) - ($('#wrapper').height() - overlayHeight) * 0.5) / overlayHeight
					},
						
					size:
					{
						width: this.$frame.width() / overlayWidth,
						height: this.$frame.height() / overlayHeight
					},

					orientation:
					{
						rotation: this.rotation
					}
				};
			},

			getFrameBoundingBox : function()
			{
				var x = this.$frame.offset().left;
				var y = this.$frame.offset().top;

				var originalWidth = this.$frame.width();
				var originalHeight = this.$frame.height();
				var rotation = this.rotation % 360;

				if(rotation > 90 && rotation <= 180)
				{
					rotation = 180 - rotation;
				} else if(rotation > 180 && rotation <= 270)
				{
					rotation = 180 + rotation;
				} else if(rotation > 270)
				{
					rotation = -rotation;
				}

				rotation *= Math.PI / 180;

				var width = originalWidth * Math.cos(rotation) + originalHeight * Math.sin(rotation);
				var height = originalWidth * Math.sin(rotation) + originalHeight * Math.cos(rotation);

				var centerX = x + width * 0.5;
				var centerY = y + height * 0.5;

				return {x: x, y: y, width: width, height: height, centerX: centerX, centerY: centerY};
			},

			apply : function()
			{
				// var boundingBox = this.getFrameBoundingBox();

				// var offsetX = boundingBox.centerX - this.$canvas.offset().left - this.$canvas.width() * 0.5 + 2;
				// var offsetY = boundingBox.centerY - this.$canvas.offset().top - this.$canvas.height() * 0.5 + 2;

				// CutoutFaceController.getInstance().draw(offsetX, offsetY, this.width, this.height, this.rotation);

				this.$photo.css('left', parseInt(this.$frame.css('left'), 10));
				this.$photo.css('top', parseInt(this.$frame.css('top'), 10));
				this.$photo.width(this.$frame.width());
				this.$photo.height(this.$frame.height());
				this.$photo.css('margin-left', parseInt(this.$frame.css('margin-left'), 10));
				this.$photo.css('margin-top', parseInt(this.$frame.css('margin-top'), 10));
				this.$photo.rotate(this.rotation);
			},

			setInitialPosition : function(orientation)
			{
				if(this.photoAspectRatio === null)
				{
					return;
				}

				var photoHeight = PhotoPositionController.INITIAL_PHOTO_HEIGHT * $('#wrapper').height();
				var photoWidth = photoHeight * this.photoAspectRatio;
				var left = $(window).width() * 0.5;
				var top = PhotoPositionController.INITIAL_PHOTO_OFFSET_TOP * $('#wrapper').height();
				
				this.setPosition(left, top);
				this.setRotation((orientation - 1) * 90);
				this.setSize(photoWidth, photoHeight);

				setTimeout(Poof.retainContext(this, this.apply), 1);	// new frame's position is being applied at a single cycle delay
			},

			restorePosition : function()
			{
				this.setPosition(this.left, this.top);
				this.setRotation(this.rotation);
				this.setSize(this.width, this.height);

				setTimeout(Poof.retainContext(this, this.apply), 1);	// new frame's position is being applied at a single cycle delay
			},

			registerStartValues : function(eventData)
			{
				eventData = eventData.originalEvent;

				this.controlModePosition = true;

				if(eventData.touches)
				{
					if(this.numTouches === 0)
					{
						// first touch
						this.photoStartPosition = {x: parseInt(this.$frame.css('left'), 10), y: parseInt(this.$frame.css('top'), 10)};

						this.startPos1 = {x: eventData.touches[0].pageX, y: eventData.touches[0].pageY};
						this.lastPos1 = {x: this.startPos1.x, y: this.startPos1.y};
						this.numTouches = 1;

						if(eventData.touches.length > 1)
						{
							this.photoStartSize = {width: this.$frame.width(), height: this.$frame.height()};
							this.photoStartMargins = {left: parseFloat(this.$frame.css('margin-left'), 10), top: parseFloat(this.$frame.css('margin-top'), 10)};
							this.photoStartRotation = this.rotation;

							this.startPos1b = {x: this.startPos1.x, y: this.startPos1.y};
							this.startPos2 = {x: eventData.touches[1].pageX, y: eventData.touches[1].pageY};
							this.lastPos2 = {x: this.startPos2.x, y: this.startPos2.y};
							this.controlModeScale = true;
							this.controlModeRotation = true;
							this.controlModePosition = false;
							this.numTouches = 2;
						}
					} else if(this.numTouches === 1)
					{
						// second touch
						this.photoStartSize = {width: parseInt(this.$frame.css('width'), 10), height: parseInt(this.$frame.css('height'), 10)};
						this.photoStartMargins = {left: parseFloat(this.$frame.css('margin-left'), 10), top: parseFloat(this.$frame.css('margin-top'), 10)};
						this.photoStartRotation = this.rotation;

						this.startPos1b = {x: this.lastPos1.x, y: this.lastPos1.y};
						this.startPos2 = {x: eventData.touches[1].pageX, y: eventData.touches[1].pageY};
						this.lastPos2 = {x: this.startPos2.x, y: this.startPos2.y};
						this.controlModeScale = true;
						this.controlModeRotation = true;
						this.controlModePosition = false;
						this.numTouches = 2;
					}	// ignore further touches
				} else
				{
					this.numTouches = 1;
					this.startPos1 = {x: eventData.pageX, y: eventData.pageY};
				}
			},

			registerEndValues : function(eventData)
			{
				eventData = eventData.originalEvent;

				this.controlModeScale = this.controlModeRotation = false;

				if(eventData.touches)
				{
					if(eventData.touches.length > 1)
					{
						this.controlModePosition = false;
						this.numTouches = 0;
					} else
					{
						if(this.numTouches > 1 && eventData.touches && eventData.touches.length > 0)
						{
							var distanceVector1 = {x: eventData.touches[0].pageX - this.lastPos1.x, y: eventData.touches[0].pageY - this.lastPos1.y};
							var distanceVector2 = {x: eventData.touches[0].pageX - this.lastPos2.x, y: eventData.touches[0].pageY - this.lastPos2.y};
							var distanceSq1 = distanceVector1.x * distanceVector1.x + distanceVector1.y * distanceVector1.y;
							var distanceSq2 = distanceVector2.x * distanceVector2.x + distanceVector2.y * distanceVector2.y;

							if(distanceSq1 < distanceSq2)
							{
								this.numTouches = this.numTouches > 1 ? 1 : 0;
								this.photoStartPosition = {x: parseInt(this.$frame.css('left'), 10), y: parseInt(this.$frame.css('top'), 10)};
								this.startPos1 = {x: this.lastPos1.x, y: this.lastPos1.y};
								this.controlModePosition = true;
							} else
							{
								this.controlModePosition = false;
								this.numTouches = 0;
							}
						} else
						{
							this.controlModePosition = false;
							this.numTouches = 0;
						}
					}
				} else
				{
					this.numTouches = 0;
					this.controlModePosition = false;
				}
			},

			registerMoveValues : function(eventData)
			{
				eventData = eventData.originalEvent;

				if(eventData.touches)
				{
					this.lastPos1 = {x: eventData.touches[0].pageX, y: eventData.touches[0].pageY};

					if(eventData.touches.length > 1)
					{
						this.lastPos2 = {x: eventData.touches[1].pageX, y: eventData.touches[1].pageY};
					}
				} else
				{
					this.lastPos1 = {x: eventData.pageX, y: eventData.pageY};
				}

				if(this.controlModePosition)
				{
					this.applyPosition();
				}

				if(this.controlModeRotation)
				{
					this.applyRotation();
				}

				if(this.controlModeScale)
				{
					this.applyScale();
				}

				this.applyConstraints();
			},

			setPosition : function(left, top)
			{
				this.left = left;
				this.top = top;

				this.$frame.css('left', left);
				this.$frame.css('top', top);
			},

			setRotation : function(rotation)
			{
				this.rotation = rotation < 0 ? (360 + rotation) : rotation;
				this.rotation = this.rotation % 360;
				this.$frame.rotate(this.rotation);
			},

			setSize : function(width, height)
			{
				this.width = width;
				this.height = height;

				Poof.suppressUnused(height);

				var widthDiff = width - this.photoStartSize.width;

				this.$frame.css('width', width);
				this.$frame.css('height', width / this.photoAspectRatio);
				
				this.$frame.css('margin-left', - widthDiff * 0.5 + this.photoStartMargins.left);
				this.$frame.css('margin-top', - widthDiff * 0.5 / this.photoAspectRatio + this.photoStartMargins.top);
			},

			updateAspectRatio : function()
			{
				if(this.$photo.width() > 0 && this.$photo.height() > 0)
				{
					this.photoAspectRatio = this.$photo.width() / this.$photo.height();
					this.setInitialPosition(1);
					this.applyAspectRatio();
					this.apply();
					this.$frame.fadeIn();
					this.$photo.fadeIn();
				} else
				{
					setTimeout(Poof.retainContext(this, this.updateAspectRatio), 20);
				}
			},

			applyAspectRatio : function()
			{
				this.$frame.css('width', this.$frame.width());
				this.$frame.css('height', this.$frame.width() / this.photoAspectRatio);
			},

			applyPosition : function()
			{
				var deltaPosition = {x: this.lastPos1.x - this.startPos1.x, y: this.lastPos1.y - this.startPos1.y};
				var newPositionLeft = this.photoStartPosition.x + deltaPosition.x;
				var newPositionTop = this.photoStartPosition.y + deltaPosition.y;
				this.left = newPositionLeft;
				this.top = newPositionTop;
				this.setPosition(newPositionLeft, newPositionTop);
			},

			applyRotation : function()
			{
				this.controlModePosition = false;

				var originalTouchVector = {x: this.startPos2.x - this.startPos1b.x, y: this.startPos2.y - this.startPos1b.y};
				var currentTouchVector = {x: this.lastPos2.x - this.lastPos1.x, y: this.lastPos2.y - this.lastPos1.y};
				var originalAngle = Math.atan2(originalTouchVector.y, originalTouchVector.x);
				var currentAngle = Math.atan2(currentTouchVector.y, currentTouchVector.x);
				this.setRotation((currentAngle - originalAngle) * 180 / Math.PI + this.photoStartRotation);
			},

			applyScale : function()
			{
				this.controlModePosition = false;

				var originalDistanceVector = {x: this.startPos2.x - this.startPos1b.x, y: this.startPos2.y - this.startPos1b.y};
				var currentDistanceVector = {x: this.lastPos2.x - this.lastPos1.x, y: this.lastPos2.y - this.lastPos1.y};
				var originalDistance = Math.sqrt(originalDistanceVector.x * originalDistanceVector.x + originalDistanceVector.y * originalDistanceVector.y);
				var currentDistance = Math.sqrt(currentDistanceVector.x * currentDistanceVector.x + currentDistanceVector.y * currentDistanceVector.y);
				var scale = currentDistance / originalDistance;
				var newWidth = this.photoStartSize.width * scale;
				var newHeight = newWidth / this.photoAspectRatio;

				var minPhotoWidth = $(window).height() * PhotoPositionController.MIN_PHOTO_WIDTH;
				var minPhotoHeight = $(window).height() * PhotoPositionController.MIN_PHOTO_HEIGHT;
				var maxPhotoWidth = $(window).height() * PhotoPositionController.MAX_PHOTO_WIDTH;
				var maxPhotoHeight = $(window).height() * PhotoPositionController.MAX_PHOTO_HEIGHT;

				if(newWidth > minPhotoWidth && newHeight > minPhotoHeight && newWidth < maxPhotoWidth && newHeight < maxPhotoHeight)
				{
					this.setSize(newWidth, newHeight);
				}
			},

			applyConstraints : function()
			{
				var minLeft = 0;
				var maxLeft = $(window).width() - this.$frame.width();
				var minTop = 0;
				var maxTop = $(window).height() + this.$frame.height();

				minLeft -= parseFloat(this.$frame.css('margin-left'));
				minTop -= parseFloat(this.$frame.css('margin-top'));
				maxLeft -= parseFloat(this.$frame.css('margin-left'));
				maxTop += parseFloat(this.$frame.css('margin-top'));

				var newPositionLeft = parseFloat(this.$frame.css('left'));
				var newPositionTop = parseFloat(this.$frame.css('top'));

				if(newPositionLeft < minLeft)
				{
					newPositionLeft = minLeft;
				} else if(newPositionLeft > maxLeft)
				{
					newPositionLeft = maxLeft;
				}

				if(newPositionTop < minTop)
				{
					newPositionTop = minTop;
				} else if(newPositionTop > maxTop)
				{
					newPositionTop = maxTop;
				}

				this.$frame.css('left', newPositionLeft);
				this.$frame.css('top', newPositionTop);
			},

			onTouchStart : function(event)
			{
				if(this.photo && this.photoAspectRatio !== null)
				{
					this.isDragging = true;
					this.registerStartValues(event);
				}
			},

			onTouchEnd : function(event)
			{
				if(this.photo && this.photoAspectRatio !== null)
				{
					this.isDragging = false;
					this.registerEndValues(event);
				}
			},

			onTouchMove : function(event)
			{
				if(Detection.getInstance().android)
				{
					if(!this.isDragging)
					{
						this.onTouchStart(event);
					}

					event.originalEvent.preventDefault();
				}

				if(this.photo && this.isDragging && this.photoAspectRatio !== null)
				{
					this.registerMoveValues(event);
					this.apply();
				}
			}
		}
	})
]);