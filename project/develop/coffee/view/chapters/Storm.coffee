class Storm extends AbstractChapter

    clock           : null

    APP_HEIGHT      : 800
    APP_WIDTH       : 600
    APP_HALF_X      : 800/2
    APP_HALF_Y      : 600/2

    mouseX          : 0
    mouseY          : 0
    followX         : 0
    followY         : 0
    cubeRefMesh     : null
    bal             : null
    sl1             : null
    sl2             : null
    sl3             : null
    sl4             : null

    currentScale    : 0.3
    speed           : 1

    running         : true

    init: =>

        @clock =  new THREE.Clock()
        
        @APP_WIDTH = $(window).width()
        @APP_HEIGHT = $(window).height()


        @renderer = new THREE.WebGLRenderer 
            canvas:  @oz().appView.renderCanvas3D
            antialias:true
            clearAlpha: 1 
            clearColor: 0x000000

        # @renderer.domElement.dispose = () => @

        @renderer.setSize @APP_WIDTH, @APP_HEIGHT

        @camera = new THREE.PerspectiveCamera 75, @APP_WIDTH / @APP_HEIGHT, 10, 100000
        @camera.position.set 0, 0, 40
        @camera.updateMatrix()

        @scene = new THREE.Scene()
        
        # LIGHTS
        ambient = new THREE.AmbientLight 0xFFFFFF
        @scene.add ambient

        cube = new THREE.CubeGeometry 1, 1, 1
        @cubeRefMesh = new THREE.Mesh cube,  new THREE.MeshLambertMaterial { color: 0xFFFFFF }
        #@scene.add @cubeRefMesh

        # Planes
        @sl1 = @addPlane 2000, 227, 1.0, 1100, 0, -80, 0, 0, 0, "/models/textures/stormsky/storm/sl1.png"
        @sl2 = @addPlane 2000, 227, 1.0, 1100, 0, -90, 0, 0, 0, "/models/textures/stormsky/storm/sl2.png"
        @sl3 = @addPlane 2100, 327, 1.0, 1000, 0, -100, 0, 0, 0, "/models/textures/stormsky/storm/sl3.png"
        @bal = @addPlane 212, 315,  0.3, 0,  0, -150, 0, 0, 0, "/models/textures/stormsky/storm/balloon.png"
        @sl4 = @addPlane 2500, 374, 1.0, 900, 0, -180, 0, 0, 0, "/models/textures/stormsky/storm/sl4.png"
        
        @scene.add @sl1
        @scene.add @sl2
        @scene.add @sl3
        @scene.add @bal
        @scene.add @sl4

        @onResize()

        @trigger 'onWorldLoaded'
        
        # @addChild @renderer.domElement

    activate : =>

        $('body').bind 'click', @pointLock

    changeView: =>

        @

    addPlane: ( w, h, scale, x, y, z, rx, ry, rz, mat ) =>

        planeGeom = new THREE.PlaneGeometry w, h, 39, 9
        planeText = THREE.ImageUtils.loadTexture mat
        planeMat = new THREE.MeshLambertMaterial {
            color: 0x00ff80,
            ambient: 0xFFFFFF,
            shading: THREE.SmoothShading,
            map: planeText,
            transparent: true,
            wireframe: false,
            side: THREE.DoubleSide
        }
        plane = new THREE.Mesh planeGeom, planeMat

        plane.scale.x = plane.scale.y = plane.scale.z = scale
        plane.position.x = x
        plane.position.y = y
        plane.position.z = z
        plane.rotation.x = rx
        plane.rotation.y = ry
        plane.rotation.z = rz
        plane.updateMatrix();

        plane

    initSky : () ->

        # material
        path = "/models/textures/stormsky/"
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

        @skyCube = new THREE.Mesh new THREE.CubeGeometry( 10000, 10000, 10000 ), material
        @skyCube.name = "skyCube"
        @scene.add @skyCube
    
    onDocumentMouseMove: (event) =>

        @mouseX = ( event.clientX - (@APP_WIDTH / 2) )
        @mouseY = ( event.clientY - (@APP_HEIGHT / 2) )

    onLockMouseMove : (event) =>

        e = event.originalEvent

        mX = e.movementX || e.mozMovementX || e.webkitMovementX || 0
        mY = e.movementY || e.mozMovementY || e.webkitMovementY || 0

        @mouseX += mX * 1.2
        @mouseY += mY

    onLock : =>
        @

    onUnLock : =>
        @mouseX = 0
        @mouseY = 0

    onEnterFrame: =>

        if @running

            delta = @clock.getDelta()

            moveX = (@mouseX - @followX ) / 10
            moveY = (@mouseY - @followY ) / 10

            @followX += moveX
            @followY += moveY

            @sl4.position.y = ( @followY / 40 )
            @bal.position.y = ( @followY / 20 )
            @sl3.position.y = ( @followY / 30 )
            @sl2.position.y = ( @followY / 50 )
            @sl1.position.y = ( @followY / 60 )

            @speed = @followX / (@APP_WIDTH / 2)
            @sl4.position.x -= @speed
            @sl3.position.x -= @speed * 1.1
            @sl2.position.x -= @speed * 1.2
            @sl1.position.x -= @speed * 1.3

            # console.log @sl4.position.x

            if @sl4.position.x < -1150
                $('body').unbind 'click', @pointLock
                @running = false
                @oz().appView.subArea.playVideo()
                @releasePointLock()
                return

            r = Date.now() * 0.002
            @bal.rotation.z = -0.2 * @speed
            @bal.rotation.x = 0.1 * Math.cos( r )
            @bal.rotation.y = 0.1 * Math.cos( r )

            ###if @followX > 0
                @flipBalloon 0.3
            else
                @flipBalloon -0.3###
            
            #@sl4.position.x = ( @followX / 20 ) * -1
            #@bal.position.x = ( @followX / 18 ) * -1
            #@sl3.position.x = ( @followX / 19 ) * -1
            #@sl2.position.x = ( @followX / 17 ) * -1
            #@sl1.position.x = ( @followX / 15 ) * -1

            # console.log @mouseY / (@APP_HEIGHT / 2)
            # @camera.position.x = ( @followX / 2 ) * -1
            # @bal.scale.x = - 0.3

            # @camera.rotation.y = -@speed / 150


            @renderer.clear()
            @renderer.render @scene, @camera

            TWEEN.update()

    flipBalloon: ( scale ) =>

        if scale != @currentScale
            
            position = { model: @bal, scale : @currentScale }
            target = { scale : scale}

            tween = new TWEEN.Tween(position).to(target, 700)
            tween.easing TWEEN.Easing.Quadratic.Out
            tween.onUpdate ->
                position.model.scale.x = position.scale
            tween.start()
            @currentScale = scale

    onResize: =>

        @APP_WIDTH = $(window).width();
        @APP_HEIGHT = $(window).height();
        @APP_HALF_X = @APP_WIDTH/2
        @APP_HALF_Y = @APP_HEIGHT/2

        @camera.aspect = @APP_WIDTH / @APP_HEIGHT
        @camera.updateProjectionMatrix()
        @renderer.setSize( @APP_WIDTH, @APP_HEIGHT )

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

    dispose :=>
        @releasePointLock()
        $('body').unbind 'click', @pointLock

        # @remove @renderer.domElement
        @renderer = null
        @