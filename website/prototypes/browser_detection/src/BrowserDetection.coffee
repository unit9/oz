class BrowserDetection

	browser = null
	browserVersion = null
	webGL = Modernizr.webgl

	constructor: ( ) ->
		@browser = BrowserDetect.browser
		@browserVersion = BrowserDetect.version

		@compare()

	compare: =>
		if @browser == 'Chrome' && webGL
			@onSuccess()
		else if @browser == 'Chrome' && !webGL
			@onError( 'Chrome_NoWebGL' )
		else if @browser == 'Firefox' && webGL
			@onError( 'FF4_WebGL' )
		else if @browser == 'Firefox' && !webGL
			@onError( 'FF4_noWebGL' )
		else if @browser == 'Explorer' && ( @browserVersion == 6 || @browserVersion == 7 || @browserVersion == 8 || @browserVersion == 9 )
			@onError( 'Explorer_OldVersion' )
		else if @browser == 'Safari'
			@onError( 'Safari' )
		else 
			if !window.WebGLRenderingContext
				@onError( 'NoWebGLRenderingContext' )

			gl = canvas.getContext("webgl")
			if !gl
				@onError( 'NoWebGL' )

	onSuccess: =>
		console.log 'good'

	onError: ( error ) =>






