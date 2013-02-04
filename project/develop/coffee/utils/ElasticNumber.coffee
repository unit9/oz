class ElasticNumber


	spring 		: 0
	damping 	: 0
	_value 		: 0
	_aim 		: 0
	_vel 		: 0
	roundToInt 	: false
	maxdelta 	: 0
	deltaScale	: 0
	threshold	: 0

	constructor:->
		@spring = 0.03
		@damping = 0.3
		@_vale = 0
		@_aim = 0
		@_vel = 0
		@roundToInt = false
		@maxdelta = 0.3
		@deltaScale = 100
		@threshold = 0.01


	aimAt:(value)->
		@_aim = value;			

	step:(delta)->
		
		d = @_aim - @_value

		acc = d * @spring - @_vel * @damping

		# if Math.abs( @_aim - @_value ) > @threshold

		delt = Math.min(delta,@maxdelta) * @deltaScale

		@_vel += acc * delt
		@_value =  @_value + @_vel