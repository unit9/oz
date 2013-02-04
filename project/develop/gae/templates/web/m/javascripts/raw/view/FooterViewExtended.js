/*global Poof */
/*global Package */
/*global Import */
/*global Class */

Package('view',
[
	Import('mjframe.View'),

	Class('public singleton FooterViewExtended extends View',
	{
		_public:
		{
			FooterViewExtended : function()
			{
				this._super();
				this.init('footerExtended', 'view.FooterViewExtended', 'FooterExtended');
			},

			show : function(direction)
			{
				Poof.suppressUnused(direction);
				this.$el.fadeIn();
			},

			hide : function(direction)
			{
				Poof.suppressUnused(direction);
				this.$el.fadeOut();
			}
		}
	})
]);