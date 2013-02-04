/*global Poof */
/*global Package */
/*global Load */
/*global Import */
/*global Class */

/*global console */

Package('view',
[
	Import('mjframe.View'),

	Class('public singleton StatsView extends View',
	{
		_public:
		{
			stats : null,
			$stats : null,

			StatsView : function()
			{
				this._super();

				this.stats = new Stats();
				this.stats.setMode(0);

				this.stats.domElement.style.display = 'none';
				this.stats.domElement.style.position = 'absolute';
				this.stats.domElement.style.left = '0px';
				this.stats.domElement.style.top = '0px';
				this.stats.domElement.style.zIndex = '99999999';

				document.body.appendChild(this.stats.domElement);
				this.$stats = $(this.stats.domElement);
			},

			show : function(direction)
			{
				this.$stats.fadeIn();
			},

			hide : function(direction)
			{
				this.$stats.fadeOut();
			},

			registerFrame : function()
			{
				this.stats.end();
				this.stats.begin();
			}
		}
	})
]);