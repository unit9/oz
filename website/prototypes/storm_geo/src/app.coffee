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

	cloudMeshes		: null
	clouds			: null
	instancedClouds : null
	numClouds 		: 7
	particles 		: []

	cloudMinSpeed : 0.3
	cloudMaxSpeed : 1.7

	noiseMap : null
	noiseShader : null
	noiseScene : null
	noiseMaterial : null
	noiseCameraOrtho : null
	noiseQuadTarget : null
	noiseRenderTarget : null
	noiseSpeed : 0.5

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
		@camera.position.z = 100;
		# @camera.position.z = -30;
		# @camera.position.x = -20;
		# @camera.position.y = -5;
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
		@terrainLoader.load( "models/storm.if3d", @onTerrainLoaded, @onTerrainProgress );

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
		
		@clouds = []
		@cloudMeshes = []
		@instancedClouds = []


		for child in iflscene.children
			if child && child.name.indexOf("cloud") != -1
				child.geometry.computeCentroids()
				@cloudMeshes.push(child)
				console.log "#{child.name} added as template"
			if child && child.name.indexOf("storm") != -1
				@particleGeo = child.geometry
			# if child && child.name.indexOf("baloon") != -1
			# 	child.material = 
			# 	@scene.add child
			# 	@camera.target = child.target
			# 	@baloon = child


		balmat = new THREE.MeshPhongMaterial({lights:true,color:0xCCCCCC,ambient:0x111111})
		@baloon = new THREE.Object3D
		@baloon.add(new THREE.Mesh(new THREE.SphereGeometry(10,10),balmat))
		chest = new THREE.Mesh(new THREE.CubeGeometry(5,5,5),balmat)
		chest.position.set(0,-15,0)
		@baloon.add chest

		@scene.add @baloon



		for i in [0...8]
			partmat = new THREE.ParticleBasicMaterial()
			partmat.transparent = true
			partmat.depthWrite = false
			
			if i < 4
				# partmat.color = 0x111111
				partmat.color = new THREE.Color 0x111111
				partmat.size = Math.random()*5
			else
				partmat.color = new THREE.Color 0xCCCCCC
				partmat.size = 10 + Math.random() * 20

			partmat.map = THREE.ImageUtils.loadTexture("models/trans2.png")


			@particleGeo.computeFaceNormals();
			@particleGeo.computeCentroids();

			#randomize vertices
			for face in @particleGeo.faces
				centroid = face.centroid
				normal = face.normal.clone()

				ran = -0.5 + Math.random() 
				normal.normalize()
				normal.multiplyScalar(ran*30)

				@particleGeo.vertices[face.a].addSelf(normal)

				ran = -0.5 + Math.random()
				normal.normalize()
				normal.multiplyScalar(ran*30)

				@particleGeo.vertices[face.b].addSelf(normal)

				ran = -0.5 + Math.random() 
				normal.normalize()
				normal.multiplyScalar(ran*30)

				@particleGeo.vertices[face.c].addSelf(normal)

			particle = new THREE.ParticleSystem(@particleGeo, partmat )
			particle.rotation.y = Math.random()*Math.PI*2
			s = 0.8 + Math.random() * .2
			# particle.scale.set(s,s,s)
			# particle.sortParticles = true
			particle.position.set(0,-100,0)
			particle.speed = @cloudMinSpeed + Math.random() * (@cloudMaxSpeed-@cloudMinSpeed)
			@scene.add particle
			@particles.push particle


		@createCloudMaterial()
		@onCloudNumberChange(@numClouds);
		# @sph = new THREE.Mesh( new THREE.SphereGeometry(10), new THREE.MeshBasicMaterial({map:@noiseMap}))
		# @scene.add(@sph)

		@gui = new dat.GUI({width:400})
		@gui.add(@,"numClouds",1,20).name("Number of clouds").step(1).onChange @onCloudNumberChange
		@gui.add(@fresnel.uniforms[ "mFresnelPower" ],"value",0,5).name("fresnel power")
		@gui.add(@fresnel.uniforms[ "mFresnelBias" ],"value",0,1).name("fresnel bias")
		@gui.add(@fresnel.uniforms[ "mFresnelGain" ],"value",0,10).name("fresnel gain")
		@gui.add(@fresnel.uniforms[ "reflectivity" ],"value",0,1).name("reflectivity")
		@gui.add(@fresnel.uniforms[ "mDisplacementScale" ],"value",0,100).name("Displ scale")
		@gui.add(@,"noiseSpeed",0,1).name("Displ Speed")
		@gui.addColor({val:[@fresnel.uniforms.diffuse.value.r,@fresnel.uniforms.diffuse.value.g,@fresnel.uniforms.diffuse.value.b]},"val",0,1).name("Diffuse Color").onChange @onDiffuseColorChange
		@gui.add(@fresnel,"depthWrite").name("depthWrite")
		@gui.add(@fresnel,"depthTest").name("depthTest")
		@gui.add(@fresnel,"transparent").name("transparent")
		@gui.add({side:@fresnel.side == THREE.FrontSide},"side").name("Backface Culling").onChange( (value)=> if value then @fresnel.side = THREE.DoubleSide else @fresnel.side = THREE.FrontSide )
		@gui.add(@controls,"enabled").name("Enable Mouse Look")
		@gui.add(@,"cloudMinSpeed",0,2).name("Cloud Min speed").onChange @onCloudSpeedChange
		@gui.add(@,"cloudMaxSpeed",0,5).name("Cloud Max speed").onChange @onCloudSpeedChange

		
		$( "#loading" ).remove()
		


		return null

	onDiffuseColorChange:(value)=>
		@fresnel.uniforms.diffuse.value.setRGB(value[0]/255,value[1]/255,value[2]/255)

	onCloudNumberChange:(value)=>


		for oldcloud in @clouds
			@scene.remove oldcloud

		@clouds = []

		for mesh,counter in @cloudMeshes

			if !@instancedClouds[counter]
				@instancedClouds[counter] = []

			for k in [0...value]

				if !@instancedClouds[counter][k]
					m = new THREE.Mesh(THREE.GeometryUtils.clone(mesh.geometry),mesh.material)
					m.material = @fresnel

					# ran : 1 = x : maxspeed-minspeed
					
					m.speed = @cloudMinSpeed + Math.random() * (@cloudMaxSpeed-@cloudMinSpeed)
					m.rotation.set(0,Math.random()*Math.PI*2,0)
					m.position.set(0,-100 + Math.random() * 10,0)
					s = 0.7 + Math.random() * .3
					m.scale.set(s,1,s)
					@instancedClouds[counter][k] = m

				@scene.add @instancedClouds[counter][k]
				@clouds.push @instancedClouds[counter][k]

	onCloudSpeedChange:(value)=>
		for cloud in @clouds
			cloud.speed = @cloudMinSpeed + Math.random() * (@cloudMaxSpeed-@cloudMinSpeed)

	createCloudMaterial:()->   
        shader = new IFLPhongFresnelShader
        
        uniforms = shader.uniforms

        params = {}
        params.fragmentShader   = shader.fragmentShader
        params.vertexShader     = shader.vertexShader
        params.uniforms         = uniforms
        # params.blending 		= THREE.MultiplyBlending


        material = new THREE.ShaderMaterial( params );
        material.side = THREE.DoubleSide
        material.lights = false
        material.transparent = true
        material.depthWrite = false
        # material.depthTest = false
        # material.alphaTest = 0.7;
        # material.fog = true


        uniforms[ "diffuse" ].value                             = new THREE.Color( 0x000000 )
        uniforms[ "ambient" ].value                             = new THREE.Color( 0xFFFFFF )
        uniforms[ "specular" ].value                            = new THREE.Color( 0xFFFFFF )
        uniforms[ "mFresnelBias" ].value = 0.0
        uniforms[ "mFresnelGain" ].value = 10
        uniforms[ "mFresnelPower" ].value = 1.9
        uniforms[ "reflectivity" ].value = 0.74
        uniforms[ "mDisplacementScale" ].value = 5

        # uniforms[ "map" ].value = material.map                  = @loader.getTexture("roundtent_diff.png")
        uniforms[ "envMap" ].value = material.envMap            = @skyCubeTexture
        # uniforms[ "normalMap" ].value  = material.normalMap     = @loader.getTexture("roundtent_nrml.jpg")
        # uniforms[ "specularMap" ].value = material.specularMap  = @loader.getTexture("roundtent_spec.jpg")
        uniforms[ "tAux" ].value                                = @noiseMap
        @fresnel = material

        return material

	

	animate: =>
		window.requestAnimationFrame( @animate )
		@render()
		@stats.update()
		return

	render: =>
		delta = @clock.getDelta()
		@renderer.clear()


		@noiseShader.uniforms[ "time" ].value += delta * @noiseSpeed
		@noiseShader.uniforms[ "offset" ].value.x += delta * @noiseSpeed
		# @noiseShader.uniforms[ "uOffset" ].value.x = 4 * @noiseShader.uniforms[ "offset" ].value.x;
		# @renderer.render( @noiseScene, @noiseCameraOrtho, @noiseMap, true );
		@renderer.render( @noiseScene, @noiseCameraOrtho ,@noiseMap,true);
		# return

		

		# @renderer.render( @noiseRenderTarget, @noiseCameraOrtho );
		#return

		# if @particle?

		# 	mat = new THREE.Matrix4();

		# 	@particle.rotation.y -= .01
		# 	@particle.updateMatrix()
			
		# 	inv = mat.getInverse @particle.matrix 


		# 	for pl in @particle.children

		# 		ran = 1 + Math.sin(@clock.oldTime/(500*pl.growSpeed)) / 2
		# 		min = 0.5
		# 		max = 1.2
		# 		exc = max - min
		# 		# ran : 1 = x : exec
		# 		ran = min + (ran * exc)

		# 		# ran = Math.min(1.3,Math.max(0.7,ran))

		# 		pl.scale.set(ran,ran,1)	
		# 		pl.lookAt(@camera.position)
		# 		pl.updateMatrix()
		# 		pos = pl.position.clone()

		# 		pl.matrix.multiply(inv,pl.matrix)
		# 		pl.matrix.setPosition(pos)
		

		if @clouds
			for cloud in @clouds
				# cloud.geometry.faces.sort(@centroidSort)
				cloud.rotation.y -= cloud.speed * delta


		for particSystem in @particles
				particSystem.rotation.y -= particSystem.speed * delta


		if @baloon
			t = @clock.oldTime/3000
			@baloon.position.x = Math.sin(t)*150

			if !@controls.enabled
				r = 50;
				camX = @baloon.position.x + (r * Math.cos(t))
				camZ = @baloon.position.z + (r * Math.sin(t) * 2)

				@camera.position.set(camX,@baloon.position.y,camZ)
				@camera.lookAt(@baloon.position)



		@sph?.position.x = Math.sin(@clock.oldTime/1600)*200
		@controls?.update() if @controls?.enabled
		@renderer.render( @scene, @camera )
		THREE.AnimationHandler.update( delta )
		return
	
	centroidSort: ( a, b )=>
		a_dist = a.centroid.distanceTo(@camera.position)
		b_dist = b.centroid.distanceTo(@camera.position)
		return b_dist - a_dist;

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