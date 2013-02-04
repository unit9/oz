class App
	container 	: null
	stats 		: null
	camera 		: null
	scene 		: null
	projector  	: null
	renderer 	: null
	controls 	: null
	mesh 		: null
	clock = new THREE.Clock();

	constructor: ->
		@container = document.createElement( 'div' );
		document.body.appendChild( @container );


		@camera = new THREE.PerspectiveCamera( 50, window.innerWidth / window.innerHeight, 1, 10000 );
		@camera.position.z = 500;
		@camera.target = new THREE.Vector3( 0, 0, 0 );

		@scene = new THREE.Scene();

		

		@light = new THREE.DirectionalLight( 0xefefff, 2 );
		@light.position.set( 1, 1, 1 ).normalize();
		@scene.add( @light );

		@light = new THREE.DirectionalLight( 0xffefef, 2 );
		@light.position.set( -1, -1, -1 ).normalize();
		@scene.add( @light );


		@loader = new ifl.IFLLoader( );
		@loader.load( "models/boy.if3d", @onModelLoaded, @onModelProgress );

		# @loader = new ifl.IFLLoader( );
		# @loader.load( "models/creature.if3d", @onModelLoaded, @onModelProgress );

		# @loader = new ifl.IFLLoader( );
		# @loader.load( "models/test.if3d", @onModelLoaded, @onModelProgress );

		# @loader = new ifl.IFLLoader( );
		# @loader.load( "models/test2.if3d", @onModelLoaded, @onModelProgress );		

		@renderer = new THREE.WebGLRenderer({antialias:true});
		@renderer.sortObjects = false;
		@renderer.setSize( window.innerWidth, window.innerHeight );

		@container.appendChild(@renderer.domElement);

		
		radius = @camera.position.z;
		@controls = new THREE.TrackballControls( @camera, @renderer.domElement );

		@controls.rotateSpeed = 1.0;
		@controls.zoomSpeed = 1.2;
		@controls.panSpeed = 0.2;

		@controls.noZoom = false;
		@controls.noPan = false;

		@controls.staticMoving = false;
		@controls.dynamicDampingFactor = 0.3;

		@controls.minDistance = radius / 2;
		@controls.maxDistance = radius * 100;

		@controls.keys = [ 65, 83, 68 ]


		@stats = new Stats();
		@stats.domElement.style.position = 'absolute';
		@stats.domElement.style.top = '0px';

		@container.appendChild( @stats.domElement );

		window.addEventListener( 'resize', @onWindowResize, false );

		@animate()
	
	totalModels : 3;
	modelsLoaded : 0;

	onModelProgress:(data) =>
		#console.log "TOTAL: #{data.total} PROGRESS: #{data.progress}"

	onModelLoaded: (iflscene) =>
		@modelsLoaded++
		#iflscene.position.set(-250+(@modelsLoaded*100),0,0);
		@scene.add( iflscene )

		#animate animated meshes
		for mesh in iflscene.children when mesh.geometry?.animation?
			THREE.AnimationHandler.add( mesh.geometry.animation )
			animation = new THREE.Animation( mesh, mesh.geometry.animation.name )
			animation.JITCompile = false
			animation.interpolationType = THREE.AnimationHandler.LINEAR
			animation.play()
		return null;

	animate: =>
		window.requestAnimationFrame( @animate )
		@render()
		@stats.update()
		return null

	render: =>
		delta = clock.getDelta()
		@controls.update()
		@renderer.render( @scene, @camera )
		THREE.AnimationHandler.update( delta )
		return null
	

	onWindowResize: =>
		@camera.aspect = window.innerWidth / window.innerHeight
		@camera.updateProjectionMatrix()
		@renderer.setSize( window.innerWidth, window.innerHeight )
		@controls.handleResize()
		return null
	
# bootstrap
if !Detector.webgl or !Detector.workers then Detector.addGetWebGLMessage() else new App()