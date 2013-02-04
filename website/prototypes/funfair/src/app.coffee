class App
	#container 		: null
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

	skyCubeTexture 	: null
	skyCube			: null
	bigWheel		: null
	crousel			: null
	ground			: null

	pointer			: null
	pickMouse		: null
	projector 		: null

	constructor: ->

		@clock =  new THREE.Clock()
		@pickMouse = 
			x:0
			y:0

		@projector = new THREE.Projector();

		#@container = document.createElement( 'div' );
		$("body").append( '<div id="container"></div>' );
		@APP_WIDTH = $(window).width();
		@APP_HEIGHT = $(window).height();


		@renderer = new THREE.WebGLRenderer({antialias:false, stencil:false})
		@renderer.autoClear = false
		
		@renderer.gammaOutput = true
		@renderer.gammaInput = true

		@renderer.sortObjects = false
		@renderer.shadowMapEnabled = true
		@renderer.shadowMapSoft = true
		@renderer.setSize( @APP_WIDTH, @APP_HEIGHT )


		@camera = new THREE.PerspectiveCamera( 50, @APP_WIDTH / @APP_HEIGHT, 10, 100000 )
		#@camera.position.z = 10;
		#@camera.target = new THREE.Vector3( 0, 3, 3 );

		@scene = new THREE.Scene();
		#@scene.fog = new THREE.Fog( 0xFFFFFF, 100, 500 );
		#@scene.fog.color.setRGB(1,1,1)



		renderTargetParameters = 
			minFilter: THREE.LinearFilter
			magFilter: THREE.LinearFilter
			format: THREE.RGBFormat

		@renderTarget = new THREE.WebGLRenderTarget( @APP_WIDTH, @APP_HEIGHT, renderTargetParameters )
		@composer = new THREE.EffectComposer( @renderer, @renderTarget )

		renderModel = new THREE.RenderPass( @scene, @camera, null, false, false )
		effectBloom = new THREE.BloomPass( 1 )
		effectFilm = new THREE.FilmPass 0.10, 0.20, @APP_HEIGHT*2, false
		
		fxaa = new THREE.ShaderPass( THREE.ShaderExtras[ "fxaa" ] );
		fxaa.uniforms['resolution'].value = new THREE.Vector2( 1 / @APP_WIDTH, 1 / @APP_HEIGHT )
		

		hblur = new THREE.ShaderPass( THREE.ShaderExtras[ "horizontalTiltShift" ] );
		vblur = new THREE.ShaderPass( THREE.ShaderExtras[ "verticalTiltShift" ] );

		bluriness = 2;

		hblur.uniforms[ 'h' ].value = bluriness / @APP_WIDTH;
		vblur.uniforms[ 'v' ].value = bluriness / @APP_HEIGHT;

		hblur.uniforms[ 'r' ].value = vblur.uniforms[ 'r' ].value = 0.5;

		@composer.addPass( renderModel );
		#@composer.addPass( fxaa );
		@composer.addPass( effectBloom );
		@composer.addPass( effectFilm );
		# @composer.addPass( hblur );
		# @composer.addPass( vblur );	

		# vblur.renderToScreen = true

		renderToScreenPass = new THREE.ShaderPass( THREE.ShaderExtras[ "screen" ] );
		renderToScreenPass.renderToScreen = true
		@composer.addPass(renderToScreenPass);


		# @ground = new THREE.Mesh( new THREE.PlaneGeometry(10000,10000) )
		# @ground.rotation.x = -Math.PI/2
		# @ground.visible = false
		# @scene.add(@ground)
		# @pointer = @createPyramid(-10,-10,20,20,100)
		# @pointer.rotation.x = Math.PI/2
		# @scene.add(@pointer)

		ambient = new THREE.AmbientLight 0xFFFFFF
		@scene.add( ambient )


		@initSky()
		@initSun()


		$.getJSON('js/camerapath.json', @initPathControls);


		@loader = new ifl.IFLLoader( );
		@loader.load "models/fair_hi.if3d", @onWorldLoaded, @onWorldProgress


		@stats = new Stats();
		@stats.domElement.style.position = 'absolute';
		@stats.domElement.style.top = '0px';


		window.addEventListener( 'resize', @onWindowResize, false );
		document.addEventListener( 'mousemove', @onMouseMove, false );
		document.addEventListener( 'mousedown', @onMouseClick, false );
		document.addEventListener( 'touchstart', @onTouchStart, false );
		document.addEventListener( 'touchmove', @onTouchMove, false );

		@animate()

		$("#container").append @stats.domElement 
		$("#container").append @renderer.domElement 
		$("#container").append "<div id='loading'>Loading Resources<div>"
		$("#loading").append "<div id='progressbar'></div>"
		$("#progressbar").progressbar({ value: 0 })
		
		@onWindowResize()

		return
	
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


	onWorldProgress:(loaded,total) =>
		$( "#progressbar" ).progressbar( "option", "value", (loaded*100)/total );


	onWorldLoaded:(iflscene) =>
		# iflscene.children[0].material.map = THREE.ImageUtils.loadTexture "textures/checker.png"
		
		descendants = iflscene.getDescendants()
		for descendant in descendants
			if descendant.name.toLowerCase().indexOf("big_wheel") != -1
				@bigWheel = descendant
			if descendant.name.toLowerCase().indexOf("carrousel") != -1
				@carousel = descendant

		

		@scene.add iflscene
		@controls.animation.play( true, 0 )
		$( "#loading" ).remove()


	initPathControls: (data) =>
		@controls = new THREE.PathControls( @camera );
		@controls.waypoints = data.waypoints
		@controls.duration = 100

		@controls.useConstantSpeed = true;
		@controls.createDebugPath = false;
		@controls.createDebugDummy = false;

		@controls.lookSpeed = 0.5;

		@controls.lookVertical = true;
		@controls.lookHorizontal = true;

		@controls.verticalAngleMap = 
			srcRange: [ 0, 2 * Math.PI ]
			dstRange: [ 1.3, 2.2 ] 

		@controls.horizontalAngleMap = 
			srcRange: [ 0, 2 * Math.PI ]
			dstRange: [ 1, Math.PI - 1 ] 

		@controls.init()

		@scene.add( @controls.debugPath );
		@scene.add( @controls.animationParent );
		#@controls.animation.play( true, 3 )


	createPyramid:(x, y, w, h, d)->
		geometry = new THREE.Geometry();
		
		# top
		topFace = new THREE.Face3(2,1,0);

		geometry.vertices.push(new THREE.Vector3(x, y, 0));
		geometry.vertices.push(new THREE.Vector3(x + w, y, 0));
		geometry.vertices.push(new THREE.Vector3(x + w / 2, y + h / 2, d));
		
		#right
		rightFace = new THREE.Face3(5,4,3);

		geometry.vertices.push(new THREE.Vector3(x + w, y, 0));
		geometry.vertices.push(new THREE.Vector3(x + w, y + h, 0));
		geometry.vertices.push(new THREE.Vector3(x + w / 2, y + h / 2, d));
		
		#bottom
		bottomFace = new THREE.Face3(8,7,6);

		geometry.vertices.push(new THREE.Vector3(x, y + h, 0));
		geometry.vertices.push(new THREE.Vector3(x + w, y + h, 0));
		geometry.vertices.push(new THREE.Vector3(x + w / 2, y + h / 2, d));
		
		#left
		leftFace = new THREE.Face3(11,10,9);

		geometry.vertices.push(new THREE.Vector3(x, y, 0));
		geometry.vertices.push(new THREE.Vector3(x, y + h, 0));
		geometry.vertices.push(new THREE.Vector3(x + w / 2, y + h / 2, d));

		geometry.faces.push(topFace);
		geometry.faces.push(rightFace);
		geometry.faces.push(bottomFace);
		geometry.faces.push(leftFace);

		geometry.computeCentroids();
		geometry.computeFaceNormals();
		geometry.computeVertexNormals();

		material = new THREE.MeshPhongMaterial({side:THREE.DoubleSide,color:0xFF0000,ambient:0x333333});
		return new THREE.Mesh(geometry, material);

	initSun:()->
		sunLight = new THREE.DirectionalLight();
		sunLight.color.setRGB(1,1,1);
		sunLight.position.set( 5000, 5000, -5000 )
		sunLight.intensity = 1.3
		sunLight.castShadow = true;
		sunLight.shadowCameraNear = 20;
		sunLight.shadowCameraFar = 100000;
		sunLight.shadowCameraFov = 70;
		#sunLight.shadowBias = 0.001;
		sunLight.shadowMapWidth = 1024;
		sunLight.shadowMapHeight = 1024;
		sunLight.shadowDarkness  = .2;

		sunLight.shadowCameraLeft = 5000;
		sunLight.shadowCameraRight = -5000;
		sunLight.shadowCameraTop = 5000;
		sunLight.shadowCameraBottom = -5000;

		#sunLight.shadowCameraVisible = true;

		@scene.add( sunLight );

		textureFlare0 = THREE.ImageUtils.loadTexture( "textures/lensflare/lensflare0.png" );
		textureFlare2 = THREE.ImageUtils.loadTexture( "textures/lensflare/lensflare2.png" );
		textureFlare3 = THREE.ImageUtils.loadTexture( "textures/lensflare/lensflare3.png" );
		
		flareColor = new THREE.Color( 0xFFFFFF )

		lensFlare = new THREE.LensFlare( textureFlare0, 700, 0.0, THREE.AdditiveBlending, flareColor );
		lensFlare.position = sunLight.position

		lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending );
		lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending );
		lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending );

		lensFlare.add( textureFlare3, 60, 0.6, THREE.AdditiveBlending );
		lensFlare.add( textureFlare3, 70, 0.7, THREE.AdditiveBlending );
		lensFlare.add( textureFlare3, 120, 0.9, THREE.AdditiveBlending );
		lensFlare.add( textureFlare3, 70, 1.0, THREE.AdditiveBlending );

		
		lensFlare.customUpdateCallback = ( object ) =>
			vecX = -object.positionScreen.x * 2;
			vecY = -object.positionScreen.y * 2;
			for flare in object.lensFlares
				flare.x = object.positionScreen.x + vecX * flare.distance;
				flare.y = object.positionScreen.y + vecY * flare.distance;
				flare.rotation = 0;
			object.lensFlares[ 2 ].y += 0.025;
			object.lensFlares[ 3 ].rotation = object.positionScreen.x * 0.5 + 45 * Math.PI / 180


		@scene.add( lensFlare );
			

	initSky : () ->

		# material
		path = "textures/skybloom/"
		format = '.png';
		urls = [
			path + 'posx' + format
			path + 'negx' + format
			path + 'posy' + format
			path + 'negy' + format
			path + 'negz' + format
			path + 'posz' + format
		]

		@skyCubeTexture = THREE.ImageUtils.loadTextureCube( urls ,null, onload);
		@skyCubeTexture.format = THREE.RGBFormat
		
		cubeShader = THREE.ShaderUtils.lib[ "cube" ]
		cubeShader.uniforms[ "tCube" ].value = @skyCubeTexture
		
		material = new THREE.ShaderMaterial
			fragmentShader: cubeShader.fragmentShader
			vertexShader: cubeShader.vertexShader
			uniforms: cubeShader.uniforms
			depthWrite: false
			side: THREE.BackSide


		@skyCube = new THREE.Mesh( new THREE.CubeGeometry( 10000, 10000, 10000 ), material )
		@skyCube.name = "skyCube"
		@scene.add @skyCube
		return
	

	

	animate: =>
		window.requestAnimationFrame( @animate )

		delta = @clock.getDelta()

		if @ground? && @controls? && @pointer?
			pickVector = new THREE.Vector3( @pickMouse.x, @pickMouse.y, 1 )
			@projector.unprojectVector( pickVector, @camera )

			cameraAbsPos = @controls.animationParent.position#@camera.matrixWorld.getPosition()

			ray = new THREE.Ray( cameraAbsPos, pickVector.subSelf( cameraAbsPos ).normalize() )
			intersections = ray.intersectObject( @ground )

			if intersections[0]
				point =  intersections[0].point
				console.log "#{point.x} #{point.y} #{point.z}"
				@pointer.position.set(point.x,point.y+100,point.z)


		@bigWheel?.rotation.y +=  delta/10
		@carousel?.rotation.z += delta/2
		THREE.AnimationHandler.update( delta )

		@dcontrols?.update()
		@controls?.update( delta )



		@render()
		@stats.update()
		return

	render: =>
		@renderer.clear()
		#@renderer.render( @scene, @camera )
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

		# renderTargetParameters = 
		# 	minFilter: THREE.LinearFilter
		# 	magFilter: THREE.LinearFilter
		# 	format: THREE.RGBFormat

		@renderTarget  = new THREE.WebGLRenderTarget( @APP_WIDTH, @APP_HEIGHT )
		@composer.reset( @renderTarget )

		@controls?.handleResize()

		$( "#loading" ).css({
			'position': 'absolute'
			'width' : 400
			"height": 100
			'left': @APP_WIDTH/2 - 200
			'top': @APP_HEIGHT/2 - 50
			});		

		return
	
# bootstrap
$ ->
    $(document).ready ->
        if !Detector.webgl or !Detector.workers
            Detector.addGetWebGLMessage()
        else
            new App