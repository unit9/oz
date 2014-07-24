class SpinParticle

	dt = .05
	
	constructor: ( _ctx, _x, _y, _life, _angle ) ->
		@moving = false
		@movingAngle = 0
		@movingRadius = Math.random() * 10
		@movingRate = Math.random() * 0.5 + 0.2

		@ctx = _ctx

		@position = {
			x: _x,
			y: _y
		}

		@life = _life
		@angle = _angle
		@color = '#fff'

		@velocity = {
			x: @speed * Math.cos( @angleToRadians( @angle ) ),
			y: @speed * Math.sin( @angleToRadians( @angle ) )
		}

	update: =>

		# @life -= dt

		# if @life > 0
		# 	@position.x += @velocity.x * dt
		# 	@position.y += @velocity.y * dt

		@ctx.beginPath()
		@ctx.fillStyle = @color
		@ctx.arc(@position.x, @position.y, 1, 0, Math.PI*2, true)
		@ctx.fill()
		@ctx.closePath()
		

	fire: =>
		if @moving then return

		@moving = true
		@movingAngle = 0

	angleToRadians: ( angle ) =>
		return angle * Math.PI / 180
