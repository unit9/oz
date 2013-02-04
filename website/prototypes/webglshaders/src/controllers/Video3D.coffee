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
    texture             : null
    shaderMaterial      : null

    # Shader
    shader              : 5

    # 3D Scene dimensions
    AREA_WIDTH          : window.innerWidth - 10
    AREA_HEIGHT         : window.innerHeight - 88 - 10

    constructor: ( video, shader ) ->

        console.log "* Video3D ready"

        @video = video
        @shader = Number shader

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

        # Renderer
        @renderer = new THREE.WebGLRenderer { antialias: true }
        @renderer.setSize @AREA_WIDTH, @AREA_HEIGHT
        @container.appendChild @renderer.domElement

        # Sky
        skyBoxGeometry = new THREE.CubeGeometry 10000, 10000, 10000
        skyBoxMaterial = new THREE.MeshBasicMaterial { color: 0xf3eee8 }
        skyBoxMaterial.side = THREE.BackSide;
        skyBox = new THREE.Mesh skyBoxGeometry, skyBoxMaterial
        @scene.add skyBox
        
        # Video
        # Texture from canvas in Cam object 
        @texture = new THREE.Texture @video.canvas
        @texture.minFilter = THREE.LinearFilter
        @texture.magFilter = THREE.LinearFilter

        # Create a shader
        @shaderMaterial = ShaderManager.shader @shader, @texture
        # material = new THREE.MeshBasicMaterial { map: @texture, wireframe: true }

        # Create a plane
        planeGeom = new THREE.PlaneGeometry 200, 160, 1, 1

        @plane = new THREE.Mesh planeGeom, @shaderMaterial
        @scene.add @plane

        # Shader process
        ShaderManager.process @shader, { plane: @plane }
        
        # Render
        THREEx.WindowResize @renderer, @camera

        # setTimeout @changeShader, 3000, 0
        # setTimeout @changeShader, 8000, 1

        @startRender()
    
    changeShader: ( num ) =>

        @scene.remove @plane

        @plane.deallocate()
        @plane.geometry.deallocate()
        @plane.material.deallocate()

        @renderer.deallocateObject @plane
        @renderer.deallocateMaterial @plane.material

        # @renderer.deallocateTexture @texture

        @shader = num
        # @texture = new THREE.Texture @video.canvas
        @shaderMaterial = ShaderManager.shader @shader, @texture
        @planeGeom = new THREE.PlaneGeometry 200, 160, 20, 20
        @plane = new THREE.Mesh @planeGeom, @shaderMaterial
        @scene.add @plane
        ShaderManager.process @shader, { plane: @plane }

        # @plane.material = ShaderManager.shader @shader, @texture

        console.log( "after", @renderer.info.memory.programs );

        

# -----------------------------------------------------
# Render
# -----------------------------------------------------
    
    render: =>
        
        # Update video texture
        if @texture
            @texture.needsUpdate = true

        # Update shader
        ShaderManager.render @shader, { plane: @plane, elapsedTime: @clock.getElapsedTime() }

        # Render
        @renderer.render @scene, @camera

    startRender: =>

        requestAnimationFrame @startRender
        @render()

