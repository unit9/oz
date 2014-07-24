/*global Poof */
/*global Package */
/*global Class */

/*global AnimationController */
/*global ThreeUtil */
/*global TweenLite */

Package('fx',
[
	Class('public ParticlesFx',
	{
		_public_static:
		{
			getEnabled : function()
			{
				return true;	// for now support on all devices
			}
		},

		_public:
		{
			numParticles : 100,
			size : 4,
			color : '#ffffff',
			assetName : null,
			rangeX : 600,
			rangeY : 1000,
			rangeZ : 1000,
			dynamic : false,
			energy : 0.2,
			gyroControl : false,
			gyroControlScaleX : 6.5,
			gyroControlScaleY : 6.5,
			gyroControlScaleZ : 0,
			gyroDelay : 0,

			particles : [],
			acceleration : {x: 0, y: 0, z: 0},
			domObject : null,
			$domObject : null,

			ParticlesFx : function(numParticles, size, color, rangeX, rangeY, rangeZ, assetName, dynamic, energy, gyroControl, gyroControlScaleX, gyroControlScaleY, gyroControlScaleZ, gyroDelay)
			{
				this.numParticles = numParticles || this.numParticles;
				this.size = size || this.size;
				this.color = color || this.color;
				this.dynamic = dynamic || this.dynamic;
				this.rangeX = rangeX || this.rangeX;
				this.rangeY = rangeY || this.rangeY;
				this.rangeZ = rangeZ || this.rangeZ;
				this.assetName = assetName || this.assetName;
				this.dynamic = dynamic || this.dynamic;
				this.energy = energy || this.energy;
				this.gyroControl = gyroControl || this.gyroControl;
				this.gyroControlScaleX = gyroControlScaleX || this.gyroControlScaleX;
				this.gyroControlScaleY = gyroControlScaleY || this.gyroControlScaleY;
				this.gyroControlScaleZ = gyroControlScaleZ || this.gyroControlScaleZ;
				this.gyroDelay = gyroDelay || this.gyroDelay;

				this.build();
			},

			build : function()
			{
				if(!ParticlesFx.getEnabled())
				{
					return;
				}

				var $container = $('<div class="particles" />');
				this.particles = [];

				for(var i = 0; i < this.numParticles; ++i)
				{
					var particle = this.generateParticle(this.size, this.color, this.assetName, this.dynamic);
					var $particle = $(particle.domObject);
					ThreeUtil.getInstance().setPosition($particle, Math.random() * this.rangeX - this.rangeX * 0.5, Math.random() * this.rangeY - this.rangeY * 0.5, Math.random() * this.rangeZ * 2 - this.rangeZ);
					$container.append(particle.domObject);
					this.particles.push($particle);
				}

				this.$domObject = $container;
				this.domObject = $container[0];
			},

			start : function()
			{
				if(!ParticlesFx.getEnabled())
				{
					return;
				}

				AnimationController.getInstance().on(AnimationController.EVENT_FRAME + '#particles', Poof.retainContext(this, this.update));
				RotationController.getInstance().on(RotationController.EVENT_ROTATION + '#particles', Poof.retainContext(this, this.onDeviceRotation));
				RotationController.getInstance().start();
			},

			stop : function()
			{
				if(!ParticlesFx.getEnabled())
				{
					return;
				}
				
				AnimationController.getInstance().off(AnimationController.EVENT_FRAME + '#particles');
				RotationController.getInstance().off(RotationController.EVENT_ROTATION + '#particles');
				RotationController.getInstance().stop();
			},

			generateParticle : function(size, color, assetName, dynamic)
			{
				var $domObject = $('<div class="particle" />').width(size).height(size).css('position', 'absolute');
				if(assetName)
				{
					$domObject.addClass('asset ' + assetName);
				} else
				{
					$domObject.css('background-color', color);
				}
				$domObject.css('opacity', Math.random() * 0.5);
				var particle = {domObject: $domObject, dynamic: dynamic};
				return particle;
			},

			update : function(e)
			{
				if(this.dynamic)
				{
					for(var i = 0; i < this.particles.length; ++i)
					{
						if(Math.random() < this.energy)
						{
							var newLeft = this.particles[i].position().left + (Math.random() - 0.5) * this.rangeX * 1 * this.energy;
							var newTop = this.particles[i].position().top + (Math.random() - 0.5) * this.rangeY * 1 * this.energy;

							if(newLeft > -this.rangeX && newLeft < this.rangeX)
							{
								this.particles[i].css('left', newLeft);
							}

							if(newTop > -this.rangeY && newTop < this.rangeY)
							{
								this.particles[i].css('top', newTop);
							}

							this.particles[i].css('opacity', Math.random() > 0.5 ? 0.5 : 0);
						}
					}
				}

				if(this.gyroControl)
				{
					ThreeUtil.getInstance().rotate(this.$domObject, (this.acceleration.y + 8) * this.gyroControlScaleX, this.acceleration.x * this.gyroControlScaleY, this.acceleration.z * this.gyroControlScaleZ);
				}
			},

			onDeviceRotation : function(event)
			{
				TweenLite.to(this.acceleration, this.gyroDelay, event.data.rotation);
			}
		}
	})
]);