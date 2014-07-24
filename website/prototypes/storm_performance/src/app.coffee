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
		@camera.position.z = 30;
		# @camera.position.z = -30;
		# @camera.position.x = -20;
		# @camera.position.y = -5;
		@camera.target = new THREE.Vector3( 0, 0, 0 );

		@scene = new THREE.Scene();
		#@scene.fog = new THREE.Fog( 0xFFFFFF, 100, 500 );
		#@scene.fog.color.setRGB(1,1,1)


		ambient = new THREE.AmbientLight 0xFFFFFF
		@scene.add( ambient )

		@initSky()
		@terrainLoader = new IFLLoader( );
		@terrainLoader.sky = @skyCubeTexture
		@terrainLoader.load( "models/storm.if3d", @onTerrainLoaded, @onTerrainProgress );

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
		

		cubeShader = THREE.ShaderUtils.lib[ "cube" ]
		cubeShader.uniforms[ "tCube" ].value = @skyCubeTexture
		cubeShader.uniforms[ "tFlip" ].value = true
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
		
		# @scene.add( iflscene )
		
		@sph = new THREE.Mesh( new THREE.SphereGeometry(1), new THREE.MeshBasicMaterial({color:0xFF0000,wireframe:true}))
		@scene.add(@sph)
		$( "#loading" ).remove()
		@createParticleSystem(iflscene)
		return

		mesh = iflscene.children[0].children[0];
		
		shader = new IFLPhongFresnelShader

		geom = new THREE.PlaneGeometry(4.8,4.8)
		
		mat = new THREE.ShaderMaterial({
		vertexShader:shader.vertexShader
		fragmentShader:shader.fragmentShader
		uniforms:shader.uniforms
		})

		mat.map = shader.uniforms["map"].value = THREE.ImageUtils.loadTexture("models/trans2.png")
		mat.normalMap = shader.uniforms["normalMap"].value = THREE.ImageUtils.loadTexture("models/sphere_normal.png")
		mat.envMap = shader.uniforms["envMap"].value = @skyCubeTexture
		mat.lights = false
		mat.transparent = true
		mat.depthWrite = false

		@particle = new THREE.Object3D
		@particle.matrixAutoUpdate = false
		@particle.position.y = -5
		@particle.rotation.x = Math.PI

		for vertex in mesh.geometry.vertices
			pl = new THREE.Mesh(geom,mat)
			pl.growSpeed = 0.5 + Math.random()
			pl.matrixAutoUpdate = false

			# vertex.multiplyScalar(2)

			pl.position.copy(vertex)
			pl.updateMatrix()
			@particle.add(pl)


		@scene.add(@particle)


		return null

	createParticleSystem:(iflscene)->
		mesh = iflscene.children[0].children[0];

		shader = new IFLStormParticleShader

		mat = new THREE.ShaderMaterial({
			vertexShader:shader.vertexShader
			fragmentShader:shader.fragmentShader
			uniforms:shader.uniforms
			blending : THREE.AdditiveBlending
			})
		
		mat.transparencyMap = THREE.ImageUtils.loadTexture("models/sphere_trans.png")
		mat.normalMap = THREE.ImageUtils.loadTexture("models/sphere_normal.png")
		mat.envMap =  @skyCubeTexture
		mat.transparent = true
		# mat.depthWrite = false
		# mat.depthTest  = true
		# mat.alphaTest = 0.99

		mat.lights = false
		mat.sizeAttenuation = true

		shader.uniforms.transparencyMap.value = mat.transparencyMap
		shader.uniforms.normalMap.value = mat.normalMap
		shader.uniforms.envMap.value = mat.envMap
		shader.uniforms.size.value = 10000

		@particle = new THREE.ParticleSystem(mesh.geometry, mat)
		@particle.position.y = -5
		@particle.rotation.x = Math.PI
		@particle.sortParticles = true
		@scene.add @particle




		# gui = new dat.GUI
		# gui.add(@particle,"sortParticles")
		# gui.add(mat,"depthWrite")
		# gui.add(mat,"depthTest")
		# gui.add(shader.uniforms.alpha,"value",0,1).name("alpha")
		# gui.add(shader.uniforms.normalScale,"alphaTest",0,1)
		# gui.add(mat,"transparent")		
		return

	animate: =>
		window.requestAnimationFrame( @animate )
		@render()
		@stats.update()
		return

	render: =>
		delta = @clock.getDelta()
		@renderer.clear()

		
		if @particle?

			mat = new THREE.Matrix4();

			@particle.rotation.y -= .01
			@particle.updateMatrix()
			
			inv = mat.getInverse @particle.matrix 


			for pl in @particle.children

				ran = 1 + Math.sin(@clock.oldTime/(500*pl.growSpeed)) / 2
				min = 0.5
				max = 1.2
				exc = max - min
				# ran : 1 = x : exec
				ran = min + (ran * exc)

				# ran = Math.min(1.3,Math.max(0.7,ran))

				pl.scale.set(ran,ran,1)	
				pl.lookAt(@camera.position)
				pl.updateMatrix()
				pos = pl.position.clone()

				pl.matrix.multiply(inv,pl.matrix)
				pl.matrix.setPosition(pos)
		


		@sph?.position.x = Math.sin(@clock.oldTime/1600)*10
		@controls.update()
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