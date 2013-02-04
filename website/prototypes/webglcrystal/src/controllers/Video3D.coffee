class Video3D

    # 
    video               : null # Video source ( Cam Object )
    container           : null # Render DOM Element
    
    # 3D Scene
    scene               : null
    camera              : null
    renderer            : null
    clock               : null
    plane               : null
    cube                : null
    texture             : null
    shaderMaterial      : null

    # Shader
    shader              : 1

    # 3D Scene dimensions
    AREA_WIDTH          : window.innerWidth - 10
    AREA_HEIGHT         : window.innerHeight - 88 - 10

    constructor: ( video ) ->

        console.log "* Video3D ready"

        @video = video

        @build()

    build: =>

        # Container
        @container = document.createElement "div"
        @container.style.cssText = "position:absolute; top: 88px; left:0px; width: #{@AREA_WIDTH}px; height: #{@AREA_HEIGHT}px; z-index: -1; border: 5px solid red";
        document.body.appendChild @container
        
        # Scene
        @scene  = new THREE.Scene

        # Clock
        @clock = new THREE.Clock
        @clock.start()

        # Camera
        @camera = new THREE.PerspectiveCamera 50, window.innerWidth / window.innerHeight, 1, 10000        
        @camera.position.set 0, 0, 250
        @scene.add @camera

        # LIGHTS
        ambient = new THREE.AmbientLight 0xffffff
        @scene.add ambient

        pointLight = new THREE.PointLight 0xffffff, 2
        @scene.add pointLight

        # Renderer
        @renderer = new THREE.WebGLRenderer { antialias: true }
        @renderer.setSize @AREA_WIDTH, @AREA_HEIGHT
        @container.appendChild @renderer.domElement

         # Texture from canvas in Cam object 
        @texture = new THREE.Texture @video.canvas
        @texture.minFilter = THREE.LinearFilter
        @texture.magFilter = THREE.LinearFilter

        # Sky
        r = "images/sky/";
        urls = [ r + "px.jpeg", r + "nx.jpeg", r + "py.jpeg", r + "ny.jpeg", r + "pz.jpeg", r + "nz.jpeg" ]

        textureCube = THREE.ImageUtils.loadTextureCube( urls, new THREE.CubeRefractionMapping() );

        shader = THREE.ShaderUtils.lib[ "cube" ]
        shader.uniforms[ "tCube" ].value = textureCube;
        skyBoxMaterial = new THREE.ShaderMaterial {
            fragmentShader: shader.fragmentShader,
            vertexShader: shader.vertexShader,
            uniforms: shader.uniforms,
            side: THREE.BackSide
        }


        skyBoxGeometry = new THREE.CubeGeometry 10000, 10000, 10000
        # skyBoxMaterial = new THREE.MeshBasicMaterial { color: 0x000000 }
        # skyBoxMaterial.side = THREE.BackSide;
        skyBox = new THREE.Mesh skyBoxGeometry, skyBoxMaterial
        @scene.add skyBox   

        materials = [
                    new THREE.MeshLambertMaterial { ambient: 0xbbbbbb, map: textureCube },
                    new THREE.MeshBasicMaterial { color: 0xccddff, envMap: textureCube, refractionRatio: 0.48, reflectivity:0.9 }
                ];

        object = THREE.SceneUtils.createMultiMaterialObject new THREE.CubeGeometry(100, 150, 80, 10, 10, 10), materials
        object.position.set 0, 0, 0
        @scene.add object
        
        # Video
        # Create a shader
        @shaderMaterial = ShaderManager.shader @shader, @texture

        # Create cube
        cubeGeom = new THREE.CubeGeometry 100, 150, 80, 10, 10, 10
        @cube = new THREE.Mesh cubeGeom, @shaderMaterial
        @cube.rotation.y = 45

        @scene.add @cube

        # Create a plane
        planeGeom = new THREE.PlaneGeometry 200, 160, 1, 1

        # @plane = new THREE.Mesh planeGeom, @shaderMaterial
        # @scene.add @plane

        # Shader process
        ShaderManager.process @shader, { plane: @cube }
        
        # Render
        THREEx.WindowResize @renderer, @camera

        @startRender()
        

# -----------------------------------------------------
# Render
# -----------------------------------------------------
    
    render: =>

        @cube.rotation.y = Math.sin @clock.getElapsedTime() / 10

        # Update video texture
        if @texture
            @texture.needsUpdate = true

        # Update shader
        ShaderManager.render @shader, { plane: @cube, elapsedTime: @clock.getElapsedTime() }

        # Render
        @renderer.render @scene, @camera

    startRender: =>

        requestAnimationFrame @startRender
        @render()

