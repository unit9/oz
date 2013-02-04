class App
	container 		: null
	stats 			: null
	camera 			: null
	scene 			: null
	renderer 		: null
	controls 		: null
	clock			: null
	renderTarget 	: null
	composer		: null


	skyCubeTexture 	: null
	skyCube			: null

	terrainLoader	: null
	skyLoader		: null

	lake 			: null
	terrain 		: null
	cloudsGeometry	: null

	materialManager	: null

	constructor: ->

		@clock =  new THREE.Clock()

		@container = document.createElement( 'div' );
		document.body.appendChild( @container );

		@renderer = new THREE.WebGLRenderer({antialias:false});
		@renderer.autoClear = false
		@renderer.gammaOutput = false;
		@renderer.gammaInput = false;
		@renderer.sortObjects = false;
		@renderer.shadowMapEnabled = false;
		@renderer.shadowMapSoft = true;
		@renderer.setSize( window.innerWidth, window.innerHeight );


		@camera = new THREE.PerspectiveCamera( 50, window.innerWidth / window.innerHeight, 1, 5000 );
		@camera.position.z = 20;
		@camera.target = new THREE.Vector3( 0, 0, 0 );

		@scene = new THREE.Scene();
		#@scene.fog = new THREE.Fog( 0xFFFFFF, 100, 500 );
		#@scene.fog.color.setRGB(1,1,1)



		# renderTargetParameters = 
		# 	minFilter: THREE.LinearFilter
		# 	magFilter: THREE.LinearFilter
		# 	format: THREE.RGBFormat

		# @renderTarget = new THREE.WebGLRenderTarget( window.innerWidth, window.innerHeight, renderTargetParameters );
		# @composer = new THREE.EffectComposer( @renderer, @renderTarget );

		# renderModel = new THREE.RenderPass( @scene, @camera, null, false, false );
		# effectBloom = new THREE.BloomPass( .7 );
		
		# hblur = new THREE.ShaderPass( THREE.ShaderExtras[ "horizontalTiltShift" ] );
		# vblur = new THREE.ShaderPass( THREE.ShaderExtras[ "verticalTiltShift" ] );

		# bluriness = 2;

		# hblur.uniforms[ 'h' ].value = bluriness / window.innerWidth;
		# vblur.uniforms[ 'v' ].value = bluriness / window.innerHeight;

		# hblur.uniforms[ 'r' ].value = vblur.uniforms[ 'r' ].value = 0.5;

		# @composer.addPass( renderModel );
		# @composer.addPass( effectBloom );
		# @composer.addPass( hblur );
		# @composer.addPass( vblur );	

		# vblur.renderToScreen = true

		# renderToScreenPass = new THREE.ShaderPass( THREE.ShaderExtras[ "screen" ] );
		# renderToScreenPass.renderToScreen = true
		# @composer.addPass(renderToScreenPass);




		# sunLight = new THREE.DirectionalLight();
		# sunLight.color.setRGB(1,.9,.5);
		# sunLight.position.set( -100, 100, -490 );
		# sunLight.intensity = 1.6
		# sunLight.castShadow = true;
		# sunLight.shadowCameraNear = 1;
		# sunLight.shadowCameraFar = 2000;
		# sunLight.shadowCameraFov = 70;
		# #sunLight.shadowBias = 0.001;
		# sunLight.shadowMapWidth = 512;
		# sunLight.shadowMapHeight = 512;
		# sunLight.shadowDarkness  = .2;

		# sunLight.shadowCameraLeft = 400;
		# sunLight.shadowCameraRight = -400;
		# sunLight.shadowCameraTop = 130;
		# sunLight.shadowCameraBottom = -60;

		#sunLight.shadowCameraVisible = true;

		# @scene.add( sunLight );

		ambient = new THREE.AmbientLight 0xFFFFFF
		@scene.add( ambient )

		@initSky()
		@terrainLoader = new IFLLoader( );
		@terrainLoader.sky = @skyCubeTexture
		@terrainLoader.load( "models/scene.if3d", @onTerrainLoaded, @onTerrainProgress );


		# @skyLoader = new ifl.IFLLoader( );
		# @skyLoader.load( "models/sky_textures.if3d", @initSky );
		# @materialManager = new MaterialManager(@terrainLoader,@skyCubeTexture)
	
		# @loader = new ifl.IFLLoader( );
		# @loader.load "models/balloon.if3d", (iflscene) =>
		# 	iflscene.scale.set(.05,.05,.05)
		# 	@scene.add iflscene
		

		# @loader = new ifl.IFLLoader( );
		# @loader.load "models/vcolor.if3d", (iflscene) =>
		# 	iflscene.children[0].material = @getTerrainMaterial()
		# 	@scene.add iflscene



		@container.appendChild(@renderer.domElement);

		
		radius = @camera.position.z;
		@controls = new THREE.OrbitControls( @camera, @renderer.domElement );


		@stats = new Stats();
		@stats.domElement.style.position = 'absolute';
		@stats.domElement.style.top = '0px';

		@container.appendChild( @stats.domElement );

		window.addEventListener( 'resize', @onWindowResize, false );

		@animate()
		$("body").append("<div id='loading'>Loading Resources<div>")
		$("#loading").append("<div id='progressbar'></div>")
		$("#progressbar").progressbar({ value: 0 })
		@onWindowResize()
		return
	

	initSky : (iflscene) =>

		geom = new THREE.CubeGeometry( 2000, 2000, 2000 )


		# material
		path = "models/used/"
		format = '.jpg';
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


		@skyCube = new THREE.Mesh( geom, material )
		@skyCube.name = "skyCube"
		@scene.add @skyCube
		return
	

	onTerrainProgress:(loaded,total) =>
		$( "#progressbar" ).progressbar( "option", "value", (loaded*100)/total );

	onTerrainLoaded: (iflscene) =>
		
		@scene.add( iflscene )

		descendants = iflscene.getDescendants()
		for descendant in descendants
			fresnel = descendant.material

		gui = new dat.GUI {width:400}	
		gui.add(fresnel.uniforms['mFresnelPower'], 'value',-5,5).name('Fresnel Power').step(0.01)
		gui.add({value:1}, 'value',0,20).name('Normal Scale').onChange (bindval) => fresnel.uniforms['normalScale'].value = new THREE.Vector2(bindval,bindval) 


		$( "#loading" ).remove()
	

		@gui = new dat.GUI {width:400,autoPlace:false}
		return null

	animate: =>
		window.requestAnimationFrame( @animate )
		@render()
		@stats.update()
		return

	render: =>
		delta = @clock.getDelta()


		@renderer.clear()
		@controls.update()
		@renderer.render( @scene, @camera )
		# @composer.render(0.1)
		THREE.AnimationHandler.update( delta )
		return
	

	onWindowResize: =>
		@camera.aspect = window.innerWidth / window.innerHeight
		@camera.updateProjectionMatrix()
		@renderer.setSize( window.innerWidth, window.innerHeight )
		# @renderTarget.width = window.innerWidth
		# @renderTarget.height = window.innerHeight
		$( "#loading" ).css({
			'position': 'absolute'
			'width' : 400
			"height": 100
			'left': window.innerWidth/2 - 200
			'top': window.innerHeight/2 - 50
			});	
		return
	
# bootstrap
$ ->
    $(document).ready ->
        if !Detector.webgl or !Detector.workers
            Detector.addGetWebGLMessage()
        else
            new App