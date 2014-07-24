class Scene3D

    container: null
    renderer: null
    scene: null
    camera: null
    clock: null

    floor: null
    cube: null

    constructor: ( ) ->

        console.log "* Scene3D ready"

        @build()

    build: ( ) ->

        # Clock
        @clock = new THREE.Clock()
        @clock.start()

        # Grab our container div
        @container = document.getElementById "container"

        # Create the Three.js renderer, add it to our div
        @renderer = new THREE.WebGLRenderer( { clearColor: 0x000000, clearAlpha: 1, antialias: true })
        @renderer.setSize @container.offsetWidth, @container.offsetHeight
        @renderer.sortObjects = false
        @container.appendChild @renderer.domElement

        # Create a new Three.js scene
        @scene = new THREE.Scene()
        @scene.fog = new THREE.FogExp2 0x000000, 0.0003

        # Create a camera and add it to the scene
        @camera = new THREE.PerspectiveCamera 25, @container.offsetWidth / @container.offsetHeight, 1, 10000
        @camera.position.set 0, 100, 1500
        @scene.add @camera

        # Create a directional light to show off the object
        light = new THREE.PointLight 0xff0040, 2, 500
        light.position.set 0, 10, 200
        @scene.add light

        # Particle
        particleGeom = new THREE.SphereGeometry 20, 10, 10
        particle = new THREE.Mesh particleGeom, new THREE.MeshDepthMaterial( { wireframe: true } )
        particle.position.set 0, 10, 200
        @scene.add particle

        # Floor
        planeSimple = new THREE.PlaneGeometry 200, 300
        matSolid = new THREE.MeshBasicMaterial { color :0x151515 }
        floor = new THREE.Mesh planeSimple, matSolid
        floor.position.y = -10
        floor.rotation.x = - Math.PI / 2
        floor.scale.set 25, 25, 25
        @scene.add floor

        planeTesselated = new THREE.PlaneGeometry 100, 300, 40, 40
        matWire = new THREE.MeshBasicMaterial { color :0x444444, wireframe: true, wireframeLinewidth: 1 }
        floor = new THREE.Mesh planeTesselated, matWire
        floor.position.y = -9
        floor.rotation.x = - Math.PI / 2
        floor.scale.set 25, 25, 25
        @scene.add floor
        
        # Random convex
        materials = [
            # new THREE.MeshPhongMaterial { color: 0xFF0000, wireframe: false }
            # new THREE.MeshLambertMaterial { color: 0xdddddd, shading: THREE.FlatShading }
            # new THREE.MeshBasicMaterial( { color: 0xFF0000, blending: THREE.AdditiveBlending, transparent: true, depthWrite: false } )
            new THREE.MeshPhongMaterial( { ambient: 0xFF0000, color: 0xdddddd, specular: 0x009900, shininess: 60, shading: THREE.FlatShading } )
            # new THREE.MeshPhongMaterial( { color: 0xffffff, wireframe: true, transparent: true, opacity: 1.0 } )
        ]
        points = [];
        for i in [0..30]
            points.push @randomPointInSphere 10

        object = THREE.SceneUtils.createMultiMaterialObject new THREE.ConvexGeometry( points ), materials
        object.position.set 0, 50, 0
        object.scale.set 5, 25, 5
        @scene.add object

        # Render it
        @startRender()
        THREEx.WindowResize @renderer, @camera

    randomPointInSphere: ( radius ) =>
        
        new THREE.Vector3(
            ( Math.random() - 0.5 ) * 2 * radius,
            ( Math.random() - 0.5 ) * 2 * radius,
            ( Math.random() - 0.5 ) * 2 * radius
            )

# -----------------------------------------------------
# Render
# -----------------------------------------------------
    
    render: =>

        # @camera.position.z -= 10 * Math.sin( @clock.getElapsedTime() );
        # @camera.position.x += 2 * Math.sin( @clock.getElapsedTime() );
        x = @camera.position.x
        y = @camera.position.y
        z = @camera.position.z
        rotSpeed = 0.002

        @camera.position.x = x * Math.cos(rotSpeed) + z * Math.sin(rotSpeed);
        @camera.position.z = z * Math.cos(rotSpeed) - x * Math.sin(rotSpeed);

        @camera.lookAt @scene.position

        # Render
        @renderer.render @scene, @camera

    startRender: =>

        requestAnimationFrame @startRender
        @render()

