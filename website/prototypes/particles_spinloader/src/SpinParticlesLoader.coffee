class SpinParticlesLoader 

	maxParticles = 100
	particles = []

	constructor: ->
		@width = 100
		@height = 100
		@radius = 20
		@spinAngle = 0


		@sonic = new Sonic({

			width: 100,
			height: 100,

			stepsPerFrame: 3,
			trailLength: 1,
			pointDistance: .01,
			fps: 30,
			step: 'fader',

			strokeColor: '#fff',

			setup: () ->
				@._.lineWidth = 6;
			,

			path: [
				['arc', 50, 50, 20, 360, 0]
			]
		})		

		@canvas = $('#particles').get(0)
		@ctx = @canvas.getContext( '2d' )

		$('body').append @sonic.canvas
		@sonic.play()

		@init()

	init: =>
		cX = @width / 2 
		cY = @height / 2
		for i in [0 ... maxParticles]
			angle = Math.random() * ( Math.PI * 2)
			x = Math.cos(angle) * @radius + cX
			y = Math.sin(angle) * @radius + cY
			p = new SpinParticle( @ctx, x, y, 2, angle )
			particles.push p

	update: =>
		cX = @width / 2 
		cY = @height / 2

		@spinAngle += 0.05
		if @spinAngle > Math.PI * 2 then @spinAngle = 0


		@ctx.clearRect(0, 0, @width, @height)
		for i in [particles.length - 1 ... 0] by -1
			p = particles[i]
			if p.angle >= @spinAngle - 0.1 && p.angle <= @spinAngle + 0.1
				p.fire()

			if p.moving
				cos = @map(Math.cos( p.movingAngle ) * -1, -1, 1, 0, 1)

				p.position.x = Math.cos( p.angle ) * ( @radius + cos * p.movingRadius ) + cX 
				p.position.y = Math.sin( p.angle ) * ( @radius + cos * p.movingRadius ) + cY
				p.movingAngle += p.movingRate

				if p.movingAngle > Math.PI * 2 then p.moving = false

			p.update()


	map: (num, min1, max1, min2, max2) =>
		num1 = (num - min1) / (max1 - min1)
		num2 = (num1 * (max2 - min2)) + min2
		num2	