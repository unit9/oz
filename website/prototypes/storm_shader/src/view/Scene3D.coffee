class Scene3D

    container: null
    renderer: null
    scene: null
    camera: null
    clock: null
    controls: null

    floor: null
    cube: null
    materials: null

    tornado: null
    tornadoMat: null
    shaderCloud: null
    shaderTornado : null
    matTornado : null

    tornadoVisible : false

    parts   : []

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
    
        # Create a camera and add it to the scene
        @camera = new THREE.PerspectiveCamera 50, @container.offsetWidth / @container.offsetHeight, 1, 100000
        @camera.position.set 0, 0, 4000
        @camera.target = new THREE.Vector3 0, 0, 0
        @scene.add @camera

        # Controls
        @controls = new THREE.OrbitControls @camera, @renderer.domElement

        # Light
        light = new THREE.DirectionalLight 0xffffff
        light.position.set 0, 1, 0
        @scene.add light

        @stats = new Stats()
        @stats.domElement.style.position = 'absolute'
        @stats.domElement.style.top = '50px'
        @container.appendChild @stats.domElement

        # Random convex
        @materials = [ ]   

        ###
        new THREE.MeshBasicMaterial({color:0x000000,wireframe: false})
            new THREE.MeshPhongMaterial
                    ambient: 0xFF0000
                    color: 0xdddddd
                    specular: 0xFFFFFFF
                    shininess: 10
                    shading: THREE.SmoothShading
                    side: THREE.DoubleSide
        ]
        ###
        

        # Shader
        @shaderTornado = new IFLTornadoShader
        @shaderTornado.uniforms[ "time" ].value = 0.0
        @shaderTornado.uniforms[ "resolution" ].value = new THREE.Vector3( window.innerWidth, window.innerHeight, 1 )

        @matTornado = new THREE.ShaderMaterial
            uniforms: @shaderTornado.uniforms
            attributes: null
            vertexShader: @shaderTornado.vertexShader
            fragmentShader: @shaderTornado.fragmentShader
            transparent: true
            side: THREE.DoubleSide


        @shaderCloud = new IFLCloudsShader
        @shaderCloud.uniforms[ "time" ].value = 0.0
        @shaderCloud.uniforms[ "resolution" ].value = new THREE.Vector3( window.innerWidth, window.innerHeight, 1 )

        @tornadoMat = new THREE.ShaderMaterial
            uniforms: @shaderCloud.uniforms
            attributes: null
            vertexShader: @shaderCloud.vertexShader
            fragmentShader: @shaderCloud.fragmentShader
            transparent: true
            side: THREE.DoubleSide

        @materials.push @matTornado

        points = []

        ###
        for i in [0..250]
            _x = Math.sin( i * 0.05 ) * 300 + 800
            _y = 0
            _z = ( i - 125 ) * 12
            points.push new THREE.Vector3(_x, _y, _z)
        ###

        for i in [0..250]
            _x = ( i * 0.05 ) * 100 + 200
            _y = 0
            _z = ( i - 125 ) * 12
            points.push new THREE.Vector3(_x, _y, _z)

        @tornado = THREE.SceneUtils.createMultiMaterialObject new THREE.LatheGeometry( points, 90 ), @materials
        @tornado.rotation.set 90 * Math.PI / 180, 180 * Math.PI / 180, 0
        @scene.add @tornado

        @initSky()
        @debugaxis 5000

        # Add Particles
        delay = (ms, func) -> setTimeout func, ms
        for i in [0..100]
            delay i * 10, () =>
                @parts.push new Particle(@scene, Math.abs(Math.random() * 2))


        # Render it
        @startRender()

        THREEx.WindowResize @renderer, @camera

        gui = new dat.GUI
        gui.add @, "tornadoVisible"

    initSky : () =>

        # material
        path = "models/stormsky/"
        format = '.png';
        urls = [
            path + 'posx' + format
            path + 'negx' + format
            path + 'posy' + format
            path + 'negy' + format
            path + 'negz' + format
            path + 'posz' + format
        ]

        skyText = THREE.ImageUtils.loadTextureCube urls
        skyText.format = THREE.RGBFormat
        
        cubeShader = new IFLSkyCubeShader
        cubeShader.uniforms[ "tCube" ].value = skyText
        cubeShader.uniforms[ "tFlip" ].value = true
        
        material = new THREE.ShaderMaterial
            fragmentShader: cubeShader.fragmentShader
            vertexShader: cubeShader.vertexShader
            uniforms: cubeShader.uniforms
            depthWrite: false
            side: THREE.BackSide

        @skyCube = new THREE.Mesh new THREE.CubeGeometry( 10000, 10000, 10000 ), @tornadoMat
        @skyCube.name = "skyCube"
        @scene.add @skyCube

    debugaxis: (axisLength) =>

        # {x: red, y: green, z: blue}
        @createAxis @v( -axisLength, 0, 0), @v(axisLength, 0, 0), 0xFF0000
        @createAxis @v(0, -axisLength, 0), @v(0, axisLength, 0), 0x00FF00
        @createAxis @v(0, 0, -axisLength), @v(0, 0, axisLength), 0x0000FF

    # Shorten the vertex function
    v: (x, y, z) =>
        new THREE.Vector3 x, y, z

    # Create axis (point1, point2, colour)
    createAxis: (p1, p2, color) =>
        line = new THREE.Geometry
        lineGeometry = new THREE.Geometry
        lineMat = new THREE.LineBasicMaterial {color: color, lineWidth: 1}
        lineGeometry.vertices.push p1, p2
        line = new THREE.Line lineGeometry, lineMat
        @scene.add line

# -----------------------------------------------------
# Render
# -----------------------------------------------------
    
    render: =>

        ###
        x = @camera.position.x
        y = @camera.position.y
        z = @camera.position.z
        rotSpeed = 0.002

        @camera.position.x = x * Math.cos(rotSpeed) + z * Math.sin(rotSpeed);
        @camera.position.z = z * Math.cos(rotSpeed) - x * Math.sin(rotSpeed);
        @camera.lookAt @scene.position
        ###

        for i in [0..100]
            @parts[i]?.update()

        @stats.update()

        @shaderCloud.uniforms[ "time" ].value = @clock.getElapsedTime()
        @shaderTornado.uniforms[ "time" ].value = @clock.getElapsedTime()

        THREE.SceneUtils.traverseHierarchy( @tornado,  ( object ) =>
            object.visible = @tornadoVisible
            )

        @controls.update()

        # Render
        @renderer.render @scene, @camera

    startRender: =>

        requestAnimationFrame @startRender
        @render()

