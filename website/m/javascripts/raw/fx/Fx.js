/*global Package */
/*global Import */
/*global Class */

/*global ParticlesFx */
/*global ThreeUtil */

Package('fx',
[
	Import('fx.ParticlesFx'),

	Class('public singleton Fx',
	{
		_public:
		{
			particles : null,

			initParticles : function()
			{
				var $container = $('#wrapper');
				this.particles = new ParticlesFx(50, 20, '#ffffff', screen.width * 1, screen.height * 0.3, 200, 'fx particle', false, 0.01, true, -4, -4, 0, 0.5);
				var $particles = $(this.particles.domObject);
				$particles.css('left', '50%').css('top', '50%').css('position', 'absolute');
				$container.append($particles);
				ThreeUtil.getInstance().setPerspective($particles, 800);
			},

			showParticles : function()
			{
				if(!this.particles)
				{
					this.initParticles();
				}
				
				this.particles.start();
				$(this.particles.domObject).stop().fadeTo(3000, 1);
			},

			hideParticles : function()
			{
				this.particles.stop();
				$(this.particles.domObject).stop(true, true).fadeOut(1000);
			}
		}
	})
]);