class App

    container       : null
    stats           : null
    camera          : null
    scene           : null
    renderer        : null
    controls        : null
    clock           : null

    loader          : null

    # Particles
    mesh                : null
    particles           : null
    uniforms            : null
    attributes          : null
    numberOfParticles   : 100
    numberOfPlanes      : 1
    particleSize        : 5

    planes              : null

    cameraPositionPoints: []
    debugPaths          : null
    currentIndex        : 0

    constructor: ->

        @clock =  new THREE.Clock()

        @container = document.createElement 'div'
        document.body.appendChild @container

        @renderer = new THREE.WebGLRenderer { antialias:false, clearColor: 0x000000, clearAlpha: 1 }
        @renderer.gammaInput = false
        @renderer.gammaOutput = false
        @renderer.sortObjects = false
        @renderer.shadowMapEnabled = false
        @renderer.shadowMapSoft = true
        @renderer.setSize window.innerWidth, window.innerHeight

        @scene = new THREE.Scene()

        @camera = new THREE.PerspectiveCamera 50, window.innerWidth / window.innerHeight, 10, 100000
        @camera.position.x = 0;
        @camera.position.y = 0;
        @camera.position.z = -1500;
        @camera.fov = 25
        @camera.near = .10
        @camera.far = 20000
        @camera.target =  new THREE.Vector3( 0, 0, 0 )

        ambient = new THREE.AmbientLight 0xFFFFFF
        @scene.add ambient

        ambient = new THREE.AmbientLight 0xFFFFFF
        @scene.add ambient

        @loader = new IFLLoader()
        @loader.load "../../models/stormlayers.if3d", @onComplete, @onProgress

        $.ajax( {url : "/models/storm_position.txt", success : @onCameraPositionsLoaded });

        @container.appendChild @renderer.domElement
        
        # Controls
        # @controls = new THREE.OrbitControls @camera, @renderer.domElement

        # Stats
        @stats = new Stats()
        @stats.domElement.style.position = 'absolute'
        @stats.domElement.style.top = '0px'
        @container.appendChild @stats.domElement

        @initSky()
        @initSun()

        @debugPaths = new THREE.Object3D
        @scene.add @debugPaths

        # Loop render
        @animate()

        # Loading
        $("body").append "<div id='loading'>Loading Resources<div>"
        $("#loading").append "<div id='progressbar'></div>"
        $("#progressbar").progressbar { value: 0 }

        # Resize
        window.addEventListener 'resize', @onWindowResize, false
        @onWindowResize()

        return

    onProgress:(loaded,total) =>

        $( "#progressbar" ).progressbar "option", "value", ( loaded * 100 ) / total

    onComplete: (iflscene) =>

        @scene.add iflscene
        @scene.add @skyCube
        @scene.add @lensFlare

        descendants = iflscene.getDescendants()
        
        
        for descendant in descendants

            if descendant instanceof THREE.Mesh
                # console.log descendant
                descendant.material = @instanceBasicMaterial()

            #console.log descendant


        # Add sphere
        @sph = new THREE.Mesh new THREE.SphereGeometry(1), new THREE.MeshBasicMaterial({color:0xFF0000,wireframe:true}) 
        @scene.add(@sph)

        # Remove loading
        $( "#loading" ).remove()

        gui = new dat.GUI

     onCameraPositionsLoaded:(data)=>

        @cameraPositionPoints = []
        arr = data.split("\n")
        for txtpos in arr
            posarr = txtpos.split(",")
            @cameraPositionPoints.push( [
                parseFloat(posarr[0]),
                parseFloat(posarr[1]),
                parseFloat(posarr[2])
                ])

        @createDebugPath(@cameraPositionPoints)

        @controls = new THREE.PathControls @camera
        @controls.waypoints = @cameraPositionPoints # [ [ -500, 0, 0 ], [ 0, 200, 0 ], [ 500, 0, 0 ] ]
        
        @controls.duration = 18
        @controls.useConstantSpeed = true
        @controls.createDebugPath = true;
        @controls.createDebugDummy = false;
        @controls.lookSpeed = 0.06
        @controls.lookVertical = false
        @controls.lookHorizontal = false
        @controls.verticalAngleMap = { srcRange: [ 0, 2 * Math.PI ], dstRange: [ 1.1, 3.8 ] }
        @controls.horizontalAngleMap = { srcRange: [ 0, 2 * Math.PI ], dstRange: [ 0.3, Math.PI - 0.3 ] }
        @controls.lon = 360
        @controls.init()

        @scene.add @controls.animationParent

        @controls.animation.play true, 0

    createDebugPath : (arr) =>

        root = new THREE.Object3D

        linegeom = new THREE.Geometry
        linerenderable = new THREE.Line(linegeom)
        root.add linerenderable

        
        for point in arr
            dMesh = new THREE.Mesh(new THREE.SphereGeometry(.1,3,2), new THREE.MeshBasicMaterial({wireframe:true,color:0xFF0000,lights:false}) )
            dMesh.position.copy point
            root.add( dMesh );
            linegeom.vertices.push(point)
        
        @debugPaths.add root
        return

    instanceBasicMaterial: =>

        mat = new THREE.MeshPhongMaterial
            diffuse:0xFFFFFF
            ambient:0x111111

        mat.side = THREE.DoubleSide
        mat.alphaTest = 0.5
        mat.opacity = 0.5
        mat.fog = true
        mat.lights = true

        mat
    
    initSky : () ->

        path = "/models/textures/skybloom/"
        format = '.png';
        urls = [
            path + 'posx' + format
            path + 'negx' + format
            path + 'posy' + format
            path + 'negy' + format
            path + 'negz' + format
            path + 'posz' + format
        ]

        @skyCubeTexture = THREE.ImageUtils.loadTextureCube( urls )
        @skyCubeTexture.format = THREE.RGBFormat
        
        cubeShader = new IFLSkyCubeShader
        cubeShader.uniforms[ "tCube" ].value = @skyCubeTexture
        cubeShader.uniforms[ "tFlip" ].value = true
        
        material = new THREE.ShaderMaterial
            fragmentShader: cubeShader.fragmentShader
            vertexShader: cubeShader.vertexShader
            uniforms: cubeShader.uniforms
            depthWrite: false
            side: THREE.BackSide


        @skyCube = new THREE.Mesh( new THREE.CubeGeometry( 10000, 10000, 10000 ), material )
        @skyCube.name = "skyCube"
        
        return

    initSun:()->

        sunLight = new THREE.DirectionalLight();
        sunLight.color.setRGB(1,1,1);
        sunLight.position.set( -5000, 1000, -5000 )
        sunLight.intensity = 1
        sunLight.castShadow = true;
        sunLight.shadowCameraNear = 20;
        sunLight.shadowCameraFar = 100000;
        sunLight.shadowCameraFov = 70;
        sunLight.shadowMapWidth = 1024;
        sunLight.shadowMapHeight = 1024;
        sunLight.shadowDarkness  = .4;
        sunLight.shadowCameraLeft = 200;
        sunLight.shadowCameraRight = -200;
        sunLight.shadowCameraTop = 100;
        sunLight.shadowCameraBottom = -500;
        sunLight.shadowCameraVisible = true;
        @scene.add( sunLight );

        @scene.add( new THREE.AmbientLight(0xffffff) )

        textureFlare0 = THREE.ImageUtils.loadTexture( "/models/textures/lensflare/lensflare0.png" );
        # textureFlare2 = THREE.ImageUtils.loadTexture( "/models/textures/lensflare/lensflare2.png" );
        textureFlare3 = THREE.ImageUtils.loadTexture( "/models/textures/lensflare/hexangle.png" );
        
        flareColor = new THREE.Color( 0xFFFFFF )

        @lensFlare = new THREE.LensFlare( textureFlare0, 1000, 0.0, THREE.AdditiveBlending, flareColor );
        @lensFlare.position.set(-2000,500,-2000)

        # lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending );
        # lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending );
        # lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending );

        @lensFlare.add( textureFlare3, 60, 0.6, THREE.AdditiveBlending );
        @lensFlare.add( textureFlare3, 70, 0.7, THREE.AdditiveBlending );
        @lensFlare.add( textureFlare3, 120, 0.9, THREE.AdditiveBlending );
        @lensFlare.add( textureFlare3, 70, 1.0, THREE.AdditiveBlending );

        
        @lensFlare.customUpdateCallback = ( object ) =>
            vecX = -object.positionScreen.x * 2;
            vecY = -object.positionScreen.y * 2;
            for flare in object.lensFlares
                flare.x = object.positionScreen.x + vecX * flare.distance;
                flare.y = object.positionScreen.y + vecY * flare.distance;
                flare.rotation = 0;
            object.lensFlares[ 2 ].y += 0.025;
            object.lensFlares[ 3 ].rotation = object.positionScreen.x * 0.5 + 45 * Math.PI / 180

        return null 

    animate: =>

        window.requestAnimationFrame( @animate )
        @render()
        @stats.update()
        return

    render: =>

        delta = @clock.getDelta()
        @renderer.clear()

        if @controls?
            @controls.update delta

        @sph?.position.x = Math.sin(@clock.oldTime/1600)*10
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