class App

    container       : null
    stats           : null
    camera          : null
    scene           : null
    renderer        : null
    controls        : null
    clock           : null

    skyCubeTexture  : null
    skyCube         : null

    terrainLoader   : null

    # Particles
    mesh                : null
    particles           : null
    uniforms            : null
    attributes          : null
    numberOfParticles   : 100
    numberOfPlanes      : 1
    particleSize        : 5

    planes              : null

    constructor: ->

        @clock =  new THREE.Clock()

        @container = document.createElement 'div'
        document.body.appendChild @container

        @renderer = new THREE.WebGLRenderer { antialias:false, clearColor: 0x000000, clearAlpha: 1 }
        @renderer.autoClear = false
        @renderer.gammaOutput = false
        @renderer.gammaInput = false
        @renderer.sortObjects = true
        @renderer.shadowMapEnabled = false
        @renderer.shadowMapSoft = true
        @renderer.setSize window.innerWidth, window.innerHeight

        @camera = new THREE.PerspectiveCamera 50, window.innerWidth / window.innerHeight, 1, 5000
        @camera.position.z = 30
        @camera.target = new THREE.Vector3 0, 0, 0

        @scene = new THREE.Scene()

        ambient = new THREE.AmbientLight 0xFFFFFF
        @scene.add ambient

        @initSky()
        @terrainLoader = new IFLLoader()
        @terrainLoader.sky = @skyCubeTexture
        @terrainLoader.load "models/storm.if3d", @onTerrainLoaded, @onTerrainProgress

        @container.appendChild @renderer.domElement
        
        @controls = new THREE.OrbitControls @camera, @renderer.domElement

        @stats = new Stats()
        @stats.domElement.style.position = 'absolute'
        @stats.domElement.style.top = '0px'
        @container.appendChild @stats.domElement

        window.addEventListener 'resize', @onWindowResize, false

        @animate()
        $("body").append "<div id='loading'>Loading Resources<div>"
        $("#loading").append "<div id='progressbar'></div>"
        $("#progressbar").progressbar { value: 0 }
        @onWindowResize()

        return
    
    initSky : (iflscene) =>

        geom = new THREE.CubeGeometry 2000, 2000, 2000

        # material
        path = "models/"
        format = '.png'
        urls = [
            path + 'posx' + format
            path + 'negx' + format
            path + 'posy' + format
            path + 'negy' + format
            path + 'negz' + format
            path + 'posz' + format
        ]

        @skyCubeTexture = THREE.ImageUtils.loadTextureCube urls ,null, onload
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
            sizeAttenuation: true

        @skyCube = new THREE.Mesh geom, material
        @skyCube.name = "skyCube"
        @scene.add @skyCube
        return    

    onTerrainProgress:(loaded,total) =>

        $( "#progressbar" ).progressbar "option", "value", ( loaded * 100 ) / total

    onTerrainLoaded: (iflscene) =>

        @mesh = iflscene.children[0].children[0]

        # Add sphere
        @sph = new THREE.Mesh new THREE.SphereGeometry(1), new THREE.MeshBasicMaterial({color:0xFF0000,wireframe:true}) 
        @scene.add(@sph)

        # Remove loading
        $( "#loading" ).remove()

        # Partciles
        @addParticles()

        # Container for the planes         
        @addPlanes()

        gui = new dat.GUI
        gui.add @particles, "sortParticles"
        particleNumberController = gui.add @, "numberOfParticles", 100, @mesh.geometry.vertices.length
        planesNumberController = gui.add @, "numberOfPlanes", 1, @mesh.geometry.vertices.length
        particleSizeController = gui.add @, "particleSize", 5, 20

        particleNumberController.onFinishChange (value) =>

            @clean()
            @numberOfParticles = parseInt @numberOfParticles
            @addParticles()

        planesNumberController.onFinishChange (value) =>

            @cleanPlanes()
            @numberOfPlanes = parseInt @numberOfPlanes
            @addPlanes()

        particleSizeController.onFinishChange (value) =>

            for i in [0...@attributes.size.value.length]

                @attributes.size.value[ i ] = Math.random() * parseInt value

    addParticles: =>

        shaderMaterial = @getMaterial()
        
        geometry = new THREE.Geometry()

        for v in [0...@numberOfParticles]
            geometry.vertices.push @mesh.geometry.vertices[ v ]

        @particles = new THREE.ParticleSystem geometry, shaderMaterial
        @particles.dynamic = true
        @particles.scale.set 1.0, -1.0, 1.0
        @particles.sortParticles = true
        @particles.position.y = -5

        for v in [0...@particles.geometry.vertices.length]
            @attributes.size.value[ v ] = Math.random() * 5
            @attributes.customColor.value[ v ] = new THREE.Color( 0xffaa00 )
            c = 0.1 + 0.1 * ( v / @particles.geometry.vertices.length )
            @attributes.customColor.value[ v ].setRGB(c, c, c)

        @scene.add @particles

    addPlanes: =>

        @planes = new THREE.Object3D
        @planes.matrixAutoUpdate = false
        @planes.position.y = -5
        @planes.rotation.x = Math.PI
        @scene.add(@planes)

        geom = new THREE.PlaneGeometry 4.8, 4.8

        mat = @getFresnelShader()

        for vertex in [0..@numberOfPlanes]

            pl = new THREE.Mesh(geom,mat)
            pl.growSpeed = 0.5 + Math.random()
            pl.matrixAutoUpdate = false
            pl.position.copy(@mesh.geometry.vertices[vertex])
            pl.updateMatrix()
            @planes.add(pl)

    getMaterial: () =>

        @attributes = {
            size: { type: 'f', value: [] },
            customColor: { type: 'c', value: [] }
        }

        @uniforms = {
            amplitude: { type: "f", value: 10.0 },
            color:     { type: "c", value: new THREE.Color( 0xffffff ) },
            texture:   { type: "t", value: THREE.ImageUtils.loadTexture( "models/trans2.png" ) }
        }
        
        shaderMaterial = new THREE.ShaderMaterial
            uniforms: @uniforms,
            attributes: @attributes,
            vertexShader: document.getElementById('vertexshader').textContent,
            fragmentShader: document.getElementById('fragmentshader').textContent,
            blending: THREE.NormalBlending,
            depthTest: false,
            sizeAttenuation: false,
            transparent: true

        shaderMaterial

    getFresnelShader: =>

        shader = new IFLPhongFresnelShader
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

        mat

    clean: =>

        console.log "before", @renderer.info.memory.programs
        
        @scene.remove @particles
        @renderer.deallocateMaterial @particles.material
        
        console.log "after", @renderer.info.memory.programs

    cleanPlanes: =>

        console.log "before", @renderer.info.memory.programs
        @scene.remove @planes
        console.log "after", @renderer.info.memory.programs

    animate: =>

        window.requestAnimationFrame( @animate )
        @render()
        @stats.update()
        return

    render: =>
        delta = @clock.getDelta()
        @renderer.clear()

        time = Date.now() * 0.0009

        if @particles?

            @particles.rotation.y -= .01
            # console.log @attributes.size.value
            ###
            for i in [0...@attributes.size.value.length]
                d = @particles.geometry.vertices[ i ].distanceTo @camera.position
                size = 50 / d
                @attributes.size.value[ i ] = (13 * Math.sin( 0.1 * i + time ))
            ###
            # @attributes.size.needsUpdate = true

        if @planes?

            mat = new THREE.Matrix4()

            @planes.rotation.y -= .01
            @planes.updateMatrix()
            
            inv = mat.getInverse @planes.matrix 

            for pl in @planes.children

                ran = 1 + Math.sin(@clock.oldTime / ( 500 * pl.growSpeed ) ) / 2
                min = 0.5
                max = 1.2
                exc = max - min
                ran = min + (ran * exc)

                pl.scale.set(ran,ran,1) 
                pl.lookAt(@camera.position)
                pl.updateMatrix()
                pos = pl.position.clone()

                pl.matrix.multiply(inv,pl.matrix)
                pl.matrix.setPosition(pos)

        @sph?.position.x = Math.sin(@clock.oldTime/1600)*10
        
        @controls.update()
        @renderer.render( @scene, @camera )
        THREE.AnimationHandler.update delta

        return    

    onWindowResize: =>

        @camera.aspect = window.innerWidth / window.innerHeight
        @camera.updateProjectionMatrix()
        @renderer.setSize window.innerWidth, window.innerHeight
        
        $( "#loading" ).css
            'position': 'absolute'
            'width' : 400
            "height": 100
            'left': window.innerWidth/2 - 200
            'top': window.innerHeight/2 - 50

        return
    
# bootstrap
$ ->
    $(document).ready ->
        if !Detector.webgl or !Detector.workers
            Detector.addGetWebGLMessage()
        else
            new App