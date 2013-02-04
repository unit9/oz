/*global Poof */
/*global Package */
/*global Import */
/*global Class */

/*global CutoutPage */
/*global FooterViewSimple */
/*global UploadController */
/*global PhotoPositionController */
/*global CutoutOverlayController */
/*global OverlayController */
/*global SharingController */
/*global AnimationController */
/*global CutoutControls */
/*global HeaderViewSimple */
/*global FooterViewSimple */
/*global Analytics */

Package('page',
[
	Import('page.OzPageBase'),
	Import('controller.CutoutOverlayController'),
	Import('controller.CutoutFaceController'),
	Import('controller.UploadController'),
	Import('controller.PhotoPositionController'),
	Import('controller.SharingController'),
	Import('view.CutoutControls'),

	Class('public singleton CutoutPage extends OzPageBase',
	{
		_public_static:
		{
			MODE_INTRO					: 0,
			MODE_CUTOUT_SELECTION		: 1,
			MODE_PHOTO_REPOSITION		: 2,
			MODE_REDO					: 3,
			MODE_SHARING				: 4,

			FIRST_TAP_ACTIVATES_ONLY	: true,
			INSTRUCTIONS_DISMISS_DELAY	: 9000,
			UPLOAD_SPINNER_SPEED		: 3,

			FACE_HOLE:
			{
				aspectRatio :			3 / 4,
				left :					0.5,
				top :					0.5,
				height:					0.2
			}
		},

		_public:
		{
			$overlays : null,
			$introOverlay : null,
			$cutoutOverlays : null,
			$uploadButton : null,
			$reUploadButton : null,
			$shareButton : null,
			$editButton : null,
			$shareOnGoogleButton : null,
			$shareOnFacebookButton : null,
			$shareOnTwitterButton : null,
			$shareCloseButton : null,
			$fileInput : null,
			$userPhoto : null,
			$photoFrame : null,
			$uploadingOverlay : null,
			$uploadProgress : null,
			$uploadSpinner : null,
			$repositionOverlay : null,
			$redoOverlay : null,
			$retakeButton : null,
			$repositionButton : null,
			$redoCloseButton : null,
			$sharingOverlay : null,
			$shareLinkInput : null,

			firstTime : true,
			userPhoto : null,
			userPhotoOrientation : 1,
			uploadSpinnerRotation : 0,
			shareLink : null,
			mode : 0,
			overscrolled : false,

			CutoutPage : function()
			{
				this._super();

				this.prevPage = '/circus1';
				this.nextPage = '/circus2';
				this.overscrollNavigationEnabled = true;
			},

			compile : function()
			{
				this._super();

				this.$overlays = $('#cutoutOverlays');
				this.$introClickOverlay = $('#introClickOverlay');
				this.$introOverlay = $('#introOverlay');
				this.$cutoutOverlays = $('#cutoutOverlays');
				this.$fileInput = $('.fileInput');
				this.$userPhoto = $('#userPhoto');
				this.$photoFrame = $('#photoFrame');
				this.$uploadButton = $('#uploadButton');
				this.$reUploadButton = $('#reUploadButton');
				this.$shareButton = $('#cutoutShareButton');
				this.$editButton = $('#cutoutEditButton');
				this.$shareOnGoogleButton = $('#shareGoogleButton');
				this.$shareOnFacebookButton = $('#shareFacebookButton');
				this.$shareOnTwitterButton = $('#shareTwitterButton');
				this.$shareCloseButton = $('#shareCloseButton');
				this.$uploadingOverlay = $('#uploadingOverlay');
				this.$uploadProgress = this.$uploadingOverlay.find('.text.progress');
				this.$uploadSpinner = this.$uploadingOverlay.find('.spinnerContainer');
				this.$repositionOverlay = $('#repositionOverlay');
				this.$redoOverlay = $('#redoOverlay');
				this.$retakeButton = $('#redoRetakeButton');
				this.$repositionButton = $('#redoRepositionButton');
				this.$redoCloseButton = $('#redoCloseButton');
				this.$repositionDoneButton = $('#repositionDoneButton');
				this.$sharingOverlay = $('#sharingOverlay');
				this.$shareLinkInput = $('#shareLinkInput');
			},

			bindEvents : function()
			{
				this._super();

				if(this.firstTime)
				{
					this.$introClickOverlay.bind('click.first', Poof.retainContext(this, this.onFirstTap));
				}

				this.$uploadButton.bind('click', Poof.retainContext(this, this.onUploadButtonClick));
				this.$reUploadButton.bind('click', Poof.retainContext(this, this.onReUploadButtonClick));
				this.$repositionDoneButton.bind('click', Poof.retainContext(this, this.onRepositionDoneButtonClick));
				this.$editButton.bind('click', Poof.retainContext(this, this.onEditButtonClick));
				this.$retakeButton.bind('click', Poof.retainContext(this, this.onRetakeButtonClick));
				this.$repositionButton.bind('click', Poof.retainContext(this, this.onRepositionButtonClick));
				this.$redoCloseButton.bind('click', Poof.retainContext(this, this.onRedoCloseButtonClick));
				this.$shareButton.bind('click', Poof.retainContext(this, this.onShareButtonClick));
				this.$shareOnGoogleButton.bind('click', Poof.retainContext(this, this.onShareOnGoogleButtonClick));
				this.$shareOnFacebookButton.bind('click', Poof.retainContext(this, this.onShareOnFacebookButtonClick));
				this.$shareOnTwitterButton.bind('click', Poof.retainContext(this, this.onShareOnTwitterButtonClick));
				this.$shareCloseButton.bind('click', Poof.retainContext(this, this.onShareCloseButtonClick));
				this.$shareLinkInput.bind('mouseup, touchend', Poof.retainContext(this, this.onShareLinkInputUp));
				this.$shareLinkInput.bind('change, keydown, keyup', Poof.retainContext(this, this.onShareLinkInputChange));

				SharingController.getInstance().on(SharingController.EVENT_LINK_READY, Poof.retainContext(this, this.onShareLinkReady));
				CutoutOverlayController.getInstance().on(CutoutOverlayController.EVENT_OVERSCROLL_UP, Poof.retainContext(this, this.onOverscrollUp));
				CutoutOverlayController.getInstance().on(CutoutOverlayController.EVENT_OVERSCROLL_DOWN, Poof.retainContext(this, this.onOverscrollDown));
			},

			unbindEvents : function()
			{
				this.$repositionDoneButton.off('click');
				this.$retakeButton.off('click');
				this.$repositionButton.off('click');
				this.$redoCloseButton.off('click');
				this.$shareButton.off('click');
				this.$shareOnGoogleButton.off('click');
				this.$shareOnFacebookButton.off('click');
				this.$shareOnTwitterButton.off('click');
				this.$shareCloseButton.off('click');
				this.$shareLinkInput.off('mouseup, touchend');
				this.$shareLinkInput.off('change, keydown, keyup');

				SharingController.getInstance().off(SharingController.EVENT_LINK_READY);
				CutoutOverlayController.getInstance().off(CutoutOverlayController.EVENT_OVERSCROLL_UP);
				CutoutOverlayController.getInstance().off(CutoutOverlayController.EVENT_OVERSCROLL_DOWN);
			},

			deactivate : function()
			{
				this._super();

				this.unbindEvents();
			},

			onReady : function()
			{
				this._super();
				this.overscrolled = false;

				CutoutOverlayController.getInstance().initFromContainer(this.$cutoutOverlays);

				UploadController.getInstance().init(this.$fileInput);
				this.$uploadButton = $('#uploadButton');	// re-link the reference after UploadController modifies it
				UploadController.getInstance().on(UploadController.EVENT_UPLOAD_START, Poof.retainContext(this, this.onUploadStart));
				UploadController.getInstance().on(UploadController.EVENT_UPLOAD_PROGRESS, Poof.retainContext(this, this.onUploadProgress));
				UploadController.getInstance().on(UploadController.EVENT_UPLOAD_COMPLETE, Poof.retainContext(this, this.onUploadComplete));

				OverlayController.getInstance().showCutoutOverlay();

				if(this.firstTime)
				{
					this.setIntroMode();
				} else
				{
					if(this.userPhoto)
					{
						this.setUserPhoto(this.userPhoto);
						this.$photoFrame.show();
						this.setPhotoPositioningMode();
						this.hideUploadButton();
						PhotoPositionController.getInstance().restorePosition();
						this.showUserPhoto();
						this.setCutoutSelectionMode();
					}
					
					this.setCutoutSelectionMode();
				}

				this.onResize();
			},

			canGoNext : function()
			{
				return this.mode === CutoutPage.MODE_CUTOUT_SELECTION || this.mode === CutoutPage.MODE_INTRO;
			},

			canGoBack : function()
			{
				return this.mode === CutoutPage.MODE_CUTOUT_SELECTION || this.mode === CutoutPage.MODE_INTRO;
			},

			showUploadButton : function()
			{
				$('#uploadButton').fadeIn();
			},

			hideUploadButton : function()
			{
				$('#uploadButton').fadeOut();
			},

			showUserPhoto : function()
			{
				this.$userPhoto.fadeIn();
			},

			hideUserPhoto : function()
			{
				this.$userPhoto.fadeOut();
			},

			loadUserPhoto : function(photoData)
			{
				this.$userPhoto.attr('src', photoData.url).load(Poof.retainContext(this, this.onPhotoLoadComplete));

				// this.userPhoto = new Image();
				// this.userPhoto.onload = Poof.retainContext(this, this.onPhotoLoadComplete);
				// this.userPhoto.src = photoData.url;
			},

			showIntroOverlay : function()
			{
				this.$introClickOverlay.show();
				this.$introOverlay.fadeIn();
				this.$overlays.addClass('blurred');
			},

			hideIntroOverlay : function()
			{
				this.$introOverlay.fadeOut();
				this.$overlays.removeClass('blurred');
			},

			hideIntroOverlayAtDelay : function(delay)
			{
				setTimeout(Poof.retainContext(this, function()
				{
					this.onFirstTap(null);
				}), delay);
			},

			showLoading : function()
			{
				this.$uploadingOverlay.fadeIn();
				AnimationController.getInstance().on(AnimationController.EVENT_FRAME + '#upload', Poof.retainContext(this, this.onUploadAnimationFrame));
			},

			hideLoading : function()
			{
				this.$uploadingOverlay.fadeOut();
				AnimationController.getInstance().off(AnimationController.EVENT_FRAME + '#upload');
			},

			setLoadingProgress : function(progress)
			{
				this.$uploadProgress.text(parseInt(progress * 100, 10));
			},

			showPhotoPositioningOverlay : function()
			{
				this.$repositionOverlay.fadeIn();
			},

			hidePhotoPositioningOverlay : function()
			{
				this.$repositionOverlay.fadeOut();
			},

			showRedoOverlay : function()
			{
				this.$redoOverlay.fadeIn();
			},

			hideRedoOverlay : function()
			{
				this.$redoOverlay.fadeOut();
			},

			showSharingOverlay : function()
			{
				this.$shareLinkInput.val(this.shareLink);
				this.$sharingOverlay.fadeIn();
			},

			hideSharingOverlay : function()
			{
				this.$sharingOverlay.fadeOut();
			},

			showShareButton : function()
			{
				this.$shareButton.fadeIn();
			},

			hideShareButton : function()
			{
				this.$shareButton.fadeOut();
			},

			showEditButton : function()
			{
				this.$editButton.fadeIn();
			},

			hideEditButton : function()
			{
				this.$editButton.fadeOut();
			},

			setIntroMode : function()
			{
				this.mode = CutoutPage.MODE_INTRO;

				this.hideLoading();
				PhotoPositionController.getInstance().disable();
				CutoutOverlayController.getInstance().disable();
				this.hidePhotoPositioningOverlay();
				this.hideRedoOverlay();
				this.hideSharingOverlay();
				this.hideShareButton();
				this.hideEditButton();
				CutoutControls.getInstance().hide();
				FooterViewSimple.getInstance().show();
				HeaderViewSimple.getInstance().show();

				this.showIntroOverlay();
				this.hideIntroOverlayAtDelay(CutoutPage.INSTRUCTIONS_DISMISS_DELAY);
			},

			setLoadingMode : function()
			{
				this.mode = CutoutPage.MODE_LOADING;

				CutoutOverlayController.getInstance().disable();
				PhotoPositionController.getInstance().disable();
				this.hidePhotoPositioningOverlay();
				this.hideRedoOverlay();
				this.hideSharingOverlay();
				this.hideShareButton();
				this.hideEditButton();
				this.hideIntroOverlay();
				this.hideUploadButton();
				CutoutControls.getInstance().hide();
				FooterViewSimple.getInstance().hide();
				HeaderViewSimple.getInstance().hide();

				this.showLoading();
			},

			setPhotoPositioningMode : function()
			{
				this.mode = CutoutPage.MODE_PHOTO_REPOSITION;

				this.hideLoading();
				CutoutOverlayController.getInstance().disable();
				PhotoPositionController.getInstance().enable();
				this.hideRedoOverlay();
				this.hideSharingOverlay();
				this.hideShareButton();
				this.hideEditButton();
				this.hideIntroOverlay();
				CutoutControls.getInstance().hide();
				FooterViewSimple.getInstance().hide();
				HeaderViewSimple.getInstance().hide();
				this.hideUploadButton();

				this.showPhotoPositioningOverlay();
			},

			setCutoutSelectionMode : function()
			{
				this.mode = CutoutPage.MODE_CUTOUT_SELECTION;

				this.hideLoading();
				PhotoPositionController.getInstance().disable();
				this.hidePhotoPositioningOverlay();
				this.hideRedoOverlay();
				this.hideSharingOverlay();
				this.hideIntroOverlay();

				FooterViewSimple.getInstance().show();
				CutoutOverlayController.getInstance().enable();
				CutoutControls.getInstance().show();
				FooterViewSimple.getInstance().show();
				HeaderViewSimple.getInstance().show();

				if(this.userPhoto)
				{
					this.showShareButton();
					this.showEditButton();
					this.hideUploadButton();
				} else
				{
					this.hideShareButton();
					this.hideEditButton();
					this.showUploadButton();
				}
			},

			setRedoMode : function()
			{
				this.setPhotoPositioningMode();
				this.$repositionDoneButton.addClass('edit');
			},

			setSharingMode : function()
			{
				this.mode = CutoutPage.MODE_SHARING;

				this.hideLoading();
				CutoutOverlayController.getInstance().disable();
				PhotoPositionController.getInstance().disable();
				this.hidePhotoPositioningOverlay();
				this.hideSharingOverlay();
				this.hideShareButton();
				this.hideEditButton();
				this.hideRedoOverlay();
				this.hideIntroOverlay();
				CutoutControls.getInstance().hide();
				FooterViewSimple.getInstance().hide();
				HeaderViewSimple.getInstance().hide();

				this.showSharingOverlay();
			},

			getCutoutInfoObject : function()
			{
				var photoPositionInfoObject = PhotoPositionController.getInstance().getPositionInfoObject();
				
				return {
					cutout:
					{
						photo:
						{
							id: UploadController.getInstance().fileId,
							position: photoPositionInfoObject.position,
							size: photoPositionInfoObject.size,
							orientation: photoPositionInfoObject.orientation
						},

						overlay:
						{
							id: CutoutOverlayController.getInstance().getSelectedId()
						}
					}
				};
			},

			onFirstTap : function(event)
			{
				if(!this.firstTime)
				{
					return;
				}

				this.firstTime = false;

				if(event)
				{
					Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.cutoutpage_useraction_instructionsdismiss);
				} else
				{
					Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.cutoutpage_automatic_instructionsdismiss);
				}

				if(CutoutPage.FIRST_TAP_ACTIVATES_ONLY)
				{
					if(event)
					{
						event.preventDefault();
					}
				}
				
				this.setCutoutSelectionMode();

				this.$introClickOverlay.hide();
				this.$introClickOverlay.unbind('click.first');
			},

			onUploadButtonClick : function()
			{
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.cutoutpage_useraction_touchupload);
			},

			onReUploadButtonClick : function()
			{
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.cutoutpage_useraction_touchreupload);
			},

			onUploadStart : function(event)
			{
				Poof.suppressUnused(event);

				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.cutoutpage_automatic_uploadstart);
				this.hideUploadButton();
				this.hideUserPhoto();
				this.setLoadingMode();
			},

			onUploadProgress : function(event)
			{
				this.setLoadingProgress(event.data.progress);
			},

			onUploadAnimationFrame : function()
			{
				this.uploadSpinnerRotation += CutoutPage.UPLOAD_SPINNER_SPEED;
				this.$uploadSpinner.rotate(this.uploadSpinnerRotation);
			},

			onUploadComplete : function(event)
			{
				this.loadUserPhoto(event.data);
			},

			onPhotoLoadComplete : function(event)
			{
				Poof.suppressUnused(event);

				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.cutoutpage_automatic_uploadfinish);
				
				this.userPhoto = this.$userPhoto[0];
				PhotoPositionController.getInstance().init(this.userPhoto, this.$photoFrame, this.$userPhoto);
				PhotoPositionController.getInstance().updateData();
				this.setRedoMode();
				PhotoPositionController.getInstance().setInitialPosition(1);
				this.showUserPhoto();
			},

			onRepositionDoneButtonClick : function(event)
			{
				event.preventDefault();
				this.setCutoutSelectionMode();
			},

			onEditButtonClick : function(event)
			{
				event.preventDefault();
				if(this.mode === CutoutPage.MODE_CUTOUT_SELECTION && this.userPhoto !== null)
				{
					Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.cutoutpage_useraction_touchedit);
					this.setRedoMode();
				}
			},

			onRedoCloseButtonClick : function(event)
			{
				event.preventDefault();
				this.setCutoutSelectionMode();
			},

			onRetakeButtonClick : function(event)
			{
				Poof.suppressUnused(event);
				this.setCutoutSelectionMode();
			},

			onRepositionButtonClick : function(event)
			{
				event.preventDefault();
				this.setPhotoPositioningMode();
			},

			onShareButtonClick : function(event)
			{
				Poof.suppressUnused(event);
				Analytics.getInstance().trackGoogleAnalyticsEvent($.extend(Analytics.GA_EVENTS.cutoutpage_useraction_touchshare, {value: CutoutOverlayController.getInstance().selectedOverlayIndex}));
				SharingController.getInstance().requestShareLink(this.getCutoutInfoObject());
			},

			onShareLinkReady : function(event)
			{
				this.shareLink = event.data.url;
				this.setSharingMode();
			},

			onShareOnGoogleButtonClick : function(event)
			{
				Poof.suppressUnused(event);
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.cutoutpage_useraction_touchsharegoogle);
				SharingController.getInstance().shareLinkOnGoogle(this.shareLink);
			},

			onShareOnFacebookButtonClick : function(event)
			{
				Poof.suppressUnused(event);
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.cutoutpage_useraction_touchsharefacebook);
				SharingController.getInstance().shareLinkOnFacebook(this.shareLink, '', '');
			},

			onShareOnTwitterButtonClick : function(event)
			{
				Poof.suppressUnused(event);
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.cutoutpage_useraction_touchsharetwitter);
				SharingController.getInstance().shareOnTwitter(this.shareLink);
			},

			onShareLinkInputUp : function(event)
			{
				event.preventDefault();
				event.stopPropagation();
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.cutoutpage_useraction_touchsharelink);
				this.$shareLinkInput[0].setSelectionRange(0, 9999);
			},

			onShareLinkInputChange : function(event)
			{
				event.preventDefault();
				event.stopPropagation();
				this.$shareLinkInput.val(this.shareLink);
			},

			onShareCloseButtonClick : function(event)
			{
				event.preventDefault();
				Analytics.getInstance().trackGoogleAnalyticsEvent(Analytics.GA_EVENTS.cutoutpage_useraction_touchshareclose);
				this.setCutoutSelectionMode();
			},

			onOverscrollUp : function(event)
			{
				Poof.suppressUnused(event);

				if(!this.overscrolled)
				{
					this.overscrolled = true;
					this.goBack();
				}
			},

			onOverscrollDown : function(event)
			{
				Poof.suppressUnused(event);

				if(!this.overscrolled)
				{
					this.overscrolled = true;
					this.goNext();
				}
			},

			onResize : function(event)
			{
				Poof.suppressUnused(event);
				this.$sharingOverlay.show();
				var $sharingOverlayContent = this.$sharingOverlay.find('.content');
				$sharingOverlayContent.css('margin-top', -$sharingOverlayContent.height() * 0.5);
				this.$sharingOverlay.hide();
			}
		}
	})
]);