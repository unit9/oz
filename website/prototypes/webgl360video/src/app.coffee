class App
	stats 			: null
	camera 			: null
	scene 			: null
	renderer 		: null
	controls 		: null
	clock			: null
	renderTarget 	: null
	composer		: null	

	APP_HEIGHT		: 800
	APP_WIDTH		: 600
	APP_HALF_X	 	: 800/2;
	APP_HALF_Y	 	: 600/2;	
	mouseX			: 0
	mouseY			: 0

	counter		: 0


	videoWidth	: 0
	videoHeight	: 0
	videoName	: null
	videoFPS 	: 0
	textureWidth : 0
	textureHeight : 0




	constructor: ->

		@videoWidth		= 2160
		@videoHeight	= 1080
		@videoName		= "videos/inter_appart.webm"
		@videoFPS 		= 24

		@textureWidth 	= 2048
		@textureHeight 	= 1024


		@clock =  new THREE.Clock()
		@pickMouse = 
			x:0
			y:0

		@projector = new THREE.Projector();

		$("body").append( '<div id="container"></div>' );
		@APP_WIDTH = $(window).width();
		@APP_HEIGHT = $(window).height();


		@renderer = new THREE.WebGLRenderer({antialias:false, stencil:false})
		@renderer.autoClear = false
		@renderer.gammaOutput = true
		@renderer.gammaInput = true
		@renderer.sortObjects = false
		# @renderer.shadowMapEnabled = true
		# @renderer.shadowMapSoft = true
		@renderer.setSize( @APP_WIDTH, @APP_HEIGHT )


		@camera = new THREE.PerspectiveCamera( 50, @APP_WIDTH / @APP_HEIGHT, 1, 100000 )
		@camera.position.set(0,0,1)
		@scene = new THREE.Scene();

		ambient = new THREE.AmbientLight 0xFFFFFF
		@scene.add( ambient )

		@initSphere()
		@controls = new THREE.OrbitControls(@camera, @renderer.domElement)

		@stats = new Stats();
		@stats.domElement.style.position = 'absolute';
		@stats.domElement.style.top = '0px';


		window.addEventListener( 'resize', @onWindowResize, false );
		document.addEventListener( 'mousemove', @onMouseMove, false );
		document.addEventListener( 'mousedown', @onMouseClick, false );
		document.addEventListener( 'touchstart', @onTouchStart, false );
		document.addEventListener( 'touchmove', @onTouchMove, false );


		$("#container").append @stats.domElement 
		$("#container").append @renderer.domElement 
		# $("#container").append "<div id='loading'>Loading Resources<div>"
		# $("#loading").append "<div id='progressbar'></div>"
		# $("#progressbar").progressbar({ value: 0 })
		
		@initcomposer()
		@animate()
		@onWindowResize()
		return
	
	initcomposer:()->

		renderTargetParameters = 
			minFilter: THREE.LinearFilter
			magFilter: THREE.LinearFilter
			format: THREE.RGBFormat		
		@renderTarget = new THREE.WebGLRenderTarget( @APP_WIDTH, @APP_HEIGHT, renderTargetParameters )
		@composer = new THREE.EffectComposer( @renderer, @renderTarget )

		renderModel = new THREE.RenderPass( @scene, @camera, null, false, false )
		effectBloom = new THREE.BloomPass( 1 )
		effectFilm = new THREE.FilmPass 0.10, 0.20, @APP_HEIGHT*2, false
		
		@fxaa = new THREE.ShaderPass( THREE.ShaderExtras[ "fxaa" ] );
		@fxaa.uniforms['resolution'].value = new THREE.Vector2( 1 / @APP_WIDTH, 1 / @APP_HEIGHT )
		

		hblur = new THREE.ShaderPass( THREE.ShaderExtras[ "horizontalTiltShift" ] );
		vblur = new THREE.ShaderPass( THREE.ShaderExtras[ "verticalTiltShift" ] );

		bluriness = 2;

		hblur.uniforms[ 'h' ].value = bluriness / @APP_WIDTH;
		vblur.uniforms[ 'v' ].value = bluriness / @APP_HEIGHT;

		hblur.uniforms[ 'r' ].value = vblur.uniforms[ 'r' ].value = 0.5;

		@composer.addPass( renderModel );
		@composer.addPass( @fxaa );
		#@composer.addPass( effectBloom );
		#@composer.addPass( effectFilm );
		# @composer.addPass( hblur );
		# @composer.addPass( vblur );	

		# vblur.renderToScreen = true

		renderToScreenPass = new THREE.ShaderPass( THREE.ShaderExtras[ "screen" ] );
		renderToScreenPass.renderToScreen = true
		@composer.addPass(renderToScreenPass);


	initSphere:()->

		@videoTexture = new VideoTexture @videoName, @videoWidth, @videoHeight, @textureWidth, @textureHeight, @videoFPS

		geom = new THREE.IcosahedronGeometry 10, 4# 100, 40, 20
		
		# shader = THREE.ShaderConvolution3x3['shader']
		# uniforms = THREE.UniformsUtils.clone( shader.uniforms )
		# uniforms['map'].value = @videoTexture

		# uniforms['width'].value =  @textureWidth
		# uniforms['height'].value =  @textureHeight
		# uniforms['cKernel'].value =  THREE.ShaderConvolution3x3['kernels'].emboss_black2

		# # bright factor
		# factor = 0
		# for n in uniforms['cKernel'].value
		# 	factor += n
		# uniforms['factor'].value = if factor != 0 then 1/factor else 1


		# mat = new THREE.ShaderMaterial
		# 	fragmentShader: shader.fragmentShader,
		# 	vertexShader: shader.vertexShader, 
		# 	uniforms: uniforms,



		mat = new THREE.MeshBasicMaterial
			map: @videoTexture
			side: THREE.BackSide



		mat.map = @videoTexture
		mat.side = THREE.BackSide

		mesh = new THREE.Mesh(geom,mat)
		mesh.rotation.y = -Math.PI/2
		@scene.add mesh

	onMouseClick:(event) =>


	onMouseMove:( event ) => 
		@mouseX = event.pageX - @APP_HALF_X
		@mouseY = event.pageY - @APP_HALF_Y

		@pickMouse.x = ( event.clientX / @APP_WIDTH ) * 2 - 1;
		@pickMouse.y = - ( event.clientY / @APP_HEIGHT ) * 2 + 1;

	onTouchStart:( event ) => 
		if ( event.touches.length == 1 ) 
			event.preventDefault()
			mouseX = event.touches[ 0 ].pageX - @APP_HALF_X
			mouseY = event.touches[ 0 ].pageY - @APP_HALF_Y
	
	onTouchMove:( event ) =>
		if ( event.touches.length == 1 ) 
			event.preventDefault()
			mouseX = event.touches[ 0 ].pageX - @APP_HALF_X
			mouseY = event.touches[ 0 ].pageY - @APP_HALF_Y
	

	animate: =>
		window.requestAnimationFrame( @animate )

		delta = @clock.getDelta()

		THREE.AnimationHandler.update( delta )

		# if @video?.readyState == @video?.HAVE_ENOUGH_DATA
		# 	@canvascontext.drawImage( @video, 0, 0, @videoWidth, @videoHeight, 0, 0, @textureWidth, @textureHeight )
		# 	@videoTexture?.needsUpdate = true
		
		#@counter++

		@controls.update()
		@render()
		@stats.update()

		return

	render: =>
		@renderer.clear()
		# @renderer.render( @scene, @camera )
		@composer.render(0.1)
		return

	onWindowResize: =>
		@APP_WIDTH = $(window).width();
		@APP_HEIGHT = $(window).height();
		@APP_HALF_X = @APP_WIDTH/2
		@APP_HALF_Y = @APP_HEIGHT/2

		@camera.aspect = @APP_WIDTH / @APP_HEIGHT
		@camera.updateProjectionMatrix()
		@renderer.setSize( @APP_WIDTH, @APP_HEIGHT )

		try
			@controls?.handleResize()
		catch e
			null

		@renderTarget  = new THREE.WebGLRenderTarget( @APP_WIDTH, @APP_HEIGHT )
		@composer.reset( @renderTarget )		

		@fxaa?.uniforms['resolution'].value = new THREE.Vector2( 1 / @APP_WIDTH, 1 / @APP_HEIGHT )
		# $( "#loading" ).css({
		# 	'position': 'absolute'
		# 	'width' : 400
		# 	"height": 100
		# 	'left': @APP_WIDTH/2 - 200
		# 	'top': @APP_HEIGHT/2 - 50
		# 	});
		return
	
#bootstrap
$ ->
    $(document).ready ->
        if !Detector.webgl or !Detector.workers
            Detector.addGetWebGLMessage()
        else
            new App