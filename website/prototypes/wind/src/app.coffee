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

	noiseMap : null
	noiseShader : null
	noiseScene : null
	noiseMaterial : null
	noiseCameraOrtho : null
	noiseQuadTarget : null
	noiseRenderTarget : null
	
	noiseSpeed : 0.046
	noiseOffsetSpeed : 0.11

	windDirection : new THREE.Vector3(0.8,0.1,0.1)



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
		@camera.position.x = 5;
		@camera.position.y = 10;
		@camera.position.z = 40;
		# @camera.target = new THREE.Vector3( 99, 0, 100 );

		@scene = new THREE.Scene();
		#@scene.fog = new THREE.Fog( 0xFFFFFF, 100, 500 );
		#@scene.fog.color.setRGB(1,1,1)


		ambient = new THREE.AmbientLight 0xFFFFFF
		@scene.add( ambient )

		directional = new THREE.DirectionalLight
		directional.position.set(100,100,100)
		@scene.add directional


		@onWindowResize()
		@noiseMap  = new THREE.WebGLRenderTarget( 256, 256, { minFilter: THREE.LinearMipmapLinearFilter, magFilter: THREE.LinearFilter, format: THREE.RGBFormat } );
		@noiseShader = new NoiseShader()
		@noiseShader.uniforms.vScale.value.set(0.3,0.3)
		@noiseScene = new THREE.Scene()
		@noiseCameraOrtho = new THREE.OrthographicCamera( window.innerWidth / - 2, window.innerWidth / 2,  window.innerHeight / 2, window.innerHeight / - 2, -10000, 10000 );
		@noiseCameraOrtho.position.z = 100
		@noiseScene.add( @noiseCameraOrtho )

		@noiseMaterial = new THREE.ShaderMaterial
			fragmentShader: @noiseShader.fragmentShader
			vertexShader: @noiseShader.vertexShader
			uniforms: @noiseShader.uniforms
			lights:false

		@noiseQuadTarget = new THREE.Mesh( new THREE.PlaneGeometry(window.innerWidth,window.innerHeight,100,100), @noiseMaterial )
		@noiseQuadTarget.position.z = -500
		@noiseScene.add( @noiseQuadTarget )



		@initSky()
		@terrainLoader = new IFLLoader( );
		@terrainLoader.load( "models/wind.if3d", @onTerrainLoaded, @onTerrainProgress );

		@container.appendChild(@renderer.domElement);

		

		@controls = new THREE.OrbitControls( @camera, @renderer.domElement );
		@controls.enabled = true


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


		path = "models/"
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

		@cubeShader = THREE.ShaderUtils.lib[ "cube" ]
		@cubeShader.uniforms[ "tCube" ].value = @skyCubeTexture
		@cubeShader.uniforms[ "tFlip" ].value = true

		material = new THREE.ShaderMaterial
			fragmentShader: @cubeShader.fragmentShader
			vertexShader: @cubeShader.vertexShader
			uniforms: @cubeShader.uniforms
			depthWrite: false
			side: THREE.BackSide


		@skyCube = new THREE.Mesh( geom, material )
		@skyCube.name = "skyCube"
		@scene.add @skyCube
		return
	

	onTerrainProgress:(loaded,total) =>
		$( "#progressbar" ).progressbar( "option", "value", (loaded*100)/total );

	onTerrainLoaded: (iflscene) =>
		
		min = new THREE.Vector2()
		max = new THREE.Vector2()

		fresnelMat = @createFresnelMaterial();

		for child in iflscene.children

			if child.position.x < min.x
				min.x = child.position.x

			if child.position.z < min.y
				min.y = child.position.z

			if child.position.x > max.x
				max.x = child.position.x

			if child.position.z > max.y
				max.y = child.position.z

			child.material = fresnelMat


		w = max.x-min.x
		h = max.y-min.y


		plane = new THREE.Mesh(new THREE.PlaneGeometry(w,h,2,2), new THREE.MeshPhongMaterial({map:@noiseMap,lights:false}))
		plane.visible = false
		plane.position.x = min.x + w/2
		plane.position.z = min.y + h/2
		# plane.rotation.set(Math.PI*2,Math.PI*2,0)
		plane.rotation.x = -Math.PI/2
		# plane.rotation.z = Math.PI/2
		@scene.add plane

		fresnelMat.uniforms.windMin.value.copy(min)
		fresnelMat.uniforms.windSize.value.set(w,h)
		fresnelMat.uniforms.windDirection.value = @windDirection
		@scene.add iflscene


		$( "#loading" ).remove()
		

		@gui = new dat.GUI({width:400})
		@gui.add(plane,"visible").name("Show Turbulence Plane")
		@gui.add(@noiseShader.uniforms.vScale.value,"x",0,1).name("Wind Turbulence Scale X")
		@gui.add(@noiseShader.uniforms.vScale.value,"y",0,1).name("Wind Turbulence Scale Y")
		@gui.add(@,"noiseSpeed",0,1).name("Wind Turbolence Speed")
		@gui.add(@,"noiseOffsetSpeed",0,1).name("Wind Offset Speed")
		@gui.add(fresnelMat.uniforms.windScale,"value",0,10).name("Wind Power")

		

		@xcont = @gui.add(@windDirection,"x",-1,1).step(0.01).name("Wind Direction X").onChange @onWindDirectionChange
		@ycont = @gui.add(@windDirection,"y",-1,1).step(0.01).name("Wind Direction Y").onChange @onWindDirectionChange
		@zcont = @gui.add(@windDirection,"z",-1,1).step(0.01).name("Wind Direction Z").onChange @onWindDirectionChange

		@windDirection.x = 1;
		@windDirection.y = 0;
		@windDirection.z = 0;
		@onWindDirectionChange()

		return null


	onWindDirectionChange:(value)=>
		@windDirection.normalize();
		@xcont.updateDisplay();
		@ycont.updateDisplay();
		@zcont.updateDisplay();


	createFresnelMaterial:()->   
        shader = new IFLPhongFresnelShader
        
        uniforms = shader.uniforms

        params = {}
        params.fragmentShader   = shader.fragmentShader
        params.vertexShader     = shader.vertexShader
        params.uniforms         = uniforms
        params.vertexColors		= THREE.VertexColors
        # params.blending 		= THREE.MultiplyBlending


        material = new THREE.ShaderMaterial( params );
        # material.side = THREE.DoubleSide
        material.lights = false
        # material.transparent = true
        # material.depthWrite = false
        # material.depthTest = false
        # material.alphaTest = 0.7;
        # material.fog = true


        uniforms[ "diffuse" ].value                             = new THREE.Color( 0xFF0000 )
        uniforms[ "ambient" ].value                             = new THREE.Color( 0x111111 )
        uniforms[ "specular" ].value                            = new THREE.Color( 0x000000 )
        uniforms[ "map" ].value = material.map                  = THREE.ImageUtils.loadTexture("models/posy.png");
        uniforms[ "envMap" ].value = material.envMap            = @skyCubeTexture
        # uniforms[ "normalMap" ].value  = material.normalMap     = @loader.getTexture("roundtent_nrml.jpg")
        # uniforms[ "specularMap" ].value = material.specularMap  = @loader.getTexture("roundtent_spec.jpg")
        # uniforms[ "tAux" ].value                                = @noiseMap
        uniforms[ "tWindForce" ].value       					= @noiseMap
        uniforms[ "windScale" ].value       					= 1

        return material

	

	animate: =>
		window.requestAnimationFrame( @animate )
		@render()
		@stats.update()
		return

	render: =>
		delta = @clock.getDelta()
		@renderer.clear()


		if @windDirection
			@noiseShader.uniforms[ "fTime" ].value += delta * @noiseSpeed
			@noiseShader.uniforms[ "vOffset" ].value.x -= (delta * @noiseOffsetSpeed) * @windDirection.x
			@noiseShader.uniforms[ "vOffset" ].value.y += (delta * @noiseOffsetSpeed) * @windDirection.z


		# @noiseShader.uniforms[ "uOffset" ].value.x = 4 * @noiseShader.uniforms[ "offset" ].value.x;
		# @renderer.render( @noiseScene, @noiseCameraOrtho, @noiseMap, true );
		@renderer.render( @noiseScene, @noiseCameraOrtho ,@noiseMap,true);

		

	
		@controls?.update() if @controls?.enabled
		@renderer.render( @scene, @camera )
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