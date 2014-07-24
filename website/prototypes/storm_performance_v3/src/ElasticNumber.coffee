class ElasticNumber


	spring : 0.03	
	damping : 0.3
	_value : 0
	_aim : 0
	_vel : 0
	roundToInt : false
	maxdelta : 0.5

	aimAt:(value)->
		@_aim=value;			

	step:(delta)->
		
		d = @_aim - @_value

		acc = d * @spring - @_vel * @damping

		if @getDistanceToAim() > .01
			@_vel += acc * (Math.min(delta,@maxdelta)*100)
			@_value =  @_value + @_vel
			

	getDistanceToAim:()->	
		return Math.abs( @_aim - @_value );
				
		# /**
		#  * 
		#  * @return 
		#  * 
		#  */		
		# public function get velocity():Number
		# {
		# 	return Math.abs(_vel);
		# }
		# public function set velocity(newValue:Number):void
		# {
		# 	_vel = newValue;
		# }
		# /**
		#  * 
		#  * @return 
		#  * 
		#  */		
		# public function get distanceToAim():Number
		# {			
		# 	return Math.abs( _aim - _value );
		# }
		# /**
		#  * 
		#  * @return 
		#  * 
		#  */		
		# public function get value():Number
		# {			
		# 	return roundToInt ? Math.round(_value) : _value;
		# }
		# public function set value(newValue:Number):void
		# {			
		# 	_value=newValue;
		# 	_vel=0;
		# 	_aim=_value;			
		# }
		# /**
		#  * 
		#  * @return 
		#  * 
		#  */		
		# public function get aimValue():Number
		# {
		# 	return _aim;
		# }
# 	}
# }