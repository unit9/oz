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
		@renderer.gammaOutput = true;
		@renderer.gammaInput = true;
		@renderer.sortObjects = false;
		@renderer.shadowMapEnabled = false;
		@renderer.shadowMapSoft = true;
		@renderer.setSize( window.innerWidth, window.innerHeight );


		@camera = new THREE.PerspectiveCamera( 50, window.innerWidth / window.innerHeight, 1, 5000 );
		@camera.position.z = 10;
		@camera.target = new THREE.Vector3( 0, 0, 0 );

		@scene = new THREE.Scene();
		#@scene.fog = new THREE.Fog( 0xFFFFFF, 100, 500 );
		#@scene.fog.color.setRGB(1,1,1)



		renderTargetParameters = 
			minFilter: THREE.LinearFilter
			magFilter: THREE.LinearFilter
			format: THREE.RGBFormat

		@renderTarget = new THREE.WebGLRenderTarget( window.innerWidth, window.innerHeight, renderTargetParameters );
		@composer = new THREE.EffectComposer( @renderer, @renderTarget );

		renderModel = new THREE.RenderPass( @scene, @camera, null, false, false );
		effectBloom = new THREE.BloomPass( .7 );
		
		hblur = new THREE.ShaderPass( THREE.ShaderExtras[ "horizontalTiltShift" ] );
		vblur = new THREE.ShaderPass( THREE.ShaderExtras[ "verticalTiltShift" ] );

		bluriness = 2;

		hblur.uniforms[ 'h' ].value = bluriness / window.innerWidth;
		vblur.uniforms[ 'v' ].value = bluriness / window.innerHeight;

		hblur.uniforms[ 'r' ].value = vblur.uniforms[ 'r' ].value = 0.5;

		@composer.addPass( renderModel );
		@composer.addPass( effectBloom );
		@composer.addPass( hblur );
		@composer.addPass( vblur );	

		vblur.renderToScreen = true

		# renderToScreenPass = new THREE.ShaderPass( THREE.ShaderExtras[ "screen" ] );
		# renderToScreenPass.renderToScreen = true
		# @composer.addPass(renderToScreenPass);




		sunLight = new THREE.DirectionalLight();
		sunLight.color.setRGB(1,.9,.5);
		sunLight.position.set( -100, 100, -490 );
		sunLight.intensity = 1.6
		sunLight.castShadow = true;
		sunLight.shadowCameraNear = 1;
		sunLight.shadowCameraFar = 2000;
		sunLight.shadowCameraFov = 70;
		#sunLight.shadowBias = 0.001;
		sunLight.shadowMapWidth = 512;
		sunLight.shadowMapHeight = 512;
		sunLight.shadowDarkness  = .2;

		sunLight.shadowCameraLeft = 400;
		sunLight.shadowCameraRight = -400;
		sunLight.shadowCameraTop = 130;
		sunLight.shadowCameraBottom = -60;

		#sunLight.shadowCameraVisible = true;

		@scene.add( sunLight );

		ambient = new THREE.AmbientLight 0xFFFFFF
		@scene.add( ambient )

		@terrainLoader = new ifl.IFLLoader( );
		@terrainLoader.load( "models/env.if3d", @onTerrainLoaded, @onTerrainProgress );


		# @skyLoader = new ifl.IFLLoader( );
		# @skyLoader.load( "models/sky_textures.if3d", @initSky );
		@initSky()
		@materialManager = new MaterialManager(@terrainLoader,@skyCubeTexture)
	
		@loader = new ifl.IFLLoader( );
		@loader.load "models/balloon.if3d", (iflscene) =>
			iflscene.scale.set(.05,.05,.05)
			@scene.add iflscene
		

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
		path = "models/oldtex/"
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


		@skyCube = new THREE.Mesh( geom, material )
		@skyCube.name = "skyCube"
		@scene.add @skyCube
		return
	

	onTreeLoaded: (iflscene) =>

		# iflscene.position.set(0,35,0)
		trees = []

		for child in iflscene.children
			geom = child.geometry

			# basic = new THREE.MeshBasicMaterial
			# 	map: geom.materials[1].map
			# 	doubleSided: true
			# 	transparent: true
			# 	depthWrite: false
			# 	ambient: new THREE.Color(0x333333)
			# geom.materials[1] = basic

			geom.materials[1].transparent = true
			geom.materials[1].doubleSided = true
			geom.materials[1].depthWrite = false
			geom.materials[1].ambient = new THREE.Color(0x333333)
			geom.materials[1].emissive = new THREE.Color(0x333333)

			geom.materials[0].ambient = new THREE.Color(0x333333)
			geom.materials[0].emissive = new THREE.Color(0x333333)


			trees.push( geom )


		start = new THREE.Vector3( 0,1000,0 )
		down = new THREE.Vector3( 0, -1, 0 )
		plantedTrees = 0
		treesMesh = []
		clouds = 0
		grass = 0
		t = new Date().getTime();


		@cloudsGeometry = new THREE.Geometry()
		@grassGeometry = new THREE.Geometry()

		@terrain.geometry.computeCentroids()
		
		for face in @terrain.geometry.faces
			vertex = face.centroid

			isAtTreesLevel = (-45 < vertex.y < -15) and  (-200 < vertex.x < 200) and (-200 < vertex.z < 200)
			isAtCloudsLevel = (-40 < vertex.y < -20) and  (-250 < vertex.x < 250) and (-250 < vertex.z < 250)

			if Math.random() < .09 and isAtTreesLevel
				treeind = Math.floor(Math.random()*trees.length)

				rand = -1 + Math.random() * 2

				tree = new THREE.Mesh( trees[  treeind  ] , new THREE.MeshFaceMaterial)
				tree.matrixAutoUpdate = false;
				tree.position.set( vertex.x+rand, vertex.y+34.6, vertex.z-rand )
				tree.scale.set( .13,.13,.13)
				tree.rotation.y = Math.random()*Math.PI*2
				tree.updateMatrix();
				tree.castShadow = tree.receiveShadow = false;
				treesMesh.push(tree)
				#@scene.add( tree )

				plantedTrees++

			if Math.random() < .03 and isAtCloudsLevel
				vert = new THREE.Vector3(vertex.x,vertex.y+60,vertex.z)
				vert.origy = vert.y
				vert.speed = .5 + Math.random() /2
				@cloudsGeometry.vertices.push( vert )
				clouds++


			averagecolor = face.vertexColors[0]#new THREE.Color( (face.vertexColors[0].getHex() * face.vertexColors[1].getHex() * face.vertexColors[2].getHex()) / (0xFFFFFF*3) )

			if averagecolor.r == 0 and averagecolor.g == 0 and averagecolor.b == 0 and Math.random() < .1 and isAtTreesLevel
				vert = new THREE.Vector3(vertex.x,vertex.y+36,vertex.z)
				@grassGeometry.vertices.push( vert )
				for i in [0...50] by 1

					vert = new THREE.Vector3(vertex.x+(10-Math.random()*20),vertex.y+35,vertex.z+(10-Math.random()*20))
					@grassGeometry.vertices.push( vert )

				grass++

		# grassSprite = THREE.ImageUtils.loadTexture( "models/grassBlade.png" );
		# grassMaterial = new THREE.ParticleBasicMaterial( { size: 2, map: grassSprite, depthWrite: false, transparent : true, lights:false } );		
		# grassParticleSystem = new THREE.ParticleSystem( @grassGeometry, grassMaterial );
		# @scene.add(grassParticleSystem)

		
		@scene.add(obj) for obj in treesMesh 

	
		cloudsParticleSystem = new THREE.ParticleSystem( @cloudsGeometry, @materialManager.getCloudMaterial() );
		@scene.add(cloudsParticleSystem)

		console.log "clouds: #{clouds}, trees: #{plantedTrees} in #{(new Date().getTime()-t)/1000}"
		$( "#loading" ).remove()

	onTerrainProgress:(loaded,total) =>
		$( "#progressbar" ).progressbar( "option", "value", (loaded*100)/total );

	onTerrainLoaded: (iflscene) =>
		
		for child in iflscene.children
			
			if child.name.indexOf("terrain") != -1
				child.material = @materialManager.getTerrainLambertMaterial()
				# child.material = @getTerrainMaterial()

				@terrain = child
				child.receiveShadow = child.castShadow = true

			else if child.name.indexOf("lake") != -1

					@lake = child
					child.material = @materialManager.getLakeMaterial()
					child.castShadow = child.receiveShadow = false

			#else
				#child.material.ambient = child.geometry.materials[0].ambient = new THREE.Color(0x999999)
				#child.castShadow = child.receiveShadow = false

		iflscene.position.set(0,35,0)
		@scene.add( iflscene )

		#animate animated meshes
		# for mesh in iflscene.children when mesh.geometry?.animation?
		# 	THREE.AnimationHandler.add( mesh.geometry.animation )
		# 	animation = new THREE.Animation( mesh, mesh.geometry.animation.name )
		# 	animation.JITCompile = false
		# 	animation.interpolationType = THREE.AnimationHandler.LINEAR
		# 	animation.play()


		# @trees = []

		@loader = new ifl.IFLLoader( );
		@loader.load( "models/trees.if3d", @onTreeLoaded );

		# @loader = new ifl.IFLLoader( );
		# @loader.load( "models/tree2.if3d", @onTreeLoaded );

		# @loader = new ifl.IFLLoader( );
		# @loader.load( "models/tree3.if3d", @onTreeLoaded );		

		return null

	animate: =>
		window.requestAnimationFrame( @animate )
		@render()
		@stats.update()
		return

	render: =>
		delta = @clock.getDelta()

		# animate clouds
		if @cloudsGeometry?
			for vertex in @cloudsGeometry.vertices
				speed = @clock.oldTime/2000
				vertex.y = vertex.origy + Math.sin(speed*vertex.speed) * 5

			@cloudsGeometry.verticesNeedUpdate = true;

		#animate lake normals
		#@lake?.material.uniforms["uOffset"].value.x += delta/50
		@lake?.material.uniforms["uOffset"].value.y += delta/40


		@renderer.clear()
		@controls.update()
		#@renderer.render( @scene, @camera )
		@composer.render(0.1)
		THREE.AnimationHandler.update( delta )
		return
	

	onWindowResize: =>
		@camera.aspect = window.innerWidth / window.innerHeight
		@camera.updateProjectionMatrix()
		@renderer.setSize( window.innerWidth, window.innerHeight )
		@renderTarget.width = window.innerWidth
		@renderTarget.height = window.innerHeight
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