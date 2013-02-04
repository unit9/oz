class Scene3D

    postp           : null

    container       : null
    renderer        : null
    scene           : null
    camera          : null
    clock           : null
    controls        : null

    floor           : null
    cube            : null
    materials       : null

    stats           : null

    constructor: ( ) ->

        @build()

    build: ( ) ->

        # Clock
        @clock = new THREE.Clock()
        @clock.start()

        # Grab our container div
        @container = document.getElementById "container"

        # Create the Three.js renderer, add it to our div
        @renderer = new THREE.WebGLRenderer { antialias: true }
        @renderer.autoClear = false
        @renderer.setSize @container.offsetWidth, @container.offsetHeight
        @renderer.domElement.dispose = () -> return

        @camera = new THREE.PerspectiveCamera 50, @container.offsetWidth / @container.offsetHeight, 10, 100000
        @camera.name = "mainCamera"
        @camera.position.set 0, 200, 2000
        @camera.far = 5000
        @camera.near = 0.1
        
        @scene = new THREE.Scene()

        ambient = new THREE.AmbientLight 0x222222
        @scene.add ambient

        light = new THREE.DirectionalLight 0xFF0000, 2.5
        light.position.set( 200, 200, 0 ).normalize()
        @scene.add light

        @initComposer()
        @addGui()
        @container.appendChild @renderer.domElement

        # Render it
        @startRender()

        @stats = new Stats()
        @stats.domElement.style.position = 'absolute'
        @stats.domElement.style.top = '50px'
        @container.appendChild @stats.domElement

        THREEx.WindowResize @renderer, @camera, @controls

        console.log @camera.fov

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

    addCube: ( x, y, z ) =>

        geometry = new THREE.CubeGeometry 200, 200, 200
        material = new THREE.MeshLambertMaterial { color :0x444444, wireframe: false }
        mesh = new THREE.Mesh geometry, material
        mesh.position.set x, y, z
        
        mesh

    addGui: =>

        # Floor
        planeSimple = new THREE.PlaneGeometry 300, 200
        matSolid = new THREE.MeshBasicMaterial { color :0x151515 }
        floor = new THREE.Mesh planeSimple, matSolid
        floor.position.y = -402
        floor.rotation.x = - Math.PI / 2
        floor.scale.set 25, 25, 25
        @scene.add floor

        planeTesselated = new THREE.PlaneGeometry 300, 200, 40, 40
        matWire = new THREE.MeshBasicMaterial { color :0x444444, wireframe: true, wireframeLinewidth: 1 }
        floor = new THREE.Mesh planeTesselated, matWire
        floor.position.y = -401
        floor.rotation.x = - Math.PI / 2
        floor.scale.set 25, 25, 25
        @scene.add floor

        # Add Cubes
        @scene.add @addCube(0, Math.abs(Math.random() * 400) + 100,100)
        @scene.add @addCube(-400, Math.abs(Math.random() * 400) + 100, 20)
        @scene.add @addCube( 400, Math.abs(Math.random() * 400) + 100, 50)
        @scene.add @addCube( 700, Math.abs(Math.random() * 400) + 100, -50)
        @scene.add @addCube(-1200, Math.abs(Math.random() * 400) + 100, -200)
        @scene.add @addCube(600, Math.abs(Math.random() * 400) + 100, 900)
        @scene.add @addCube(300, Math.abs(Math.random() * 400) + 100, -800)
        @scene.add @addCube(-500, Math.abs(Math.random() * 400) + 100, 1500)

        @debugaxis 5000

    initComposer:() =>

        @postp = 
            enabled:false
            focus:0.98
            aperture:0.019
            maxblur:0.007
            camerafar: 5000
            cameranear: 0.1

        @postp.material_depth = new THREE.MeshDepthMaterial()
        
        @postp.scene = new THREE.Scene()
        @postp.camera = new THREE.OrthographicCamera @container.offsetWidth / - 2, @container.offsetWidth / 2,  @container.offsetHeight / 2, @container.offsetHeight / - 2, -10000, 10000
        @postp.camera.name = "dofCamera"
        @postp.scene.add @postp.camera

        renderTargetParameters =

            minFilter   : THREE.LinearFilter
            magFilter   : THREE.LinearFilter
            format      : THREE.RGBFormat

        @postp.renderTextureScene = new THREE.WebGLRenderTarget @container.offsetWidth, @container.offsetHeight, renderTargetParameters
        @postp.renderTextureDepth = new THREE.WebGLRenderTarget @container.offsetWidth, @container.offsetHeight, renderTargetParameters
        @postp.renderFinal = new THREE.WebGLRenderTarget @container.offsetWidth, @container.offsetHeight, renderTargetParameters
        
        bokeh_shader = THREE.TornadoShader

        @postp.uniforms = THREE.UniformsUtils.clone bokeh_shader.uniforms

        @postp.uniforms[ "tColor" ].value = @postp.renderTextureScene
        @postp.uniforms[ "tDepth" ].value = @postp.renderTextureDepth
        @postp.uniforms[ "focus" ].value = @postp.focus
        @postp.uniforms[ "aperture" ].value = @postp.aperture
        @postp.uniforms[ "maxblur" ].value = @postp.maxblur
        @postp.uniforms[ "aspect" ].value = @container.offsetWidth / @container.offsetHeight

        @postp.materialTornado = new THREE.ShaderMaterial
            uniforms: @postp.uniforms
            vertexShader: document.getElementById( 'vertexshader' ).textContent # bokeh_shader.vertexShader
            fragmentShader: document.getElementById( 'fragmentshader' ).textContent # bokeh_shader.fragmentShader

        @postp.quad = new THREE.Mesh new THREE.PlaneGeometry( @container.offsetWidth, @container.offsetHeight ), @postp.materialTornado
        @postp.scene.add @postp.quad

