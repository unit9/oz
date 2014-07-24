/*global Package */
/*global Import */
/*global Class */

/*global HeaderViewSimple */
/*global HeaderViewExtended */
/*global FooterViewSimple */
/*global FooterViewExtended */
/*global CutoutControls */
/*global Fx */
/*global LayoutAnimationSlideIn */

Package('controller',
[
	Import('view.HeaderViewSimple'),
	Import('view.HeaderViewExtended'),
	Import('view.FooterViewSimple'),
	Import('view.FooterViewExtended'),

	Class('public singleton OverlayController',
	{
		_public:
		{
			OverlayController : function()
			{
			},

			showPreloaderOverlay : function()
			{
				HeaderViewSimple.getInstance().hide();
				FooterViewSimple.getInstance().hide();
				HeaderViewExtended.getInstance().hide();
				FooterViewExtended.getInstance().hide();
				CutoutControls.getInstance().hide();
				
				setTimeout(function()
				{
					Fx.getInstance().showParticles();
				}, LayoutAnimationSlideIn.TRANSITION_TIME);
			},

			showHomeOverlay : function()
			{
				HeaderViewSimple.getInstance().hide();
				FooterViewSimple.getInstance().hide();
				HeaderViewExtended.getInstance().hide();
				FooterViewExtended.getInstance().hide();
				CutoutControls.getInstance().hide();
				
				setTimeout(function()
				{
					Fx.getInstance().showParticles();
				}, LayoutAnimationSlideIn.TRANSITION_TIME);
			},

			showIntroOverlay : function()
			{
				HeaderViewSimple.getInstance().show();
				FooterViewSimple.getInstance().show();
				HeaderViewExtended.getInstance().hide();
				FooterViewExtended.getInstance().hide();
				CutoutControls.getInstance().hide();
				
				setTimeout(function()
				{
					Fx.getInstance().showParticles();
				}, LayoutAnimationSlideIn.TRANSITION_TIME);
			},

			showCutoutOverlay : function()
			{
				HeaderViewSimple.getInstance().show();
				FooterViewExtended.getInstance().hide();
				HeaderViewExtended.getInstance().hide();
				FooterViewSimple.getInstance().show();
				CutoutControls.getInstance().hide();
				Fx.getInstance().hideParticles();
			},

			showJourneyToOzOverlay : function()
			{
				HeaderViewSimple.getInstance().show();
				FooterViewExtended.getInstance().hide();
				HeaderViewExtended.getInstance().hide();
				FooterViewSimple.getInstance().show();
				CutoutControls.getInstance().hide();
				Fx.getInstance().hideParticles();
			},

			showVideoOverlay : function()
			{
				HeaderViewSimple.getInstance().show();
				FooterViewSimple.getInstance().show();
				HeaderViewExtended.getInstance().hide();
				FooterViewExtended.getInstance().hide();
				CutoutControls.getInstance().hide();
				Fx.getInstance().hideParticles();
			},

			showThankYouOverlay : function()
			{
				HeaderViewSimple.getInstance().show();
				FooterViewSimple.getInstance().show();
				HeaderViewExtended.getInstance().hide();
				FooterViewExtended.getInstance().hide();
				CutoutControls.getInstance().hide();
				Fx.getInstance().hideParticles();
			},

			showFooterOverlay : function()
			{
				HeaderViewSimple.getInstance().show();
				FooterViewSimple.getInstance().hide();
				HeaderViewExtended.getInstance().hide();
				FooterViewExtended.getInstance().hide();
				CutoutControls.getInstance().hide();

				setTimeout(function()
				{
					Fx.getInstance().showParticles();
				}, LayoutAnimationSlideIn.TRANSITION_TIME);
			}
		}
	})
]);