# -----------------------------------------------------
# Render
# -----------------------------------------------------
    
    render: =>

        #@camera.position.set 0.0, 4.0, 0.0
        #@camera.lookAt @scene.position

        #console.log @scene.position
        
        x = @camera.position.x
        y = @camera.position.y
        z = @camera.position.z
        rotSpeed = 0.002

        @camera.position.x = x * Math.cos(rotSpeed) + z * Math.sin(rotSpeed);
        @camera.position.z = z * Math.cos(rotSpeed) - x * Math.sin(rotSpeed);
        @camera.lookAt @scene.position

        #console.log @camera.position.x
        

        @renderer.clear()

        # Render scene into texture
        @renderer.render @scene, @camera, @postp.renderTextureScene, true

        # override scene material
        @scene.overrideMaterial = @postp.material_depth

        # Adjust camera far/near for depth rendering
        camerafar = @camera.far
        cameranear = @camera.near
        @camera.far = @postp.camerafar
        @camera.near = @postp.cameranear
        @camera.updateProjectionMatrix()

        # Render depth into texture
        @renderer.render @scene, @camera, @postp.renderTextureDepth, true

        #restore camera far/near
        @camera.far = camerafar
        @camera.near = cameranear
        @camera.updateProjectionMatrix()

        # undo override scene material
        @scene.overrideMaterial = null

        @postp.uniforms["tColor"].value = @postp.renderTextureScene
        @postp.uniforms["time"].value = @clock.getElapsedTime()
        @postp.uniforms["camView"].value = @scene.position
        @postp.uniforms["camUp"].value = @camera.up
        @postp.uniforms["camPos"].value = @camera.position
        @postp.uniforms["resolution"].value = new THREE.Vector3( @container.offsetWidth, @container.offsetHeight, 0.0 )

        @renderer.render @postp.scene, @postp.camera

        # Update stats
        @stats?.update()

        ###
        
        @renderer.render @scene, @camera, @renderTextureScene, true

        @scene.overrideMaterial = @postp.material_depth
        @renderer.render @scene, @camera, @renderTextureDepth, true

        @scene.overrideMaterial = @materialBokeh
        @renderer.render @scene, @camera, @renderFinal, true

        @renderer.render @scene, @camera
        ###

    startRender: =>

        requestAnimationFrame @startRender
        @render()

