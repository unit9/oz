class Stormtest extends Base3DChapter

    # WARNING:
    # This contains some tricks to render correctly, as it has a fullscreen shader (tornado) that is outside composer pipeline, and it's in the middle of the scene
    # Scene is rendered in these steps: background + back stuff (debris behind tornado) => tornado => balloon + front stuff (debris in front tornado) => lensflare.
    # Added Sal2X for smooth tornado rendering at low res

    # Const
    SCENE_SCALE : 1 / 12
    CAMERA_DATA_FPS : 25
    CAMERA_ORBIT_H : 0.7
    CAMERA_ORBIT_V : 0.5
    SPEED_MIN : 0.50
    SPEED_MAX : 2.00    
    TIME_ENTER_TORNADO : 22.2
    TIME_END : 45
    MAX_DROPS : 60
    MIN_SAMPLES : 2
    MAX_SAMPLES : 16
    Q_STR : null
    Q_EXT : null
    Q_LOADER : null
    Q_DROPS : true
    OPTIONS : { tornadoRotation : 0.9, envmapMul : 10.0, envmapMix : 0.76, envmapPow : 0.57, specmapMul : 0.57, specmapPow : 0.1, cubeX : -126.0, cubeY : 107.0, cubeZ : 51.0, overrideValues : false, dropsRatio : 0.07, dropsScale : 1.0 }
    # Loader
    L_TEX : 0
    L_TEXNUM : 49
    L_LOADTEX : 0
    L_LOADSCENE : 0
    # Scene
    enableRender : false
    stormAnimTime : 0
    stormState : 0
    sceneRT : null
    hudRT : null
    tornadoSamples : 8
    tornadoW : null
    tornadoH : null
    tornadoShader : null
    tornadoMaterial : null
    tornadoTexture : true
    tornadoRT : null
    tornadoFilter : true
    sal2xShader : null
    sal2xMaterial : null
    texClouds : null
    texWhite : null
    texDrops : []
    drops : []
    dropsTime : 0
    dropsRatio : 0.15
    dropsScale : 0.7
    godrays : null
    timeFps : 0
    fpsCur : 0
    fpsAcc : 0
    fpsCount : 0
    audioListener : null
    stormControls : null
    cameraPosData : null
    cameraTgtData : null
    matTranslate : new THREE.Matrix4()
    matRotX : new THREE.Matrix4()
    matRotY : new THREE.Matrix4()
    matInverse : new THREE.Matrix4()
    matTornado : new THREE.Matrix4()
    debrisOutside : []
    debrisInside : []
    debrisOrgan : []
    sceneLoaded : false
    textureLoaded : false
    loadingDone : false
    animStarted : false
    animPaused : false
    mousePos : { x : 0, y : 0 }
    curPos : { x : 0, y : 0 }
    prevPos : { x : 0, y : 0 }

    # Add this to call the instructions box
    changeView:=>
        @onCameraReady()

    onMouseClick:(event)=>
        return unless @enableMouse and @animStarted
        if !@animPaused || !@stormControls
            @pointLock()
        super

    # get mouse coords when lock
    onLockMouseMove:(event)=>
        SPEED = 0.3
        MOUSE_RANGE_X = 400
        MOUSE_RANGE_Y = 400

        e = event.originalEvent
        @prevPos.x += e.webkitMovementX * SPEED
        @prevPos.y += e.webkitMovementY * SPEED

        @prevPos.x = UTILS.clamp( @prevPos.x, -MOUSE_RANGE_X, MOUSE_RANGE_X )
        @prevPos.y = UTILS.clamp( @prevPos.y, -MOUSE_RANGE_Y, MOUSE_RANGE_Y )

        @mousePos.x = @prevPos.x / MOUSE_RANGE_X
        @mousePos.y = @prevPos.y / MOUSE_RANGE_Y

        @pickMouse.x = ( event.clientX / @APP_WIDTH ) * 2 - 1;
        @pickMouse.y = - ( event.clientY / @APP_HEIGHT ) * 2 + 1;

    onKeyDown:(event)=>
        super( event )

        if @oz().appView.debugMode
            if event.ctrlKey && event.keyCode == 66
                @onRestart( true )

            if event.ctrlKey && event.keyCode == 65
                @animPaused = !@animPaused
                if @animPaused
                    @releasePointLock()
                    SoundController.send "storm_scene_pause"
                    @CAMERA_ORBIT_H = Math.PI/2.0
                    @CAMERA_ORBIT_V = Math.PI/2.5
                else
                    @pointLock()
                    SoundController.send "storm_scene_resume"
                    @CAMERA_ORBIT_H = 0.7
                    @CAMERA_ORBIT_V = 0.5

            ###
            if event.ctrlKey && event.keyCode == 77
                @scene.remove( cloud ) for cloud in @farclouds
                @farclouds = @addCloudsFar( 180,-14,80, 80,1,60, 25, 'far43' )
                @scene.add( cloud ) for cloud in @farclouds

                @scene.remove( cloud ) for cloud in @fdclouds
                mesh = @fdclouds.mesh
                @fdclouds = @addClouds( mesh, 90,35,90, 160, false, 'fd20' )
                @fdclouds.mesh = mesh
                @scene.add( cloud ) for cloud in @fdclouds
            ###

        return

    randomRangeInt:(lower,upper=0)->
        start = Math.random()
        if not lower?
            [lower, upper] = [0, lower]
        if lower > upper
            [lower, upper] = [upper, lower]
        return Math.floor(start * (upper - lower + 1) + lower)

    randomRange:(lower,upper)=>
        return Math.random() * (upper - lower) + lower

    normalizeAngle:(angle)->
        return Math.atan(Math.sin(angle, Math.cos(angle))) + Math.PI

    animateParam:(value,valuefin,time,timeini,timeend)->
        return value if time < timeini
        return valuefin if time > timeend
        return UTILS.lerp( UTILS.time01(time, timeini, timeend - timeini), value, valuefin )

    initQuality:()->
        @quality = @oz().appView.displayQuality
        switch @quality
            when "low"
                @SCENE_WIDTH  = @APP_WIDTH  * 0.75
                @SCENE_HEIGHT = @APP_HEIGHT * 0.75
                @MIN_SAMPLES  = 8
                @MAX_SAMPLES  = 16
                @Q_STR        = "_low"
            when "med"
                @SCENE_WIDTH  = @APP_WIDTH  * 0.75
                @SCENE_HEIGHT = @APP_HEIGHT * 0.75
                @MIN_SAMPLES  = 4
                @MAX_SAMPLES  = 12
                @Q_STR        = "_low"
            when "hi"
                @SCENE_WIDTH  = @APP_WIDTH
                @SCENE_HEIGHT = @APP_HEIGHT
                @MIN_SAMPLES  = 4
                @MAX_SAMPLES  = 12
                @Q_STR        = ""
        # DDS Support
        if @oz().appView.ddsSupported
            @Q_EXT        = ".dds"
            @Q_LOADER     = THREE.ImageUtils.loadCompressedTexture
            @Q_DROPS      = true
        else
            @Q_STR        = "_low"
            @Q_EXT        = ".png"
            @Q_LOADER     = THREE.ImageUtils.loadTexture
            @Q_DROPS      = false
        # Tornado samples
        @tornadoSamples = @MIN_SAMPLES
        @tornadoW = @APP_WIDTH  / @tornadoSamples
        @tornadoH = @APP_HEIGHT / @tornadoSamples
        if !@hudRT then @hudRT = new Hud( @renderer, @SCENE_WIDTH, @SCENE_HEIGHT, false, false ) else @hudRT.resize( @SCENE_WIDTH, @SCENE_HEIGHT )
        return

    init:()->
        super

        # Mouse events
        document.addEventListener( 'mouseup',   @onMouseUp,    false )
        document.addEventListener( 'mousedown', @onMouseDown,  false )
        document.addEventListener( 'click',     @onMouseClick, false )

        @initQuality()

        @scene.fog.far = 10000000
        @renderer.gammaInput = false
        @renderer.gammaOutput = false
        @renderer.sortObjects = true
        @renderer.shadowMapEnabled = false
        @renderer.shadowMapSoft = false

        @camera.fov = 43
        @camera.near = 1
        @camera.far = 10000

        @params.cameraFOV = 43
        @params.colorCorrectionPow = "#000000"
        @params.colorCorrectionPowM = 1
        @params.colorCorrectionMul = "#FFFFFF"
        @params.colorCorrectionMulM = 1
        @params.colorCorrectionSaturation = 0
        @params.colorCorrectionSaturationColors = "#FFFFFF"
        @params.bloomPower = 0.39
        @params.fogcolor = "#caa46f"
        @effectBloom.enabled = false
        @colorCorrection.uniforms.vignetteOffset.value = 1
        @colorCorrection.uniforms.vignetteDarkness.value = 1

        if @oz().appView.debugMode
            @stormControls = new THREE.FirstPersonControls( @camera, @oz().appView.wrapper.el )

        @initCameraData()
        @initSun()

        @loader = new IFLLoader
        @loader.enableMaterialCache = false
        @loader.enableTextureCache = false
        @loader.pickableObjects = []
        @loader.customMaterialInstancer = @instanceMaterial
        @loader.load("/models/storm.if3d", @onSceneLoaded, @onSceneProgress)

        @onColorCorrectionChange()

        @initGodrays()
        @initTornado()
        @initDrops()
        if @oz().appView.debugMode
            @initGUI()
        @onResize()

        @$el.bind 'click', @onMouseClick
        @$el.bind 'mousedown', @onMouseDown
        @$el.bind 'mouseup', @onMouseUp

    # Godrays
    initGodrays:()->
        @godrays = { enabled: false }

        @godrays.depthMaterial = new THREE.MeshBasicMaterial
            color: 0xFFFFFF
            map: null

        @godrays.depthMaterialSkinned = new THREE.MeshLambertMaterial
            color : 0xFFFFFF
            ambient : 0xFFFFFF 
            specular : 0xFFFFFF
            skinning : true
            lights : false

        @godrays.scene = new THREE.Scene()
        @godrays.camera = new THREE.OrthographicCamera( @SCENE_WIDTH / - 2, @SCENE_WIDTH / 2,  @SCENE_HEIGHT / 2, @SCENE_HEIGHT / - 2, -10000, 10000 )

        @godrays.camera.position.z = 1000;
        @godrays.scene.add( @godrays.camera );

        # god-ray shaders
        godraysGenShader = THREE.ShaderGodRays[ "godrays_generate" ];
        @godrays.godrayGenUniforms = THREE.UniformsUtils.clone( godraysGenShader.uniforms );
        @godrays.materialGodraysGenerate = new THREE.ShaderMaterial( {

            uniforms: @godrays.godrayGenUniforms,
            vertexShader: godraysGenShader.vertexShader,
            fragmentShader: godraysGenShader.fragmentShader

        } );

        godraysCombineShader = THREE.ShaderGodRays[ "godrays_combine" ];
        @godrays.godrayCombineUniforms = THREE.UniformsUtils.clone( godraysCombineShader.uniforms );
        @godrays.materialGodraysCombine = new THREE.ShaderMaterial( {

            uniforms: @godrays.godrayCombineUniforms,
            vertexShader: godraysCombineShader.vertexShader,
            fragmentShader: godraysCombineShader.fragmentShader

        } );            

        @godrays.quad = new THREE.Mesh( new THREE.PlaneGeometry( @SCENE_WIDTH, @SCENE_HEIGHT ), @godrays.materialGodraysGenerate );
        @godrays.quad.position.z = -3000;
        @godrays.scene.add( @godrays.quad );

    initSun:()->
        # DANIELE: CHANGED THIS TO AMBIENT
        sunLight = new THREE.AmbientLight();
        # sunLight.color.setRGB(1,1,1);
        # sunLight.position.set( -1000, 300, -1000 )
        # sunLight.intensity = 1
        # sunLight.castShadow = true;
        # sunLight.shadowCameraNear = 20;
        # sunLight.shadowCameraFar = 100000;
        # sunLight.shadowCameraFov = 70;
        # sunLight.shadowMapWidth = 1024;
        # sunLight.shadowMapHeight = 1024;
        # sunLight.shadowDarkness  = .4;
        # sunLight.shadowCameraLeft = 200;
        # sunLight.shadowCameraRight = -200;
        # sunLight.shadowCameraTop = 100;
        # sunLight.shadowCameraBottom = -500;
        # sunLight.shadowCameraVisible = true;
        @scene.add( sunLight );

        textureFlare0 = THREE.ImageUtils.loadTexture( "/models/textures/lensflare/lensflare0_low.png", null, @onTexLoaded );
        # textureFlare2 = THREE.ImageUtils.loadTexture( "/models/textures/lensflare/lensflare2.png" );
        textureFlare3 = THREE.ImageUtils.loadTexture( "/models/textures/lensflare/hexangle.png", null, @onTexLoaded );
        flareColor = new THREE.Color( 0xFFFFFF )
        @lensFlare = new THREE.LensFlare( textureFlare0, 1000, 0.0, THREE.AdditiveBlending, flareColor );

        # lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending );
        # lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending );
        # lensFlare.add( textureFlare2, 512, 0.0, THREE.AdditiveBlending );

        @lensFlare.add( textureFlare3, 60, 0.6, THREE.AdditiveBlending );
        @lensFlare.add( textureFlare3, 70, 0.7, THREE.AdditiveBlending );
        @lensFlare.add( textureFlare3, 120, 0.9, THREE.AdditiveBlending );
        @lensFlare.add( textureFlare3, 70, 1.0, THREE.AdditiveBlending );
        
        @lensFlare.customUpdateCallback = (object)=>
            vecX = -object.positionScreen.x * 2;
            vecY = -object.positionScreen.y * 2;
            for flare in object.lensFlares
                flare.x = object.positionScreen.x + vecX * flare.distance;
                flare.y = object.positionScreen.y + vecY * flare.distance;
                flare.rotation = 0;
            object.lensFlares[ 2 ].y += 0.025;
            object.lensFlares[ 3 ].rotation = object.positionScreen.x * 0.5 + 45 * Math.PI / 180

    initTornado:()->
        # Tornado RT
        @tornadoW = @SCENE_WIDTH  / @tornadoSamples
        @tornadoH = @SCENE_HEIGHT / @tornadoSamples

        @TORNADO_POS = new THREE.Vector3( 0, -500 * @SCENE_SCALE, -400 * @SCENE_SCALE )

        # Format (low / hi)
        format = @Q_STR + '.png'

        # Tornado EnvMap
        path = "/models/textures/storm/Env/earth_diff_"
        urls = [
            path + 'posx' + format
            path + 'negx' + format
            path + 'posy' + format
            path + 'negy' + format
            path + 'negz' + format
            path + 'posz' + format
        ]        
        @tornadoEnvMap = THREE.ImageUtils.loadTextureCube( urls, null, @onTexLoaded )
        @tornadoEnvMap.format = THREE.RGBFormat

        # Tornado SpecMap
        path = "/models/textures/storm/Env/earth_spec_"
        urls = [
            path + 'posx' + format
            path + 'negx' + format
            path + 'posy' + format
            path + 'negy' + format
            path + 'negz' + format
            path + 'posz' + format
        ]                
        @tornadoSpecMap = THREE.ImageUtils.loadTextureCube( urls, null, @onTexLoaded )
        @tornadoSpecMap.format = THREE.RGBFormat                

        # Tornado Shader
        @tornadoTexture = THREE.ImageUtils.loadTexture( "/models/textures/storm/tornado.png", null, @onTexLoaded )
        @tornadoTexture.flipY = true
        @tornadoTexture.wrapS = @tornadoTexture.wrapT = THREE.RepeatWrapping
        #@tornadoTexture.repeat.set( 10, 10 )
        #@tornadoTexture  = THREE.ImageUtils.loadTexture( "/models/textures/storm/clouds.png", null )
        
        # Shader version
        #win = navigator.appVersion.indexOf("Win") != -1
        win = false        
        @tornadoShader   = if win then new IFLTornadoShaderWin else new IFLTornadoShader
        @tornadoMaterial = new THREE.ShaderMaterial
            vertexShader:   @tornadoShader.vertexShader
            fragmentShader: @tornadoShader.fragmentShader
            uniforms:       @tornadoShader.uniforms
            depthTest:      false
            depthWrite:     false
            transparent:    true
            map:            @tornadoTexture
        @tornadoMaterial.uniforms[ "resolution" ].value = new THREE.Vector2( @tornadoW, @tornadoH )
        @tornadoMaterial.uniforms[ "tDiffuse" ].value = @tornadoTexture

        # Sal2x Shader
        @sal2xShader   = new IFLSal2x
        @sal2xMaterial = new THREE.ShaderMaterial
            vertexShader:   @sal2xShader.vertexShader
            fragmentShader: @sal2xShader.fragmentShader
            uniforms:       @sal2xShader.uniforms
            depthTest:      false
            depthWrite:     false
            transparent:    true
        @sal2xMaterial.uniforms[ "resolution" ].value = new THREE.Vector2( @SCENE_WIDTH, @SCENE_HEIGHT )

        # TexWhite
        @texWhite = THREE.ImageUtils.loadTexture( "/models/textures/white.png", null, @onTexLoaded )

    addClouds:(mesh,rx,ry,rz,num,white,seed)->
        Math.seedrandom( seed )
        # Scale
        mesh.scale.set( mesh.scale.x * @SCENE_SCALE, mesh.scale.y * @SCENE_SCALE, mesh.scale.z * @SCENE_SCALE )

        # Create random clouds around mesh vertices
        if !@texClouds
            @texClouds = []
            @texClouds.push( @Q_LOADER( "/models/textures/storm/cloud1" + @Q_STR + @Q_EXT ) )
            #@texClouds.push( @Q_LOADER( "/models/textures/storm/cloud2" + @Q_STR + @Q_EXT ) )
            #@texClouds.push( @Q_LOADER( "/models/textures/storm/clouds" + @Q_STR + @Q_EXT ) )
            @shaderClouds = new IFLCloudsShader

        # Geometry
        clouds = []
        positions = mesh.geometry.attributes.position.array
        for i in [0..num-1] by 1
            idx = Math.round( @randomRange( 0, ( positions.length - 1) / 3 ) ) * 3
            x = (positions[idx+0]) * mesh.scale.x + mesh.position.x + @randomRange(-rx, rx)
            y = (positions[idx+1]) * mesh.scale.y + mesh.position.y + @randomRange(-ry, ry)
            z = (positions[idx+2]) * mesh.scale.z + mesh.position.z + @randomRange(-rz, rz)
            # Add sprite
            alpha = 0.30
            tex = 0 # @randomRangeInt( 0, 1 )
            params =
                fragmentShader: @shaderClouds.fragmentShader
                vertexShader:   @shaderClouds.vertexShader
                uniforms:       THREE.UniformsUtils.clone( @shaderClouds.uniforms )
                depthTest:      false
                depthWrite:     false
                alphaTest:      0.1
                transparent:    true
                map:            @texClouds[ tex ]
            mat = new THREE.ShaderMaterial( params )
            mat.uniforms["tDiffuse"].value = @texClouds[ tex ]
            mat.uniforms["scale"].value = @SCENE_SCALE
            mat.uniforms["alpha"].value = @randomRange( alpha, alpha + 0.15 )
            #mat.uniforms["angle"].value = @randomRange( 0, Math.PI*2 )
            # Add cloud
            cloud = new THREE.Mesh( new THREE.PlaneGeometry( 1000, 1000, 1, 1, 1 ), mat )
            cloud.position.x = x
            cloud.position.y = y
            cloud.position.z = z
            clouds.push( cloud )
        # Debug Mesh
        #@scene.add(mesh)
        return clouds

    addCloudsFar:(x,y,z,rx,ry,rz,num,seed)->
        # Geometry
        Math.seedrandom( seed )
        clouds = []
        for i in [0..num-1] by 1
            x = x + @randomRange(-rx, rx)
            y = y + @randomRange(-ry, ry)
            z = z + @randomRange(-rz, rz)
            # Add sprite
            alpha = 0.30
            tex = 0
            params =
                fragmentShader: @shaderClouds.fragmentShader
                vertexShader:   @shaderClouds.vertexShader
                uniforms:       THREE.UniformsUtils.clone( @shaderClouds.uniforms )
                depthTest:      false
                depthWrite:     false
                alphaTest:      0.1
                transparent:    true
                map:            @texClouds[ tex ]
            mat = new THREE.ShaderMaterial( params )
            mat.uniforms["tDiffuse"].value = @texClouds[ tex ]
            mat.uniforms["scale"].value = @SCENE_SCALE
            mat.uniforms["alpha"].value = @randomRange( alpha, alpha + 0.15 )
            #mat.uniforms["angle"].value = @randomRange( 0, Math.PI*2 )
            # Add cloud
            cloud = new THREE.Mesh( new THREE.PlaneGeometry( 1000, 1000, 1, 1, 1 ), mat )
            cloud.position.x = x
            cloud.position.y = y
            cloud.position.z = z
            clouds.push( cloud )
        return clouds

    # Debris
    addDebris:(mesh,scale,x,y,speed,offset)->
        obj = new THREE.Mesh( mesh.geometry, mesh.material )
        obj.position.set( x, y, 0 )
        obj.scale.set( scale, scale, scale )
        obj.speed = @randomRange( 0.5, 0.9 )
        debris = new THREE.Object3D()
        debris.speed = speed
        debris.offset = offset
        debris.obj = obj
        debris.add( obj )
        @scene.add( debris )
        return debris

    # DebrisOutside
    addDebrisOutside:(mesh,scale)->
        # New debris options
        debris = @addDebris(mesh, scale, @randomRange( 32, 38 ), @randomRange( 0, 70 ), @randomRange( 0.5, 0.9 ), @randomRange( 0, Math.PI*2 ) )
        @debrisOutside.push( debris )
        return debris

    # DebrisInside
    addDebrisInside:(mesh,scale)->
        # New debris options
        debris = @addDebris(mesh, scale, @randomRange( 8, 10 ), @randomRange( 10, 40 ), @randomRange( 0.5, 0.9 ), @randomRange( 0, Math.PI*2 ) )
        @debrisInside.push( debris )
        return debris

    # DebrisOrgan
    addDebrisOrgan:(mesh,scale,x,y,speed,offset,audio)->
        # New debris options
        debris = @addDebris(mesh, scale, x,y, speed, offset )
        @debrisInside.push( debris )
        # Audio
        debris.audio = new THREE.AudioObject( audio )
        debris.obj.add( debris.audio )
        #debris.audio.position.set( debris.obj.position.x, debris.obj.position.y, debris.obj.position.z )
        #@scene.add( debris.audio )
        return debris

    updateDebris:(debris,cameraAngle)->
        # Update debris in main loop
        debris.position.set( @TORNADO_POS.x, 0, @TORNADO_POS.z )
        debris.rotation.y = debris.speed * @stormAnimTime + debris.offset
        debris.front = @normalizeAngle( debris.rotation.y - cameraAngle ) < Math.PI
        obj = debris.obj
        obj.rotation.x = obj.speed * @stormAnimTime * 0.39
        obj.rotation.y = obj.speed * @stormAnimTime * 1.23
        obj.rotation.z = obj.speed * @stormAnimTime * 0.89
        # Audio?
        #if debris.audio
            #debris.audio.position.set( debris.obj.position.x + @TORNADO_POS.x, debris.obj.position.y, debris.obj.position.z + @TORNADO_POS.z)
        return

    initDrops:()->
        return unless @Q_DROPS
        # TexDrops
        @texDrops[0] = @Q_LOADER( "/models/textures/storm/drop1" + @Q_EXT, null, @onTexLoaded )
        @texDrops[1] = @Q_LOADER( "/models/textures/storm/drop2" + @Q_EXT, null, @onTexLoaded )
        @texDrops[2] = @Q_LOADER( "/models/textures/storm/drop3" + @Q_EXT, null, @onTexLoaded )
        @texDrops[3] = @Q_LOADER( "/models/textures/storm/drop4" + @Q_EXT, null, @onTexLoaded )
        @texDrops[4] = @Q_LOADER( "/models/textures/storm/drop5" + @Q_EXT, null, @onTexLoaded )
        
        for i in [0..@MAX_DROPS] by 1
            @drops[i] =
                active : false
                time : 0
                len : 0
                sprite : 0
                x : 0
                y : 0

        # Overlay
        #@overlay = THREE.ImageUtils.loadTexture( "/models/textures/storm/overlay.png" )
        return

    addDrop:(time)->
        return unless @Q_DROPS
        for drop in @drops
            if !drop.active
                # Quadrant
                scale = @SCENE_WIDTH / 2048
                switch @randomRangeInt( 0, 3 )
                    when 0 
                        x = 0
                        y = 0
                        angle = 0
                    when 1
                        x = @SCENE_WIDTH
                        y = 0
                        angle = Math.PI/2.0
                    when 2
                        x = 0
                        y = @SCENE_HEIGHT
                        angle = Math.PI*1.5
                    when 3
                        x = @SCENE_WIDTH
                        y = @SCENE_HEIGHT
                        angle = Math.PI

                # Drop position (rotation from 1,0
                ra  = angle + @randomRange( 0, Math.PI / 2.0 )
                rd  = Math.cos( Math.random() * ( Math.PI / 2.0 ) ) * @randomRange( 0, @SCENE_WIDTH * 0.35 )
                rx  = Math.cos(ra) * rd
                ry  = Math.sin(ra) * rd
                rs  = scale * @randomRange( @dropsScale * 0.75, @dropsScale * 1.25 )
                spr = @randomRangeInt( 0, @texDrops.length-1 )

                # Set Drop
                drop.sprite = @texDrops[ spr ]
                drop.w = drop.sprite.image.width  * rs
                drop.h = drop.sprite.image.height * rs
                drop.x = x - drop.w * 0.5 + rx
                drop.y = y - drop.h * 0.5 + ry
                drop.down = @randomRange( 0, 40 ) * scale
                drop.time = time
                drop.len = @randomRange( 1.5, 4.0 )
                drop.active = true

                return
        return

    drawDrops:(time)->
        return unless @Q_DROPS
        @hudRT.flipy = false
        @hudRT.renderTarget = @sceneRT
        for drop in @drops
            if drop.active
                t = time - drop.time
                if t < drop.len
                    FADE_IN = 0.1
                    if t < FADE_IN
                        fade = UTILS.time01( t, 0, FADE_IN )
                    else
                        fade = UTILS.time10( t, FADE_IN, drop.len-FADE_IN )
                    x = drop.x
                    y = drop.y + UTILS.time01( time, drop.time + 0.5, drop.len - 0.5 ) * drop.down
                    w = drop.w
                    h = drop.h
                    @hudRT.render( drop.sprite, x,y, w,h, 0.0, fade )
                else
                    drop.active = false
        @hudRT.flipy = true
        return

    initGUI:()->
        super

        tornadoFolder = @gui.addFolder("Tornado")
        tornadoFolder.add( @tornadoMaterial.uniforms["tornado_bounding_radius"], 'value', 10,200 ).name('Tornado Bounding Radius')
        tornadoFolder.add( @tornadoMaterial.uniforms["light_harshness"], 'value',0,2 ).name('Tornado Light Harshness')
        tornadoFolder.add( @tornadoMaterial.uniforms["light_darkness"], 'value',0,2 ).name('Tornado Light Darkness')
        tornadoFolder.add( @tornadoMaterial.uniforms["cloud_edge_sharpness"], 'value',0,2 ).name('Tornado Edge Sharpness')
        tornadoFolder.addColor( {value:"#FFFFFF"} , 'value' ).name('Tornado Tint').onChange(
            (value)=> 
                color = @stringToColor(value)
                @tornadoMaterial.uniforms["storm_tint"].value.set(color.r,color.g,color.b)
            )
        tornadoFolder.add( @tornadoMaterial.uniforms["cam_fov"], 'value',20,180 ).name('Tornado Fov')
        tornadoFolder.add( @tornadoMaterial.uniforms["final_colour_scale"], 'value',0,20 ).name('Tornado Colour Scale')
        tornadoFolder.add( @tornadoMaterial.uniforms["gamma_correction"], 'value',0,5 ).name('Tornado Gamma correction')
        tornadoFolder.add( @tornadoMaterial.uniforms["environment_rotation"], 'value',0,1 ).name('Tornado Env Rotation')
        tornadoFolder.add( @tornadoMaterial.uniforms["storm_alpha_correction"], 'value',0,5 ).name('Tornado Alpha Correction')
        tornadoFolder.add( @tornadoMaterial.uniforms["tornado_density"], 'value',0,5 ).name('Tornado Density')
        tornadoFolder.add( @tornadoMaterial.uniforms["tornado_height"], 'value',10,200 ).name('Tornado Height')
        tornadoFolder.add( @tornadoMaterial.uniforms["spin_speed"], 'value',0,5 ).name('Tornado Spin Speed')
        tornadoFolder.add( @tornadoMaterial.uniforms["base_step_scaling"], 'value',0,5 ).name('Tornado Base Step')
        tornadoFolder.add( @tornadoMaterial.uniforms["min_step_size"], 'value',0,5 ).name('Tornado Min Step')
        tornadoFolder.add( @OPTIONS, 'tornadoRotation', 0, Math.PI*2.0 ).name('Tornado Rotation')
        tornadoFolder.add( @tornadoMaterial.uniforms["dist_approx"], 'value',0,5 ).name('Dist Approx')

    onRestart:(lock)=>
        @renderer.sortObjects = true
        @mousePos = {x : 0, y : 0}
        @curPos = {x : 0, y : 0}
        @prevPos = {x : 0, y : 0}
        @animStarted = true
        @animPaused = false
        @stormAnimTime = 0
        @stormState = 0
        @dropsTime = 0
        @balloon.anim.stop()
        @balloon.anim.play(false, 0)
        @CAMERA_ORBIT_H = 0.7
        @CAMERA_ORBIT_V = 0.5
        if lock then @pointLock()

    activate:()->
        Analytics.track 'storm_enter_page', "Google_OZ_Balloon Ride"
        @onRestart( false )
        return

    pause:()->
        super
        SoundController.send "storm_scene_pause"
        @animStarted = false
        @balloon.anim.timeScale = 0
        return
        
    resume:()->
        super
        SoundController.send "storm_scene_resume" if !@animPaused
        @animStarted = true
        return

    onWorldProgress:()=>
        total = @L_LOADSCENE * 0.5 + @L_LOADTEX * 0.5
        #console.log(" [Storm] onWorldProgress: " + (total * 100) + "%")
        super( total )

        if @textureLoaded && @sceneLoaded && !@loadingDone
            #console.log "Storm world loaded"
            @loadingDone = true
            @onWorldLoaded()
            @enableRender = true
            @enableMouse = true
        return

    onTexLoaded:()=>
        @L_TEX++
        @L_LOADTEX = @L_TEX / @L_TEXNUM
        @textureLoaded = @L_TEX == @L_TEXNUM
        #console.log( "[Storm] Texture loaded: " + (@L_LOADTEX * 100) + "% (" + @L_TEX + " / " + @L_TEXNUM + ")" )
        @onWorldProgress()

    onSceneProgress:(loaded,total)=>
        @L_LOADSCENE = loaded / total
        #console.log( "[Storm] Scene loaded: " + (@L_LOADSCENE * 100) + "%" )
        @onWorldProgress()

    onSceneLoaded:(loader,iflscene)=>

        @iflscene = iflscene

        # Add objects
        objects       = [ "balloon_simple", "floor", "earth_sky", "oz_sky" ]
        debrisOutside = [ "Pipe", "Pipe1", "Pipe2", "Pipe3", "Pipe4", "wood", "wood1", "wood2", "wood3", "wood4", "wood5", "wood6", "wood7", "wood8", "wood9", "Wingback", "Wheelbarrow", "WagonWheel", "TrestleTable", "Stool", "Seat", "RoundTable", "FenceE", "FenceD", "Easel", "Door", "CrateB", "CrateA", "Bucket", "BrokenWheel", "BranchA", "Bench", "Barrel", "ABoard" ]
        debrisInside  = [ "Pipe", "Pipe1", "Pipe2", "Pipe3", "Pipe4" ]        
        debrisObj     = []
        descendants   = @iflscene.getDescendants()
        for elem in descendants
            #console.log( "[StormTest] Loading object in scene: " + elem.name )
            # Emitters
            if elem.name == "foreground_dark_emitter"
                elem.position.y -= 55;
                @fdclouds = @addClouds( elem, 90,35,90, 160, false, 'fd49' )
                @fdclouds.mesh = elem
            else if elem.name == "foreground_tornado_clouds_emitter"
                #@ftclouds = @addClouds( elem, 400,1,400, 0, 250,400, false )
            else if elem.name == "background_dark_emitter"
                #@bdclouds = @addClouds( elem )
            else if elem.name == "background_light_clouds_emitter"
                #@blclouds = @addClouds( elem, 400,1,400, 0, 400,700, true )
            else if elem.name == "background_tornado_clouds_emitter"
                #@btclouds = @addClouds( elem )
            else if elem.name in objects
                # Layers
                @balloon       = elem if elem.name == "balloon_simple"
                @earth_floor   = elem if elem.name == "floor"
                @earth_sky     = elem if elem.name == "earth_sky"
                @oz_sky        = elem if elem.name == "oz_sky"
                #    Add to scene
                elem.position.set( elem.position.x * @SCENE_SCALE, elem.position.y * @SCENE_SCALE, elem.position.z * @SCENE_SCALE )
                elem.scale.set( elem.scale.x * @SCENE_SCALE, elem.scale.y * @SCENE_SCALE, elem.scale.z * @SCENE_SCALE )
                @scene.add( elem )
            else if elem.name in debrisOutside
                debrisObj[elem.name] = @addDebrisOutside( elem, @SCENE_SCALE * 1.3 )
                @addDebrisOutside( elem, @SCENE_SCALE * 1.3 )

        # Far Clouds
        @farclouds = @addCloudsFar( 180,-14,80, 80,1,60, 25, 'far43' )

        # Balloon
        @instanceAnimation @balloon
        @balloon.material.transparent = true

        # GUI
        if @oz().appView.debugMode
            sceneFolder = @gui.addFolder("Scene Options")
            sceneFolder.add( @OPTIONS, 'overrideValues').name('Override Values')
            sceneFolder.add( @OPTIONS, 'envmapMul', 0.0, 10.0 ).name('Envmap Mul')
            sceneFolder.add( @OPTIONS, 'envmapMix', 0.0, 1.0 ).name('Envmap Mix')
            sceneFolder.add( @OPTIONS, 'envmapPow', 0.0, 5.0 ).name('Envmap Pow')
            sceneFolder.add( @OPTIONS, 'specmapMul', 0.0, 5.0 ).name('Specmap Mul')
            sceneFolder.add( @OPTIONS, 'specmapPow', 0.0, 2.0 ).name('Specmap Pow')
            sceneFolder.add( @OPTIONS, 'cubeX', -200, 200 ).name('Cube X')
            sceneFolder.add( @OPTIONS, 'cubeY', -200, 200 ).name('Cube Y')
            sceneFolder.add( @OPTIONS, 'cubeZ', -200, 200 ).name('Cube Z')
            sceneFolder.add( @OPTIONS, 'dropsRatio', 0, 1.0 ).name('Drops Ratio')
            sceneFolder.add( @OPTIONS, 'dropsScale', 0, 2.0 ).name('Drops Scale')
            #sceneFolder.add( @shaderClouds.uniforms["dist"], 'value', 0, 1000 ).name('Clouds Scaling')
            #sceneFolder.add( @shaderClouds.uniforms["angle"], 'value', 0, Math.PI*2.0 ).name('Clouds Angle')

        # Debris Inside
        for i in [0..35] by 1
            idx = @randomRangeInt( 0, debrisOutside.length-1 )
            mesh = debrisObj[ debrisOutside[ idx ] ].obj
            @addDebrisInside( mesh, @SCENE_SCALE * 1.3 )

        # Add debris organ
        @debrisOrgan = []
        @debrisOrgan.push( @addDebrisOrgan( debrisObj[ "Pipe"  ].obj, @SCENE_SCALE * 1.5, 11, 20, 0.7, 1, "storm_particle_1" ) )
        @debrisOrgan.push( @addDebrisOrgan( debrisObj[ "Pipe1" ].obj, @SCENE_SCALE * 1.5, 11, 20, 0.7, 1, "storm_particle_2" ) )
        @debrisOrgan.push( @addDebrisOrgan( debrisObj[ "Pipe2" ].obj, @SCENE_SCALE * 1.5, 8,  30, 0.4, 2, "storm_particle_3" ) )
        @debrisOrgan.push( @addDebrisOrgan( debrisObj[ "Pipe3" ].obj, @SCENE_SCALE * 1.5, 10, 40, 0.6, 3, "storm_particle_4" ) )
        @debrisOrgan.push( @addDebrisOrgan( debrisObj[ "Pipe4" ].obj, @SCENE_SCALE * 1.5, 12, 50, 0.5, 4, "storm_particle_5" ) )        
        # Clouds
        @scene.add( cloud ) for cloud in @fdclouds
        @scene.add( cloud ) for cloud in @farclouds

        @sceneLoaded = true
        @onWorldProgress()
        SoundController.send 'load_scene_4'

    instanceAnimation:(mesh)=>
        if mesh.geometry?.animation?
            THREE.AnimationHandler.add( mesh.geometry.animation )
            animation = new THREE.Animation( mesh, mesh.geometry.animation.name )
            animation.JITCompile = false
            animation.interpolationType = THREE.AnimationHandler.LINEAR
            @balloon.anim = animation

    instanceMaterial:(mesh,meshname)=>
        if meshname == "balloon_simple"
            mat = @instanceFresnelMaterial( mesh, meshname, "Balloon" )
        else if meshname == "floor"
            mat = @instanceBasicMaterial( mesh, meshname, "earth_floor" + @Q_STR + @Q_EXT )
        else if meshname == "earth_sky"
            mat = @instanceBasicMaterial( mesh, meshname, "earth_sky" + @Q_STR + @Q_EXT )
        else if meshname == "oz_sky"
            mat = @instanceBasicMaterial( mesh, meshname, "oz_sky" + @Q_STR + @Q_EXT )
        else if meshname == "wood9"
            mat = @instanceFresnelMaterial( mesh, meshname, "Wood9" )
        else if meshname == "wood8"
            mat = @instanceFresnelMaterial( mesh, meshname, "Wood8" )
        else if meshname == "wood7"
            mat = @instanceFresnelMaterial( mesh, meshname, "Wood7" )
        else if meshname == "wood6"
            mat = @instanceFresnelMaterial( mesh, meshname, "Wood6" )
        else if meshname == "wood5"
            mat = @instanceFresnelMaterial( mesh, meshname, "Wood5" )
        else if meshname == "wood4"
            mat = @instanceFresnelMaterial( mesh, meshname, "Wood4" )
        else if meshname == "wood3"
            mat = @instanceFresnelMaterial( mesh, meshname, "Wood3" )
        else if meshname == "wood2"
            mat = @instanceFresnelMaterial( mesh, meshname, "Wood2" )
        else if meshname == "wood1"
            mat = @instanceFresnelMaterial( mesh, meshname, "Wood1" )
        else if meshname == "wood"
            mat = @instanceFresnelMaterial( mesh, meshname, "Wood0" )
        else if meshname == "Wingback"
            mat = @instanceFresnelMaterial( mesh, meshname, "Wingback" )            
        else if meshname == "Wheelbarrow"
            mat = @instanceFresnelMaterial( mesh, meshname, "Wheelbarrow" )
        else if meshname == "WagonWheel"
            mat = @instanceFresnelMaterial( mesh, meshname, "WagonWheel" )            
        else if meshname == "TrestleTable"
            mat = @instanceFresnelMaterial( mesh, meshname, "TrestleTable" )
        else if meshname == "Stool"
            mat = @instanceFresnelMaterial( mesh, meshname, "Stool" )
        else if meshname == "Seat"
            mat = @instanceFresnelMaterial( mesh, meshname, "Seat" )
        else if meshname == "RoundTable"
            mat = @instanceFresnelMaterial( mesh, meshname, "RoundTable" )
        else if meshname == "Pipe4"
            mat = @instanceFresnelMaterial( mesh, meshname, "Pipe4" )
        else if meshname == "Pipe3"
            mat = @instanceFresnelMaterial( mesh, meshname, "Pipe3" )
        else if meshname == "Pipe2"
            mat = @instanceFresnelMaterial( mesh, meshname, "Pipe2" )
        else if meshname == "Pipe1"
            mat = @instanceFresnelMaterial( mesh, meshname, "Pipe1" )
        else if meshname == "Pipe"
            mat = @instanceFresnelMaterial( mesh, meshname, "Pipe0" )
        else if meshname == "FenceE"
            mat = @instanceFresnelMaterial( mesh, meshname, "FenceE" )
        else if meshname == "FenceD"
            mat = @instanceFresnelMaterial( mesh, meshname, "FenceD" )
        else if meshname == "Easel"
            mat = @instanceFresnelMaterial( mesh, meshname, "Easel" )
        else if meshname == "Door"
            mat = @instanceFresnelMaterial( mesh, meshname, "Door" )
        else if meshname == "CrateB"
            mat = @instanceFresnelMaterial( mesh, meshname, "CrateB" )
        else if meshname == "CrateA"
            mat = @instanceFresnelMaterial( mesh, meshname, "CrateA" )
        else if meshname == "Bucket"
            mat = @instanceFresnelMaterial( mesh, meshname, "Bucket" )
        else if meshname == "BrokenWheel"
            mat = @instanceFresnelMaterial( mesh, meshname, "BrokenWheel" )
        else if meshname == "BranchA"
            mat = @instanceFresnelMaterial( mesh, meshname, "BranchA" )
        else if meshname == "Bench"
            mat = @instanceFresnelMaterial( mesh, meshname, "Bench" )
        else if meshname == "Barrel"
            mat = @instanceFresnelMaterial( mesh, meshname, "Barrel" )
        else if meshname == "ABoard"
            mat = @instanceFresnelMaterial( mesh, meshname, "ABoard" )
        else if meshname == "foreground_dark_emitter"
            mat = new THREE.MeshNormalMaterial()
            mat.side = THREE.DoubleSide
            mat.transparent = true
            mat.opacity = 1.0
            mat.depthTest = false
        else if meshname == "foreground_tornado_clouds_emitter"
            mat = new THREE.MeshNormalMaterial()
            mat.side = THREE.DoubleSide
            mat.transparent = true
            mat.opacity = 1.0
            mat.depthTest = false
        else if meshname == "background_dark_emitter"
            mat = new THREE.MeshNormalMaterial()
            mat.side = THREE.DoubleSide
            mat.transparent = true
            mat.opacity = 1.0
            mat.depthTest = false
        else if meshname == "background_light_clouds_emitter"
            mat = new THREE.MeshNormalMaterial()
            mat.side = THREE.DoubleSide
            mat.transparent = true
            mat.opacity = 1.0
            mat.depthTest = false
        else if meshname == "background_tornado_clouds_emitter"
            mat = new THREE.MeshNormalMaterial()
            mat.side = THREE.DoubleSide
            mat.transparent = true
            mat.opacity = 1.0
            mat.depthTest = false
        else
            console.log("Material not found for: " + meshname)
            mat = new THREE.MeshNormalMaterial()
        return mat

    instanceFresnelMaterial:(mesh,meshname,materialname)=>
        path = "/models/textures/storm/" + materialname + "/" + materialname
        shader = new IFLStormFresnelShader
        params =
            fragmentShader: shader.fragmentShader
            vertexShader:   shader.vertexShader
            uniforms:       shader.uniforms
            side:           THREE.DoubleSide
            lights:         false
            alphaTest:      0.4
        material = new THREE.ShaderMaterial( params )
        # Uniforms
        uniforms = shader.uniforms
        uniforms[ "fresnelPower" ].value                        = 1.0
        uniforms[ "map" ].value = material.map                  = @Q_LOADER( path + "_Diff" + @Q_STR + @Q_EXT, null, @onTexLoaded )
        #uniforms[ "tAux" ].value                                = @Q_LOADER( path + "_Aux.dds",  null, @onTexLoaded )
        #uniforms[ "specularMap" ].value = material.specularMap  = @Q_LOADER( path + "_Spec.dds", null, @onTexLoaded )
        uniforms[ "envMap" ].value = material.envMap            = @tornadoEnvMap
        uniforms[ "specMap" ].value = material.specMap          = @tornadoSpecMap
        uniforms[ "map" ].value.flipY = false
        #uniforms[ "tAux" ].value.flipY = false
        #uniforms[ "specularMap" ].value.flipY = false
        uniforms[ "envMap" ].value.flipY = false
        return material

    instanceBasicMaterial:(mesh,meshname,materialname)=>
        path = "/models/textures/storm/" + materialname
        map = @Q_LOADER( path, null, @onTexLoaded )
        map.flipY = false
        material = new THREE.MeshBasicMaterial( { side: THREE.DoubleSide, map: map } )
        return material

    # ----------------------------------------------------------------------------------------------------------------------------------
    # Render tornado storm scene
    # ----------------------------------------------------------------------------------------------------------------------------------
    renderScene:()->
        @curPos.x = UTILS.lerp( 0.09, @curPos.x, @mousePos.x )
        @curPos.y = UTILS.lerp( 0.19, @curPos.y, @mousePos.y )

        # Default
        time = frame = next = step = speed = 0
        if !@animPaused
            # Speed based on mouse position
            desp = @curPos.x
            if desp < 0
                speed = UTILS.lerp( -desp, 1.0, @SPEED_MIN )
            else
                speed = UTILS.lerp( desp, 1.0, @SPEED_MAX )
            speed = UTILS.clamp( speed, @SPEED_MIN, @SPEED_MAX )

            # Scene time
            speed = if @animPaused || !@animStarted then 0 else speed*0.75
            @stormAnimTime = @balloon.anim.currentTime
            @balloon.anim.timeScale = speed
            time   = @stormAnimTime
            # Real frame
            tframe = time * @CAMERA_DATA_FPS
            frame  = UTILS.clamp( Math.floor(tframe), 0, @cameraPosData.length - 2 )
            next   = frame + 1
            step   = tframe - frame

            # Camera path
            src = @cameraLerp( @camSrc, step, @cameraPosData[frame], @cameraPosData[next] )
            tgt = @cameraLerp( @camTgt, step, @cameraTgtData[frame], @cameraTgtData[next] )

            # Camera orbit
            ax = @curPos.x * @CAMERA_ORBIT_H
            ay = @curPos.y * @CAMERA_ORBIT_V

            # Rotate up and right around orbit
            @camdir.set( src.x - tgt.x, src.y - tgt.y, src.z - tgt.z )
            @camv.set( @camdir.x, @camdir.y, @camdir.z )
            @camv.normalize()
            @camu.set( @camera.up.x, @camera.up.y, @camera.up.z )
            @camr.set( @camera.up.x, @camera.up.y, @camera.up.z )
            @camr.crossSelf( @camv )
            @matRotX.makeRotationAxis( @camr, ay )
            @matRotX.multiplyVector3( @camdir )
            @matRotX.makeRotationAxis( @camu, ax )
            @matRotX.multiplyVector3( @camdir )        
            @camera.position.set( @camdir.x + tgt.x, @camdir.y + tgt.y, @camdir.z + tgt.z  )
            @audioListener.position.set( @camera.position.x, @camera.position.y, @camera.position.z )

            # Displace target
            @camdir.normalize()
            @camu.set( 0, -1, 0 )
            @camu.crossSelf( @camdir )
            dd = (@curPos.x * 10 * 5 / 12);
            tgt.set( tgt.x + @camu.x * dd, tgt.y + @camu.y * dd, tgt.z + @camu.z * dd )

            # Camera lookat
            @camdir.set( tgt.x, tgt.y, tgt.z )
            @camera.lookAt( @camdir )
            cameraAngle = Math.atan2( @camdir.z - @camera.position.z, @camdir.x - @camera.position.x ) - Math.PI/2.0
        else
            time = @stormAnimTime
            @balloon.anim.timeScale = 0
            @stormControls.movementSpeed = if @stormControls.mouseDragOn then 0 else 8
            @stormControls.lookSpeed = if @stormControls.mouseDragOn then 0.08 else 0
            @stormControls.update( @delta )
            @audioListener.position.set( @camera.position.x, @camera.position.y, @camera.position.z )

        # State
        switch @stormState
            when 0
                if @stormAnimTime > 0
                    SoundController.send "storm_start"
                    @stormState = 1
            when 1
                if @stormAnimTime > @TIME_ENTER_TORNADO
                    SoundController.send "storm_inside"
                    @stormState = 2
            when 2
                if @stormAnimTime > @TIME_END-8
                    SoundController.send "storm_exit"
                    @stormState = 3

        # Godrays: TEMP DISABLED
        #@godrays.enabled = time > @TIME_ENTER_TORNADO

        # Clear buffers
        @renderer.setClearColorHex( 0, 1 )
        @renderer.clear()
        @renderer.setClearColorHex( 0, 0 )
        @renderer.clearTarget( @sceneRT, true, true, false )
        @renderer.setClearColorHex( 0, 0 )
        @renderer.clearTarget( @tornadoRT, true, false, false )
        if @godrays.enabled
            @renderer.clearTarget( @godrays.rtTextureColors, true, true, false )

        # Update objects
        @updateObjects( time, cameraAngle )

        # Setup Hud
        @hudRT.flipy = true
        @hudRT.renderTarget = @sceneRT

        # ==============================================================================================================
        # PASS 0: Render tornado
        # ==============================================================================================================
        if time < @TIME_END
            # Tornado position
            @matTranslate.makeTranslation( @TORNADO_POS.x, @TORNADO_POS.y, @TORNADO_POS.z )
            @matRotX.makeRotationX( -Math.PI / 2.0 )
            @matTranslate.multiplySelf( @matRotX )
            @matRotY.makeRotationZ( @OPTIONS.tornadoRotation )
            @matTranslate.multiplySelf( @matRotY )
            @matInverse.getInverse( @matTranslate )
            @matTornado.multiply( @matInverse, @camera.matrix )
            # Tornado shader
            @tornadoMaterial.uniforms[ "time" ].value = if @animPaused then 0 else @clock.elapsedTime
            @tornadoMaterial.uniforms[ "camera_matrix" ].value = @matTornado
            @tornadoMaterial.uniforms[ "resolution" ].value.set( @tornadoW, @tornadoH )
            # Render tornado to RT
            @hudRT.renderTarget = @tornadoRT
            @hudRT.renderMaterial( @tornadoMaterial, 0,0, @tornadoW+1, @tornadoH+1, 0.0, 1.0 ) # +1 for bilinear fix
            @hudRT.renderTarget = @sceneRT

        # ==============================================================================================================
        # PASS 1: Background
        # ==============================================================================================================
        @earth_floor.visible = time < @TIME_ENTER_TORNADO
        @earth_sky.visible = time < @TIME_ENTER_TORNADO
        @oz_sky.visible = time >= @TIME_ENTER_TORNADO
        @balloon.visible = false
        cloud.visible = false for cloud in @fdclouds
        cloud.visible = time < @TIME_ENTER_TORNADO for cloud in @farclouds
        debris.obj.visible = !debris.front && time < @TIME_ENTER_TORNADO for debris in @debrisOutside
        debris.obj.visible = false for debris in @debrisInside
        # Render
        if @godrays.enabled
            @renderer.render( @scene, @camera, @godrays.rtTextureColors )
        else
            @renderer.render( @scene, @camera, @sceneRT )

        # ==============================================================================================================
        # PASS 2: Tornado
        # ==============================================================================================================
        if time < @TIME_END
            fade = UTILS.time10( time, (@TIME_END-5), 5 )
            # Render tornado to screen
            @sal2xMaterial.uniforms[ "tDiffuse" ].value = @tornadoRT
            @sal2xMaterial.uniforms[ "resolution" ].value.set( @SCENE_WIDTH, @SCENE_HEIGHT )
            @sal2xMaterial.uniforms[ "opacity" ].value = fade
            # Render
            if @tornadoFilter
                @hudRT.renderMaterial( @sal2xMaterial, 0,0, @SCENE_WIDTH, @SCENE_HEIGHT, 0, fade, THREE.NormalBlending, { x: 0, y: 0, w: @tornadoW / @SCENE_WIDTH, h: @tornadoH / @SCENE_HEIGHT } )
            else
                @hudRT.render( @tornadoRT, 0,0, @SCENE_WIDTH, @SCENE_HEIGHT, 0, fade, THREE.NormalBlending, { x: 0, y: 0, w: @tornadoW / @SCENE_WIDTH, h: @tornadoH / @SCENE_HEIGHT } )

        # ==============================================================================================================
        # PASS 3: Front
        # ==============================================================================================================
        @earth_floor.visible = false
        @earth_sky.visible = false
        @oz_sky.visible = false
        @balloon.visible = false
        @balloon.visible = true
        @scene.add( @lensFlare ) if time < 18 or time > 30
        debris.obj.visible = debris.front && time < @TIME_ENTER_TORNADO for debris in @debrisOutside
        debris.obj.visible = true for debris in @debrisInside if time > @TIME_ENTER_TORNADO
        cloud.visible = time < @TIME_ENTER_TORNADO for cloud in @fdclouds
        cloud.visible = false for cloud in @farclouds
        # Render
        if @godrays.enabled
            @renderer.render( @scene, @camera, @godrays.rtTextureColors )
        else
            @renderer.render( @scene, @camera, @sceneRT )
        @scene.remove( @lensFlare )        

        # ==============================================================================================================
        # PASS 4: Godrays
        # ==============================================================================================================
        if @godrays.enabled
            flare.visible = false for flare in @lensFlare.lensFlares
            cloud.visible = false for cloud in @ftclouds
            cloud.visible = false for cloud in @farclouds
            debris.obj.visible = false for debris in @debrisOutside
            debris.obj.visible = false for debris in @debrisInside
            @renderGodraysDepth()
            @renderGodRays()

        # ==============================================================================================================
        # PASS 5: Front storm (transition)
        # ==============================================================================================================
        if time > (@TIME_ENTER_TORNADO-1) && time < (@TIME_ENTER_TORNADO+2)
            fade = 1
            if (time < @TIME_ENTER_TORNADO)
                fade = UTILS.time01(time, @TIME_ENTER_TORNADO-1, 1)
            else if (time > @TIME_ENTER_TORNADO+1)
                fade = UTILS.time10(time, @TIME_ENTER_TORNADO+1, 1)
            # Render
            @hudRT.render( @tornadoRT, 0,0, @SCENE_WIDTH, @SCENE_HEIGHT, 0, fade, THREE.NormalBlending, { x: 0, y: 0, w: @tornadoW / @SCENE_WIDTH, h: @tornadoH / @SCENE_HEIGHT } )

        # ==============================================================================================================
        # PASS 6: drops
        # ==============================================================================================================
        @drawDrops( @clock.elapsedTime )

        # ==============================================================================================================
        # FINAL PASS: render with post FX shader
        # ==============================================================================================================
        @hud.flipy = true
        if @sceneRT
            @colorCorrection.material.uniforms["tDiffuse"].value = @sceneRT
            @colorCorrection.material.map = @sceneRT
            @hud.renderTarget = null
            @hud.renderMaterial( @colorCorrection.material, 0,0, @APP_WIDTH, @APP_HEIGHT, 0, 1.0 )

        # FADE: Storm End => Video
        if time > (@TIME_END-2)
            @hud.renderTarget = null
            @hud.render( @texWhite, 0,0, @APP_WIDTH, @APP_HEIGHT, 0, UTILS.time01( time, @TIME_END-2, 2) )

        if time > @TIME_END
            Analytics.track 'storm_end'
            SoundController.send "storm_end"

            $('body').unbind 'click'
            document.removeEventListener( 'mouseup',   @onMouseUp,    false )
            document.removeEventListener( 'mousedown', @onMouseDown,  false )
            document.removeEventListener( 'click',     @onMouseClick, false )

            @releasePointLock()
            @enableRender = false
            
            @oz().router.navigateTo "final"

        # Disable sortObjects
        @renderer.sortObjects = false

        if @capturer
            @capturer.capture( @oz().appView.renderCanvas3D )        

    # Update objects
    updateObjects:(time,cameraAngle)->
        #animateParam:(value,valuefin,time,timeini,timeend)->
        tt = @TIME_ENTER_TORNADO
        te = @TIME_END

        # Balloon Shader options
        if @OPTIONS.overrideValues
            @balloon.material.uniforms["envmapMul"].value = @OPTIONS.envmapMul
            @balloon.material.uniforms["envmapMix"].value = @OPTIONS.envmapMix
            @balloon.material.uniforms["envmapPow"].value = @OPTIONS.envmapPow
            @balloon.material.uniforms["specmapMul"].value = @OPTIONS.specmapMul
            @balloon.material.uniforms["specmapPow"].value = @OPTIONS.specmaPow
            @balloon.material.uniforms["cubeX"].value = @OPTIONS.cubeX
            @balloon.material.uniforms["cubeY"].value = @OPTIONS.cubeY
            @balloon.material.uniforms["cubeZ"].value = @OPTIONS.cubeZ
        else
            # EnvmapMul
            mul = @animateParam(10.0, 0.5, time, tt-8,  tt-1)
            mul = @animateParam(mul, 10.0, time, tt+2,  te-5)
            @balloon.material.uniforms["envmapMul"].value = mul
            # EnvmapMix
            mix = @animateParam(0.76, 0.8, time, tt-8,  tt-1)
            mix = @animateParam(mix, 0.60, time, tt+2,  te-5)
            @balloon.material.uniforms["envmapMix"].value = mix
            # EnvmapPow
            @balloon.material.uniforms["envmapPow"].value  = 0.57
            # Specmap
            @balloon.material.uniforms["specmapMul"].value = 0.57
            @balloon.material.uniforms["specmapPow"].value = 0.1
            # Cubemap vector
            @balloon.material.uniforms["cubeX"].value = @animateParam(-126,-25,  time, tt-2, tt+2)
            @balloon.material.uniforms["cubeY"].value = @animateParam( 107, 200, time, tt-2, tt+2)
            @balloon.material.uniforms["cubeZ"].value = @animateParam( 51,  200, time, tt-2, tt+2)

            # Set options (gui)
            @OPTIONS.envmapMul  = @balloon.material.uniforms["envmapMul"].value
            @OPTIONS.envmapMix  = @balloon.material.uniforms["envmapMix"].value
            @OPTIONS.envmapPow  = @balloon.material.uniforms["envmapPow"].value
            @OPTIONS.specmapMul = @balloon.material.uniforms["specmapMul"].value
            @OPTIONS.specmaPow  = @balloon.material.uniforms["specmapPow"].value
            @OPTIONS.cubeX      = @balloon.material.uniforms["cubeX"].value
            @OPTIONS.cubeY      = @balloon.material.uniforms["cubeY"].value
            @OPTIONS.cubeZ      = @balloon.material.uniforms["cubeZ"].value

        # Background rotation
        if time < @TIME_ENTER_TORNADO
            ti = tt-5
            accel = @animateParam(0, -2, time, ti, ti+4)
            speed = (time-ti) * accel
            @earth_sky.rotation.y = speed
            @earth_floor.rotation.y = speed
            #console.log(" Sky Accel = " + accel)
        else
            @earth_sky.rotation.y = 0
            @earth_floor.rotation.y = 0
        @earth_sky.position.y = -200
        @earth_floor.scale.set( 200.0, 200.0, 120.0 )

        # Debris
        @updateDebris( debris, cameraAngle ) for debris in @debrisOutside
        @updateDebris( debris, cameraAngle ) for debris in @debrisInside

        # Lensflare
        if time < @TIME_ENTER_TORNADO
            @lensFlare.position.set( -150, 120, -300 )
        else
            @lensFlare.position.set( 7, 90, -30 )

        # Drops options
        if @OPTIONS.overrideValues
            @dropsRatio = @OPTIONS.dropsRatio
            @dropsScale = @OPTIONS.dropsScale
        else
            # Ratio
            ratio = @animateParam(1.0,   0.045, time, tt-10, tt-7)
            ratio = @animateParam(ratio, 0.020, time, tt+1,  tt+3)
            @dropsRatio = ratio
            # Scale
            @dropsScale = 0.7

        # Update drops
        time = @clock.elapsedTime
        if time > 0
            if time > @dropsTime
                @addDrop( time )
                @dropsTime = time + @randomRange( @dropsRatio * 0.75, @dropsRatio * 1.25 )

    # Godrays
    renderGodraysDepth:->

        # attempt to render foreground objects white while rest is black
        # problem is with skinned meshes (need to use a skinned material)
        # TODO: need to resolve this for better godrays rendering, still works though

        # prevmats = []
        # desc = @scene.getDescendants()
        # for elem in desc
        #     if elem.material?
        #         prevmats[elem.name] = elem.material
        #         if elem.material.skinning
        #             elem.material = @depthMaterialSkinned
        #         else
        #             elem.material = @depthMaterial

        @renderer.clearTarget( @godrays.rtTextureDepth, false, false, false )
        @renderer.render( @scene, @camera, @godrays.rtTextureDepth )

        # for elem in desc
        #     if elem.material?
        #         elem.material = prevmats[elem.name]

    # Godrays
    renderGodRays:->
        # godrays uniforms
        # @godrays.godrayCombineUniforms.fGodRayIntensity.value = 4.0;

        # Find the screenspace position of the sun
        sun3DPosition = new THREE.Vector3
        @projector.projectVector( sun3DPosition, @camera );
        sun3DPosition.x = ( sun3DPosition.x + 1 ) / 2;
        sun3DPosition.y = ( sun3DPosition.y + 1 ) / 2;
        # Give it to the god-ray shader

        # TODO: pass real values
        @godrays.godrayGenUniforms[ "vSunPositionScreenSpace" ].value.x = 0.5#sun3DPosition.x;
        @godrays.godrayGenUniforms[ "vSunPositionScreenSpace" ].value.y = 0.5#sun3DPosition.y;

        # -- Render god-rays --
        # Maximum length of god-rays (in texture space [0,1]X[0,1])
        filterLen = 1.0;

        # Samples taken by filter
        TAPS_PER_PASS = 6.0;

        # Pass order could equivalently be 3,2,1 (instead of 1,2,3), which
        # would start with a small filter support and grow to large. however
        # the large-to-small order produces less objectionable aliasing artifacts that
        # appear as a glimmer along the length of the beams

        # pass 1 - render into first ping-pong target
        pass = 1.0;
        stepLen = filterLen * Math.pow( TAPS_PER_PASS, -pass );
        @godrays.godrayGenUniforms[ "fStepSize" ].value = stepLen;
        @godrays.godrayGenUniforms[ "tInput" ].value = @godrays.rtTextureDepth;
        @godrays.scene.overrideMaterial = @godrays.materialGodraysGenerate;
        @renderer.render( @godrays.scene, @godrays.camera, @godrays.rtTextureGodRays2 );

        # pass 2 - render into second ping-pong target
        pass = 2.0;
        stepLen = filterLen * Math.pow( TAPS_PER_PASS, -pass );
        @godrays.godrayGenUniforms[ "fStepSize" ].value = stepLen;
        @godrays.godrayGenUniforms[ "tInput" ].value = @godrays.rtTextureGodRays2;
        @renderer.render( @godrays.scene, @godrays.camera, @godrays.rtTextureGodRays1  );

        # pass 3 - 1st RT
        pass = 3.0;
        stepLen = filterLen * Math.pow( TAPS_PER_PASS, -pass );
        @godrays.godrayGenUniforms[ "fStepSize" ].value = stepLen;
        @godrays.godrayGenUniforms[ "tInput" ].value = @godrays.rtTextureGodRays1;
        @renderer.render( @godrays.scene, @godrays.camera , @godrays.rtTextureGodRays2  );

        # final pass - composite god-rays onto colors
        @godrays.godrayCombineUniforms["tColors"].value = @godrays.rtTextureColors;
        @godrays.godrayCombineUniforms["tColors2"].value = @tornadoRT;
        @godrays.godrayCombineUniforms["tGodRays"].value = @godrays.rtTextureGodRays2;
        @godrays.scene.overrideMaterial = @godrays.materialGodraysCombine;
        @renderer.render( @godrays.scene, @godrays.camera );
        @godrays.scene.overrideMaterial = null;

    onResize: =>
        super
        
        @initQuality()
        @stormControls?.handleResize()

        # RenderTargets
        paramsD =
            minFilter: THREE.LinearFilter
            magFilter: THREE.LinearFilter
            format: THREE.RGBAFormat
            depthBuffer: true
        paramsN =
            minFilter: THREE.LinearFilter
            magFilter: THREE.LinearFilter
            format: THREE.RGBAFormat
            depthBuffer: false
        @sceneRT                   = new THREE.WebGLRenderTarget( @SCENE_WIDTH, @SCENE_HEIGHT, paramsD )
        @tornadoRT                 = new THREE.WebGLRenderTarget( @SCENE_WIDTH, @SCENE_HEIGHT, paramsN )
        #@godrays.rtTextureColors   = new THREE.WebGLRenderTarget( @SCENE_WIDTH, @SCENE_HEIGHT, params )
        #@godrays.rtTextureDepth    = new THREE.WebGLRenderTarget( @SCENE_WIDTH / 4, @SCENE_HEIGHT / 4, params )
        #@godrays.rtTextureGodRays1 = new THREE.WebGLRenderTarget( @SCENE_WIDTH / 4, @SCENE_HEIGHT / 4, params )
        #@godrays.rtTextureGodRays2 = new THREE.WebGLRenderTarget( @SCENE_WIDTH / 4, @SCENE_HEIGHT / 4, params )        

    onEnterFrame:()=>
        return unless @enableRender

        # Don't render but update vars
        super true

        # Fps Acc
        @fpsAcc++
        if (@clock.elapsedTime - @timeFps) > 1
            @fpsCount++
            @fpsCur = @fpsAcc / (@clock.elapsedTime - @timeFps)
            @fpsAcc = 0
            @timeFps = @clock.elapsedTime

            # Change settings based on FPS
            if @fpsCount > 0
                if @fpsCur < 20
                    @tornadoSamples = Math.min( @tornadoSamples + 1, @MAX_SAMPLES )
                if @fpsCur > 25
                    @tornadoSamples = Math.max( @tornadoSamples - 1, @MIN_SAMPLES )
                @tornadoW = @SCENE_WIDTH  / @tornadoSamples
                @tornadoH = @SCENE_HEIGHT / @tornadoSamples

        # Render
        @renderScene()

        # Overlay
        #@hud.render( @overlay, 0,0, @SCENE_WIDTH, @SCENE_HEIGHT, 0, 0.4 )

        # Drops
        #idx = Math.round( @clock.elapsedTime * 10 ) % 53
        #@hud.render( @drops[idx], 0,0, @SCENE_WIDTH, @SCENE_HEIGHT, 0, 1.0, THREE.AdditiveBlending, { x: 0.2, y: 0, w: 0.8, h: 0.8 } )
        #@hud.render( @drops[idx], 0,0, @SCENE_WIDTH, @SCENE_HEIGHT, 0, 1.0, THREE.AdditiveBlending, { x: 0.2, y: 0, w: 0.8, h: 0.8 } )

    dispose:->
        #@releasePointLock()
        #$('body').unbind 'click', @pointLock

    cameraLerp:(res,step,cur,next)->
        res.x = UTILS.lerp( step, cur[0], next[0] ) * @SCENE_SCALE
        res.y = UTILS.lerp( step, cur[1], next[1] ) * @SCENE_SCALE
        res.z = UTILS.lerp( step, cur[2], next[2] ) * @SCENE_SCALE
        return res;

    initCameraData:()->
        @audioListener = new THREE.AudioListenerObject( @camera )
        @scene.add( @audioListener )
        @camdir = new THREE.Vector3()
        @camv   = new THREE.Vector3()
        @camu   = new THREE.Vector3()
        @camr   = new THREE.Vector3()
        @camSrc = new THREE.Vector3()
        @camTgt = new THREE.Vector3()
        @cameraPosData = [
            [ -1206.71076716,-93.7893524735,-126.831423857 ]
            [ -1206.24263494,-93.7123166071,-126.732381616 ]
            [ -1204.84091075,-93.4817583003,-126.435966033 ]
            [ -1203.44316794,-93.2520187065,-126.140610652 ]
            [ -1202.04937145,-93.0230911468,-125.846307159 ]
            [ -1200.66134996,-92.7949169713,-125.553455693 ]
            [ -1199.27054167,-92.5657336087,-125.260266993 ]
            [ -1197.88798735,-92.3373535471,-124.969071442 ]
            [ -1196.51365091,-92.1097702128,-124.679861963 ]
            [ -1195.14749627,-91.882977079,-124.392632054 ]
            [ -1193.78110512,-91.6555964463,-124.105614476 ]
            [ -1192.41992091,-91.4285203869,-123.819958428 ]
            [ -1191.06686157,-91.2022260792,-123.536280326 ]
            [ -1189.72189043,-90.976707101,-123.254575847 ]
            [ -1188.3796441,-90.7510879923,-122.973725408 ]
            [ -1187.03945591,-90.5252614416,-122.693596564 ]
            [ -1185.70729669,-90.3002020015,-122.415446146 ]
            [ -1184.38312911,-90.0759033546,-122.139271988 ]
            [ -1183.06441229,-89.8519518456,-121.864549681 ]
            [ -1181.74483207,-89.6273213728,-121.589969701 ]
            [ -1180.43318178,-89.4034437079,-121.317377115 ]
            [ -1179.12942341,-89.1803126382,-121.046771873 ]
            [ -1177.83351881,-88.9579219963,-120.77815447 ]
            [ -1176.53421843,-88.7344474088,-120.509194029 ]
            [ -1175.2426707,-88.5116995215,-120.242222692 ]
            [ -1173.95891164,-88.2896843735,-119.97725806 ]
            [ -1172.6829023,-88.0683959017,-119.714302681 ]
            [ -1171.40570899,-87.8463894746,-119.451515597 ]
            [ -1170.133841,-87.624720492,-119.190261473 ]
            [ -1168.86965461,-87.4037707393,-118.931041474 ]
            [ -1167.61310997,-87.1835342579,-118.673860142 ]
            [ -1166.35731752,-86.962900332,-118.417307187 ]
            [ -1165.10468869,-86.7422605373,-118.161897873 ]
            [ -1163.85963016,-86.5223268145,-117.908557907 ]
            [ -1162.62210106,-86.3030933089,-117.657293744 ]
            [ -1161.3869718,-86.0837357287,-117.407064422 ]
            [ -1160.15312217,-85.864076595,-117.15765805 ]
            [ -1158.92672691,-85.6451107305,-116.910363728 ]
            [ -1157.70774399,-85.4268323854,-116.665189735 ]
            [ -1156.49250708,-85.2086545584,-116.42140106 ]
            [ -1155.27695562,-84.989928783,-116.178184955 ]
            [ -1154.06873745,-84.7718838351,-115.937130705 ]
            [ -1152.86780926,-84.5545140692,-115.698248307 ]
            [ -1151.6716588,-84.3374190307,-115.461043332 ]
            [ -1150.47390145,-84.119580572,-115.224232426 ]
            [ -1149.28335064,-83.9024108647,-114.989639837 ]
            [ -1148.09996166,-83.6859043683,-114.757277154 ]
            [ -1146.92205463,-83.4697948516,-114.526823228 ]
            [ -1145.74156217,-83.2527989668,-114.296658189 ]
            [ -1144.56814326,-83.0364601287,-114.068774057 ]
            [ -1143.40175162,-82.8207729015,-113.843183868 ]
            [ -1142.24120568,-82.605551414,-113.619670596 ]
            [ -1141.0774214,-82.3893546991,-113.396415626 ]
            [ -1139.92057083,-82.1738037028,-113.175509672 ]
            [ -1138.77060592,-81.9588930942,-112.956967048 ]
            [ -1137.62649696,-81.7444619997,-112.740603897 ]
            [ -1136.47883417,-81.5290224304,-112.524544174 ]
            [ -1135.33795767,-81.3142176338,-112.310906387 ]
            [ -1134.20381749,-81.1000423843,-112.099705927 ]
            [ -1133.07517704,-80.8863039909,-111.890719449 ]
            [ -1131.9430163,-80.6715809651,-111.68215816 ]
            [ -1130.81748613,-80.4574821541,-111.476095715 ]
            [ -1129.69853444,-80.2440024379,-111.27254836 ]
            [ -1128.58434691,-80.030859093,-111.071178972 ]
            [ -1127.46703308,-79.8168134748,-110.870433887 ]
            [ -1126.35618502,-79.6033819071,-110.672267597 ]
            [ -1125.25174827,-79.3905593761,-110.476696942 ]
            [ -1124.15094797,-79.1779135676,-110.283195221 ]
            [ -1123.04778703,-78.9645077318,-110.090594741 ]
            [ -1121.95091711,-78.7517061824,-109.900654967 ]
            [ -1120.86028116,-78.5395040111,-109.713393035 ]
            [ -1119.7717491,-78.3272584752,-109.528015443 ]
            [ -1118.68200476,-78.114456354,-109.343894071 ]
            [ -1117.59836581,-77.9022491605,-109.162516032 ]
            [ -1116.5207724,-77.6906320928,-108.983898417 ]
            [ -1115.4433329,-77.478689928,-108.806902403 ]
            [ -1114.3662229,-77.2664570578,-108.631595548 ]
            [ -1113.29502083,-77.0548101681,-108.459113947 ]
            [ -1112.22966373,-76.8437445633,-108.289474257 ]
            [ -1111.16208082,-76.6320093524,-108.121112638 ]
            [ -1110.09677305,-76.4203129215,-107.954950675 ]
            [ -1109.03716282,-76.2091939412,-107.791693553 ]
            [ -1107.98318382,-75.9986478223,-107.631357055 ]
            [ -1106.92415734,-75.7870237599,-107.471871591 ]
            [ -1105.86976556,-75.5758326567,-107.315173064 ]
            [ -1104.82084691,-75.3652108973,-107.16145478 ]
            [ -1103.77522,-75.1548272468,-107.010317679 ]
            [ -1102.72549287,-74.9435460263,-106.860345185 ]
            [ -1101.68107222,-74.7328308882,-106.713409055 ]
            [ -1100.64188502,-74.5226774154,-106.569522267 ]
            [ -1099.60227784,-74.3122206474,-106.427609754 ]
            [ -1098.56176542,-74.1013951783,-106.287607357 ]
            [ -1097.52630747,-73.8911284401,-106.150704148 ]
            [ -1096.4958267,-73.6814161221,-106.016910657 ]
            [ -1095.46073805,-73.4707925624,-105.884392567 ]
            [ -1094.42838067,-73.2603966866,-105.754602991 ]
            [ -1093.40080809,-73.0505526288,-105.627964672 ]
            [ -1092.37570246,-72.8409133533,-105.50405283 ]
            [ -1091.34578553,-72.6303733157,-105.38148664 ]
            [ -1090.32045032,-72.4203827641,-105.262105549 ]
            [ -1089.29961105,-72.2109375605,-105.145913987 ]
            [ -1088.2760964,-72.0009511456,-105.031552981 ]
            [ -1087.25229366,-71.790800228,-104.91950542 ]
            [ -1086.23276825,-71.5811926675,-104.810668645 ]
            [ -1085.216775,-71.3720247681,-104.704917102 ]
            [ -1084.19376368,-71.1617005227,-104.600249025 ]
            [ -1083.17479858,-70.9519179226,-104.498801683 ]
            [ -1082.15978409,-70.7426730019,-104.40057058 ]
            [ -1081.14216438,-70.532981072,-104.304318981 ]
            [ -1080.12296666,-70.3230116938,-104.210258441 ]
            [ -1079.10747033,-70.1135786317,-104.119406073 ]
            [ -1078.09467084,-69.9045413442,-104.031579446 ]
            [ -1077.07440545,-69.6943744226,-103.94485993 ]
            [ -1076.05757758,-69.4847427402,-103.861324614 ]
            [ -1075.04407998,-69.2756425019,-103.780956476 ]
            [ -1074.02610768,-69.0659087501,-103.702283996 ]
            [ -1073.00705236,-68.8560689742,-103.625952028 ]
            [ -1071.991042,-68.6467599198,-103.552738295 ]
            [ -1070.97491617,-68.4375196459,-103.48204433 ]
            [ -1069.9526877,-68.2274633376,-103.412742427 ]
            [ -1068.93320136,-68.0179373199,-103.346487992 ]
            [ -1067.916336,-67.8089379658,-103.283246847 ]
            [ -1066.8911117,-67.5988343227,-103.220953864 ]
            [ -1065.86713078,-67.3890842592,-103.161392539 ]
            [ -1064.84544209,-67.179860786,-103.104739759 ]
            [ -1063.81876103,-66.9709357719,-103.049645737 ]
            [ -1062.78916678,-66.7634747814,-102.996504091 ]
            [ -1061.76148738,-66.5582033668,-102.946185136 ]
            [ -1060.73171679,-66.3545280991,-102.897915208 ]
            [ -1059.69532097,-66.1517796304,-102.850824245 ]
            [ -1058.66046441,-65.9511803895,-102.806386804 ]
            [ -1057.62595746,-65.7525584839,-102.764340955 ]
            [ -1056.58153672,-65.5543961879,-102.722753479 ]
            [ -1055.53825304,-65.3583430463,-102.683612727 ]
            [ -1054.49594926,-65.1643820844,-102.646834997 ]
            [ -1053.4435259,-64.9708774255,-102.61032981 ]
            [ -1052.39047979,-64.7792454114,-102.575778289 ]
            [ -1051.33797071,-64.5896658308,-102.543324461 ]
            [ -1050.27672807,-64.4007793127,-102.511206709 ]
            [ -1049.21248829,-64.2134445795,-102.480397206 ]
            [ -1048.14830758,-64.0281228067,-102.451369038 ]
            [ -1047.07627669,-63.8436609536,-102.422599495 ]
            [ -1045.99930299,-63.6605007999,-102.394525452 ]
            [ -1044.92187032,-63.4793144047,-102.367858193 ]
            [ -1043.83695748,-63.2990847197,-102.341223894 ]
            [ -1042.74558456,-63.1199776064,-102.31469689 ]
            [ -1041.6531883,-62.9428053174,-102.289135651 ]
            [ -1040.55315686,-62.766616377,-102.263225248 ]
            [ -1039.44557431,-62.5914419406,-102.236848961 ]
            [ -1038.33634992,-62.4181636578,-102.210921353 ]
            [ -1037.21879743,-62.2458252069,-102.184096495 ]
            [ -1036.09302454,-62.0744642699,-102.156236418 ]
            [ -1034.96492734,-61.9049610738,-102.128220662 ]
            [ -1033.82725647,-61.7362841214,-102.098582548 ]
            [ -1032.68111032,-61.5686186991,-102.06733055 ]
            [ -1031.53188084,-61.4027728557,-102.035218076 ]
            [ -1030.37126234,-61.2375697702,-102.000568132 ]
            [ -1029.20231695,-61.0734830729,-101.963700709 ]
            [ -1028.02943655,-60.9111780351,-101.925151996 ]
            [ -1026.84276136,-60.7492626388,-101.882945307 ]
            [ -1025.648295,-60.5886390703,-101.837874064 ]
            [ -1024.44892838,-60.4297594745,-101.790166135 ]
            [ -1023.23274545,-60.2709471377,-101.737455919 ]
            [ -1022.00967202,-60.1136722885,-101.681168394 ]
            [ -1020.77942726,-59.9579368408,-101.62093032 ]
            [ -1019.53102668,-59.8022116783,-101.554502822 ]
            [ -1018.27580543,-59.6481723139,-101.483491257 ]
            [ -1017.00917583,-59.4952134126,-101.406726649 ]
            [ -1015.72593943,-59.342648737,-101.322921973 ]
            [ -1014.43445497,-59.1917327802,-101.233096869 ]
            [ -1013.12659904,-59.0413702171,-101.135421181 ]
            [ -1011.80394268,-58.8918549025,-101.029705064 ]
            [ -1010.47134344,-58.7439514095,-100.916289447 ]
            [ -1009.11661756,-58.5960068653,-100.792592297 ]
            [ -1007.74908214,-58.4494309071,-100.659659208 ]
            [ -1006.36671965,-58.3040277208,-100.516579073 ]
            [ -1004.96127458,-58.1587271579,-100.361363458 ]
            [ -1003.54225323,-58.0149816356,-100.194985888 ]
            [ -1002.10098801,-57.8716806259,-100.015326801 ]
            [ -1000.6388187,-57.7291390811,-99.8219156953 ]
            [ -999.16017529,-57.5881161138,-99.6147556433 ]
            [ -997.660227315,-57.4467442992,-99.3983179938 ]
            [ -996.161182938,-57.3068547766,-99.1821079338 ]
            [ -994.657429438,-57.1676401172,-98.9652234154 ]
            [ -993.14718712,-57.0288340308,-98.7474028563 ]
            [ -991.638101476,-56.891490484,-98.5299354202 ]
            [ -990.118066403,-56.7538982546,-98.3108595926 ]
            [ -988.598006807,-56.6175691907,-98.091997792 ]
            [ -987.073675235,-56.4818928086,-97.8726799497 ]
            [ -985.542747547,-56.3465295474,-97.6525556438 ]
            [ -984.013194401,-56.2125731151,-97.4329454476 ]
            [ -982.472152226,-56.0782185295,-97.2117901653 ]
            [ -980.931923438,-55.9451604112,-96.9911060455 ]
            [ -979.386035419,-55.8124841615,-96.7698718152 ]
            [ -977.835222746,-55.6802769393,-96.548231524 ]
            [ -976.284200895,-55.5491755472,-96.3269623081 ]
            [ -974.72289325,-55.4177723695,-96.1044797107 ]
            [ -973.16323888,-55.2877011253,-95.8827083217 ]
            [ -971.59472893,-55.1574974651,-95.6600021156 ]
            [ -970.024751147,-55.0281646711,-95.4375541383 ]
            [ -968.450519691,-54.8993002943,-95.214945428 ]
            [ -966.87030529,-54.7706488361,-94.9919278408 ]
            [ -965.290055794,-54.6430112352,-94.7694532246 ]
            [ -963.699690874,-54.514992342,-94.5459709901 ]
            [ -962.111233546,-54.3882230095,-94.3233732267 ]
            [ -960.512695164,-54.2610504202,-94.0998224293 ]
            [ -958.914254203,-54.1348499462,-93.8769137957 ]
            [ -957.309106965,-54.0086794294,-93.653619644 ]
            [ -955.700770146,-53.8830037615,-93.4305017588 ]
            [ -954.088718097,-53.7577368473,-93.2074995551 ]
            [ -952.470575563,-53.6325423277,-92.984273528 ]
            [ -950.851324761,-53.5080812545,-92.7615992321 ]
            [ -949.223469464,-53.3833245806,-92.5383659406 ]
            [ -947.596728799,-53.25957231,-92.3160565382 ]
            [ -945.95925689,-53.1352104892,-92.0929168719 ]
            [ -944.324090101,-53.0119833731,-91.8709144219 ]
            [ -942.67775005,-52.8880610166,-91.6480657935 ]
            [ -941.033144963,-52.765166049,-91.4263046162 ]
            [ -939.378769378,-52.6417380696,-91.2039542825 ]
            [ -937.724829636,-52.5191325007,-90.9825355678 ]
            [ -936.062144526,-52.3961044367,-90.7607264892 ]
            [ -934.398977912,-52.2737456186,-90.5397520802 ]
            [ -932.727715299,-52.1510237128,-90.3185295668 ]
            [ -931.055433938,-52.0288690278,-90.0981021032 ]
            [ -929.375332529,-51.9063602104,-89.8775140671 ]
            [ -927.694053056,-51.7843669913,-89.6577371134 ]
            [ -926.004858897,-51.6619788554,-89.4378343075 ]
            [ -924.314702594,-51.5401042987,-89.2188124664 ]
            [ -922.616169697,-51.4177450663,-88.99964871 ]
            [ -920.917262596,-51.2959461367,-88.7814877241 ]
            [ -919.209153557,-51.1735246157,-88.5631201172 ]
            [ -917.501626514,-51.0517579424,-88.3459269604 ]
            [ -915.783713103,-50.9291834732,-88.1284160876 ]
            [ -914.067217918,-50.8073415723,-87.912233049 ]
            [ -912.339765574,-50.6845876271,-87.6957091726 ]
            [ -910.612973472,-50.5624335801,-87.4804491448 ]
            [ -908.877243394,-50.4396028848,-87.2651771796 ]
            [ -907.139952038,-50.3170472848,-87.0509108335 ]
            [ -905.396094691,-50.1940946493,-86.8370034246 ]
            [ -903.648113063,-50.0710483675,-86.6238056159 ]
            [ -901.896283773,-49.9479276713,-86.4113769793 ]
            [ -900.137432686,-49.8243017449,-86.199326926 ]
            [ -898.377791568,-49.7009657747,-85.9884929188 ]
            [ -896.607904156,-49.576671279,-85.7776743794 ]
            [ -894.837885515,-49.4527169117,-85.5682035416 ]
            [ -893.059538221,-49.3280194579,-85.3590540358 ]
            [ -891.278092553,-49.2032402894,-85.1509210624 ]
            [ -889.49236349,-49.0782070451,-84.943678688 ]
            [ -887.699358652,-48.9525139617,-84.7369803241 ]
            [ -885.905522763,-48.8269758857,-84.531656456 ]
            [ -884.101744862,-48.700396061,-84.3266064858 ]
            [ -882.296017626,-48.5737876543,-84.1228461069 ]
            [ -880.485331327,-48.4467419832,-83.9200324446 ]
            [ -878.667619611,-48.3189728735,-83.7179470007 ]
            [ -876.848433757,-48.1911744527,-83.5172868518 ]
            [ -875.020444199,-48.062382651,-83.3172064849 ]
            [ -873.189008889,-47.933265271,-83.1183761292 ]
            [ -871.354627707,-47.8038640986,-82.920881448 ]
            [ -869.510893766,-47.6733347017,-82.7240096934 ]
            [ -867.665111864,-47.5425913613,-82.5286425029 ]
            [ -865.814264533,-47.411223499,-82.3344629068 ]
            [ -863.955996993,-47.2789057991,-82.1412409745 ]
            [ -862.095325642,-47.1462557705,-81.9495789872 ]
            [ -860.228570973,-47.0127772444,-81.759099414 ]
            [ -858.355283532,-46.8783870467,-81.5697943092 ]
            [ -856.479272322,-46.7435451829,-81.382120958 ]
            [ -854.597222151,-46.6078005407,-81.1957571256 ]
            [ -852.708531218,-46.4710480749,-81.0106847938 ]
            [ -850.816840524,-46.3337231712,-80.8273377183 ]
            [ -848.92017484,-46.1955432833,-80.6455510887 ]
            [ -847.015825332,-46.0561313868,-80.4650957677 ]
            [ -845.108257648,-45.9160242647,-80.2864909484 ]
            [ -843.197332303,-45.775169751,-80.1097757264 ]
            [ -841.27767078,-45.6328459115,-79.9344718002 ]
            [ -839.35423268,-45.4896472022,-79.7611539722 ]
            [ -837.427344166,-45.3455748362,-79.5899318235 ]
            [ -835.495235381,-45.2003596975,-79.4207237044 ]
            [ -833.556282487,-45.0537472919,-79.2534873355 ]
            [ -831.61082835,-44.906132405,-79.08604644 ]
            [ -829.6556822,-44.7574620666,-78.9158563898 ]
            [ -827.688883949,-44.6074393145,-78.7428253015 ]
            [ -825.709883915,-44.455946432,-78.5669981037 ]
            [ -823.721238721,-44.3032624855,-78.3887002494 ]
            [ -821.722887894,-44.1493315271,-78.2080131557 ]
            [ -819.714395368,-43.9940487363,-78.0249851877 ]
            [ -817.69280492,-43.8369847243,-77.8394495369 ]
            [ -815.661560442,-43.6785302779,-77.6517956404 ]
            [ -813.620607766,-43.5186270741,-77.4621032572 ]
            [ -811.569895204,-43.3572161891,-77.2704518626 ]
            [ -809.508939772,-43.1941820399,-77.0768854492 ]
            [ -807.435683568,-43.0292039698,-76.8813239831 ]
            [ -805.352732442,-42.8625625291,-76.6840630465 ]
            [ -803.260042917,-42.6941956169,-76.4851795298 ]
            [ -801.157574535,-42.5240403399,-76.2847497647 ]
            [ -799.045289964,-42.3520329748,-76.0828494565 ]
            [ -796.922925792,-42.1780789723,-75.8795367904 ]
            [ -794.788883228,-42.0019072539,-75.6747738961 ]
            [ -792.645109265,-41.8237087935,-75.4687808795 ]
            [ -790.491575247,-41.6434156301,-75.2616291714 ]
            [ -788.328255713,-41.4609587616,-75.0533891597 ]
            [ -786.155128404,-41.2762681071,-74.8441300921 ]
            [ -783.972174256,-41.089272468,-74.633919975 ]
            [ -781.779377369,-40.8998994912,-74.4228254676 ]
            [ -779.576724967,-40.7080756318,-74.2109117718 ]
            [ -777.363773109,-40.5136677908,-73.9982157898 ]
            [ -775.140457374,-40.3165914717,-73.7847977082 ]
            [ -772.907394771,-40.1168525672,-73.5707561849 ]
            [ -770.664578286,-39.9143717703,-73.3561485644 ]
            [ -768.412003418,-39.7090684093,-73.1410301565 ]
            [ -766.149668048,-39.5008604225,-72.9254541109 ]
            [ -763.877572295,-39.2896643367,-72.709471291 ]
            [ -761.595718356,-39.0753952489,-72.4931301463 ]
            [ -759.304110334,-38.8579668116,-72.276476585 ]
            [ -757.002754058,-38.6372912224,-72.0595538471 ]
            [ -754.691656889,-38.4132792179,-71.8424023774 ]
            [ -752.370827518,-38.1858400727,-71.6250597015 ]
            [ -750.040275755,-37.9548816032,-71.4075603032 ]
            [ -747.700012317,-37.7203101773,-71.1899355046 ]
            [ -745.350048603,-37.4820307296,-70.9722133511 ]
            [ -742.990396469,-37.2399467832,-70.7544184991 ]
            [ -740.621067998,-36.9939604776,-70.5365721101 ]
            [ -738.242075279,-36.7439726037,-70.3186917499 ]
            [ -735.853430169,-36.4898826452,-70.1007912947 ]
            [ -733.455144073,-36.2315888282,-69.8828808438 ]
            [ -731.047227721,-35.9689881774,-69.6649666411 ]
            [ -728.629690951,-35.7019765802,-69.4470510043 ]
            [ -726.202542497,-35.4304488587,-69.2291322638 ]
            [ -723.765789793,-35.1542988492,-69.0112047115 ]
            [ -721.319372365,-34.8734091782,-68.7932564105 ]
            [ -718.863000847,-34.5876405549,-68.5752644523 ]
            [ -716.396715229,-34.2990498013,-68.3572278728 ]
            [ -713.920275902,-34.0090933578,-68.139180127 ]
            [ -711.433675624,-33.7177492693,-67.9211700532 ]
            [ -708.936906846,-33.4249951495,-67.7032458528 ]
            [ -706.42996171,-33.1308081635,-67.48545508 ]
            [ -703.912832032,-32.8351650094,-67.2678446309 ]
            [ -701.385509298,-32.5380418993,-67.0504607321 ]
            [ -698.847984646,-32.2394145409,-66.8333489286 ]
            [ -696.299594677,-31.9391576228,-66.6165392122 ]
            [ -693.740933629,-31.6373389294,-66.4000907419 ]
            [ -691.172022791,-31.3339373537,-66.1840477332 ]
            [ -688.592852384,-31.0289264844,-65.9684529394 ]
            [ -686.003412201,-30.7222793052,-65.7533483636 ]
            [ -683.403691588,-30.4139681737,-65.538775244 ]
            [ -680.793155568,-30.1038851569,-65.3247651236 ]
            [ -678.171994111,-29.7920322723,-65.1113623835 ]
            [ -675.540502279,-29.4784266436,-64.8986114287 ]
            [ -672.898668025,-29.1630379977,-64.6865503285 ]
            [ -670.246478726,-28.8458353255,-64.4752163065 ]
            [ -667.583427637,-28.5267123764,-64.2646396202 ]
            [ -664.909537484,-28.2056424082,-64.0548575286 ]
            [ -662.225239138,-27.8826593655,-63.8459105542 ]
            [ -659.530517999,-27.5577291478,-63.637832391 ]
            [ -656.825213791,-27.2307950342,-63.4306545327 ]
            [ -654.108573197,-26.9017106533,-63.2244033964 ]
            [ -651.381452885,-26.5705706163,-63.0191182349 ]
            [ -648.643835691,-26.2373373434,-62.8148288985 ]
            [ -645.895432305,-25.9019317191,-62.6115628163 ]
            [ -643.135675619,-25.5642323822,-62.4093461286 ]
            [ -640.365359464,-25.2243206888,-62.2082105188 ]
            [ -637.584463384,-24.8821551786,-62.0081816623 ]
            [ -634.792149022,-24.537571429,-61.8092826921 ]
            [ -631.988886815,-24.1905995965,-61.611539585 ]
            [ -629.174974128,-23.8412429471,-61.4149754948 ]
            [ -626.349839206,-23.489374147,-61.2196119621 ]
            [ -623.513373819,-23.134934073,-61.0254704147 ]
            [ -620.666180259,-22.7779685181,-60.8325696806 ]
            [ -617.806310048,-22.417788011,-60.6434554073 ]
            [ -614.932228193,-22.0537568502,-60.4606939206 ]
            [ -612.04464498,-21.6859238793,-60.284331039 ]
            [ -609.142863032,-21.3141274043,-60.1144164353 ]
            [ -606.227144162,-20.938348079,-59.9509944283 ]
            [ -603.298019226,-20.5586061166,-59.7941050708 ]
            [ -600.354119554,-20.1776448966,-59.6443342063 ]
            [ -597.395610822,-19.8051102235,-59.5034517736 ]
            [ -594.422178538,-19.4414465212,-59.3716172504 ]
            [ -591.433528236,-19.0863402771,-59.2488571017 ]
            [ -588.430548538,-18.7396500859,-59.1351866338 ]
            [ -585.412170052,-18.4009361006,-59.0306399577 ]
            [ -582.379503485,-18.0700805777,-58.9352286001 ]
            [ -579.332010187,-17.7467135126,-58.8489806373 ]
            [ -576.269953968,-17.4305807985,-58.7719145127 ]
            [ -573.193528856,-17.1214134913,-58.7040479347 ]
            [ -570.102378621,-16.8188551451,-58.6454044565 ]
            [ -566.997212755,-16.5227062614,-58.5959917209 ]
            [ -563.87726231,-16.232539325,-58.5558359403 ]
            [ -560.743554478,-15.9481954276,-58.5249355644 ]
            [ -557.59509515,-15.6692045203,-58.5033165499 ]
            [ -554.433051088,-15.3954221765,-58.4909694309 ]
            [ -551.256370604,-15.1263616294,-58.4879167022 ]
            [ -548.066201704,-14.8618695662,-58.4941425042 ]
            [ -544.861582543,-14.6014656073,-58.5096625377 ]
            [ -541.643503965,-14.3449669245,-58.5344561662 ]
            [ -538.411221094,-14.0919199198,-58.5685289928 ]
            [ -535.165449188,-13.8420943676,-58.6118571754 ]
            [ -531.905767063,-13.5950811263,-58.6644330887 ]
            [ -528.632515981,-13.3505874543,-58.7262310836 ]
            [ -525.345684674,-13.1082636019,-58.7972274766 ]
            [ -522.045162003,-12.8677419842,-58.877395926 ]
            [ -518.731412267,-12.6287444078,-58.9666942736 ]
            [ -515.403813459,-12.3908189473,-59.0650962196 ]
            [ -512.063096002,-12.153727509,-59.1725441898 ]
            [ -508.708851778,-11.9170496296,-59.2889972985 ]
            [ -505.341285952,-11.6804621373,-59.4143972136 ]
            [ -501.960596709,-11.4436408756,-59.5486800105 ]
            [ -498.566315138,-11.2061531384,-59.6917890142 ]
            [ -495.158980259,-10.9677304729,-59.8436417418 ]
            [ -491.738373481,-10.7279816819,-60.0041644188 ]
            [ -488.304409579,-10.486537945,-60.1732742981 ]
            [ -484.859429216,-10.2430877668,-60.351532612 ]
            [ -481.405320706,-9.997231718,-60.5394791374 ]
            [ -477.942274284,-9.74862864045,-60.7369709579 ]
            [ -474.470542572,-9.49694862187,-60.9438577859 ]
            [ -470.990022505,-9.24180203463,-61.1599896725 ]
            [ -467.500905048,-8.98284971594,-61.385204824 ]
            [ -464.003405209,-8.71975797471,-61.61933479 ]
            [ -460.497508143,-8.4521546863,-61.862208889 ]
            [ -456.983307715,-8.17968764272,-62.1136481086 ]
            [ -453.461034532,-7.90203034611,-62.3734648924 ]
            [ -449.930769227,-7.61883202907,-62.6414680189 ]
            [ -446.392478904,-7.32972350282,-62.9174617285 ]
            [ -442.846428597,-7.03439094606,-63.2012394651 ]
            [ -439.182104949,-6.71236834689,-63.494123876 ]
            [ -435.29769042,-6.34415227563,-63.7969999962 ]
            [ -431.205465172,-5.9306658983,-64.1089705517 ]
            [ -426.916671398,-5.47261511051,-64.4290919598 ]
            [ -422.441621808,-4.97050990457,-64.7563712532 ]
            [ -417.789793958,-4.42468301429,-65.0897636328 ]
            [ -412.969962322,-3.83531594819,-65.4281702622 ]
            [ -407.990220144,-3.20244438037,-65.7704377301 ]
            [ -402.858146925,-2.5259919746,-66.1153570162 ]
            [ -397.580823996,-1.80558772112,-66.4616922426 ]
            [ -392.16469609,-1.04133715026,-66.8083048917 ]
            [ -386.615685039,-0.234033549569,-67.1540866062 ]
            [ -380.939294726,0.61541496422,-67.4979245874 ]
            [ -375.140630238,1.50598533268,-67.8387056858 ]
            [ -369.22441628,2.43653957459,-68.1753206825 ]
            [ -363.195015941,3.40582653064,-68.5066686923 ]
            [ -357.056450002,4.41248518247,-68.8316616342 ]
            [ -350.813024142,5.45491777706,-69.1492373233 ]
            [ -344.467822529,6.53162505504,-69.4583460676 ]
            [ -338.023924667,7.64095735086,-69.7579666011 ]
            [ -331.485445003,8.78089771553,-70.0471360276 ]
            [ -324.85407309,9.94983332611,-70.3248855669 ]
            [ -318.133489557,11.145603469,-70.5903351139 ]
            [ -311.32535677,12.366394398,-70.8426054912 ]
            [ -304.432997722,13.6099472149,-71.0809168871 ]
            [ -297.457403586,14.8744504497,-71.3044738049 ]
            [ -290.402355946,16.1574331251,-71.5126338086 ]
            [ -283.268110414,17.4571617526,-71.7046881253 ]
            [ -276.057765715,18.7712652264,-71.8800963529 ]
            [ -268.772548,20.0977756058,-72.0383059518 ]
            [ -261.413679365,21.4347321023,-72.1788201128 ]
            [ -253.984317637,22.7797865448,-72.3013009941 ]
            [ -246.484102485,24.1313662263,-72.4052925175 ]
            [ -238.915877612,25.4872680535,-72.4905642353 ]
            [ -231.280517277,26.8457520432,-72.5568374833 ]
            [ -223.578725956,28.2051654613,-72.6038720038 ]
            [ -215.813638749,29.5634360203,-72.6316358427 ]
            [ -207.984011849,30.9194291163,-72.6398628588 ]
            [ -200.09375565,32.2710739123,-72.6286797072 ]
            [ -192.14150298,33.6173954034,-72.5978923227 ]
            [ -184.130500084,34.9566180296,-72.5476788101 ]
            [ -176.059932748,36.2878032451,-72.4779550558 ]
            [ -167.93285369,37.6093839876,-72.3889720599 ]
            [ -159.747843031,38.920670565,-72.2806575341 ]
            [ -151.509104596,40.2200662435,-72.1534348943 ]
            [ -143.214264776,41.5071809126,-72.0072030055 ]
            [ -134.866770647,42.7807099023,-71.8423875998 ]
            [ -126.466496048,44.0400183264,-71.6591297873 ]
            [ -118.013262097,45.2845309033,-71.4575809999 ]
            [ -109.510430325,46.5131911032,-71.2382497175 ]
            [ -100.957299375,47.7256336643,-71.0012838795 ]
            [ -92.3540708003,48.9213995877,-70.7469305047 ]
            [ -83.7016777674,50.0999742495,-70.4755263571 ]
            [ -74.994174221,51.2586200832,-70.270230398 ]
            [ -66.213489454,52.3903317906,-70.3879166211 ]
            [ -57.3723608592,53.4942869816,-70.8426892282 ]
            [ -48.4849075652,54.570346533,-71.6289943484 ]
            [ -39.5644738659,55.6185569214,-72.7405984545 ]
            [ -30.6238927748,56.6390926809,-74.1707607383 ]
            [ -21.6739579465,57.6323980329,-75.9126096866 ]
            [ -12.7252610654,58.5989546014,-77.9591810539 ]
            [ -3.78766235052,59.5393274543,-80.3035862562 ]
            [ 5.12906842745,60.4540904864,-82.9389793704 ]
            [ 14.0168151901,61.3439672403,-85.8590444067 ]
            [ 22.8675603787,62.2096682639,-89.0577683235 ]
            [ 31.6735193514,63.0519035857,-92.5295138325 ]
            [ 40.4269260861,63.8713642256,-96.2689855822 ]
            [ 49.120726335,64.6687794003,-100.271555458 ]
            [ 57.7478646692,65.4448548703,-104.533078913 ]
            [ 66.3011103,66.200263047,-109.049847081 ]
            [ 74.7731743052,66.9356563236,-113.81867327 ]
            [ 83.1567136457,67.6516705337,-118.836954496 ]
            [ 91.4439161579,68.3489000667,-124.102492105 ]
            [ 99.6268630387,69.0279287968,-129.613751908 ]
            [ 107.69694862,69.6892966151,-135.369570646 ]
            [ 115.643957548,70.3301360596,-141.370691164 ]
            [ 123.457860304,70.9476207659,-147.618986643 ]
            [ 131.127108401,71.5421772557,-154.114030253 ]
            [ 138.639996512,72.1142548416,-160.856370909 ]
            [ 145.983532975,72.6642666104,-167.846755838 ]
            [ 153.281543234,73.1924767276,-175.155448287 ]
            [ 160.418698427,73.6993231896,-182.740369397 ]
            [ 167.37342754,74.185126781,-190.603388182 ]
            [ 174.121484321,74.65016445,-198.745274266 ]
            [ 180.637968634,75.0947836772,-207.168211894 ]
            [ 186.892615328,75.5191833122,-215.869505106 ]
            [ 192.853574445,75.9236148319,-224.845776937 ]
            [ 198.486057067,76.3083233193,-234.090489941 ]
            [ 203.75146351,76.6735081087,-243.590649089 ]
            [ 208.607400726,77.0193083142,-253.322774114 ]
            [ 213.0082724,77.3457765739,-263.246207668 ]
            [ 216.950933825,77.6552542332,-273.440722125 ]
            [ 220.415415629,77.9498546967,-284.01456164 ]
            [ 223.32651064,78.2292769659,-294.940094902 ]
            [ 225.609094953,78.4934579972,-306.180639163 ]
            [ 227.190972037,78.7425986654,-317.68970537 ]
            [ 227.983176887,79.0288619702,-329.407862868 ]
            [ 227.922503805,79.4495870956,-341.263248319 ]
            [ 227.032712668,79.9988378987,-353.184912973 ]
            [ 225.346732934,80.6668264636,-365.114655354 ]
            [ 222.901124438,81.4432589103,-377.002430196 ]
            [ 219.733459298,82.3177863001,-388.804680769 ]
            [ 215.878194922,83.2807263589,-400.487622534 ]
            [ 211.367469176,84.3228537641,-412.019997434 ]
            [ 206.23048715,85.4354881888,-423.372730748 ]
            [ 200.491175878,86.6108668401,-434.520979246 ]
            [ 194.170747622,87.8416581349,-445.438822985 ]
            [ 187.287399605,89.1209909945,-456.099619144 ]
            [ 179.856194924,90.4424420426,-466.475762688 ]
            [ 171.889822804,91.79987549,-476.537484853 ]
            [ 163.399620711,93.1872485014,-486.251730166 ]
            [ 154.395480908,94.5985920022,-495.582143741 ]
            [ 144.887390902,96.0277401936,-504.487713308 ]
            [ 134.886019187,97.4682149088,-512.922426482 ]
            [ 124.402099943,98.9132741978,-520.835516281 ]
            [ 113.451820931,100.355133668,-528.168625348 ]
            [ 102.052845497,101.785513512,-534.858368246 ]
            [ 90.2320217741,103.194630079,-540.833656195 ]
            [ 78.0213487255,104.571794182,-546.018672053 ]
            [ 65.4675099598,105.904379718,-550.332289108 ]
            [ 52.6283483486,107.178535781,-553.692724512 ]
            [ 39.5776789782,108.379027976,-556.021418085 ]
            [ 26.4063249508,109.489736103,-557.24983893 ]
            [ 13.218123097,110.49479344,-557.327273915 ]
            [ 0.127067563253,111.379664362,-556.228701572 ]
            [ -12.7525560395,112.132732218,-553.959914793 ]
            [ -25.3165941401,112.74651651,-550.557696917 ]
            [ -37.4739425592,113.217995672,-546.088836568 ]
            [ -49.1607011171,113.548983351,-540.637452292 ]
            [ -60.3355650842,113.74502416,-534.298012074 ]
            [ -71.1022783193,113.871364132,-527.272913019 ]
            [ -81.6101709413,114.024557171,-519.778807805 ]
            [ -91.8181976611,114.21179424,-511.80535857 ]
            [ -101.675399071,114.440105432,-503.345004337 ]
            [ -111.124265729,114.71760608,-494.394987993 ]
            [ -120.100842542,115.053653499,-484.957853084 ]
            [ -128.535700362,115.459111094,-475.040119252 ]
            [ -136.353079931,115.946627056,-464.653142923 ]
            [ -143.468497556,116.530712513,-453.818255952 ]
            [ -149.787657945,117.229513893,-442.566543805 ]
            [ -155.207972699,118.062997378,-430.945192983 ]
            [ -159.623356467,119.051472406,-419.017544384 ]
            [ -162.924934955,120.215080167,-406.879359025 ]
            [ -165.011920934,121.57288691,-394.651053168 ]
            [ -165.803518498,123.139657619,-382.48300236 ]
            [ -165.255294156,124.922371353,-370.549317345 ]
            [ -163.375421207,126.916624756,-359.034867061 ]
            [ -160.232706655,129.105301626,-348.111680956 ]
            [ -155.950826011,131.460198045,-337.915221325 ]
            [ -150.690096427,133.946136618,-328.529602729 ]
            [ -144.621923745,136.526704548,-319.984532519 ]
            [ -137.913717958,139.166595651,-312.268672801 ]
            [ -130.706920611,141.837308774,-305.337650033 ]
            [ -123.120890873,144.515002314,-299.133683693 ]
            [ -115.258823957,147.178620642,-293.595610879 ]
            [ -107.193515196,149.814812851,-288.659839355 ]
            [ -98.9911742249,152.410642772,-284.269655769 ]
            [ -90.703505763,154.956578397,-280.37316479 ]
            [ -82.3826985248,157.442039928,-276.924576199 ]
            [ -74.0638963155,159.861270845,-273.882394696 ]
            [ -65.7813287616,162.20726002,-271.205873456 ]
            [ -57.5884148235,164.463689627,-268.866825158 ]
            [ -49.5144506194,166.62799344,-266.889326609 ]
            [ -41.613862623,168.691230518,-265.298431285 ]
            [ -33.9519537823,170.642010062,-264.113676364 ]
            [ -26.5805801583,172.474273548,-263.352190008 ]
            [ -19.5869570679,174.171138633,-263.012033923 ]
            [ -13.0511048639,175.717724609,-263.072576984 ]
            [ -7.04873770348,177.098625635,-263.483617692 ]
            [ -1.65563266448,178.293292201,-264.144320485 ]
            [ 3.08807882835,179.284679079,-264.907334169 ]
            [ 7.3644582779,180.136838459,-265.805989239 ]
            [ 11.3482189065,180.923507704,-266.975570247 ]
            [ 15.0238115503,181.64447333,-268.378830078 ]
            [ 18.3885098614,182.30156097,-269.97290679 ]
            [ 21.4521556542,182.898768663,-271.714327408 ]
            [ 24.2342435392,183.44188275,-273.563653951 ]
            [ 26.7582976077,183.949292081,-275.482111164 ]
            [ 29.0503763628,184.438800071,-277.437214765 ]
            [ 31.1371090154,184.916347609,-279.410972141 ]
            [ 33.0420607566,185.38675388,-281.3882134 ]
            [ 34.7852028666,185.854463883,-283.359932584 ]
            [ 36.3831525574,186.322823471,-285.318123102 ]
            [ 37.8495430898,186.794455918,-287.256581995 ]
            [ 39.19545376,187.271363281,-289.170339505 ]
            [ 40.4298581269,187.755021545,-291.055215698 ]
            [ 41.5600441696,188.246464098,-292.907494451 ]
            [ 42.5923159783,188.746166685,-294.722726201 ]
            [ 43.5316186788,189.254504324,-296.497755662 ]
            [ 44.3820198528,189.771629198,-298.229651346 ]
            [ 45.1474938854,190.297205615,-299.914179138 ]
            [ 45.8308435067,190.831079424,-301.548953791 ]
            [ 46.4347990982,191.372781563,-303.130825769 ]
            [ 46.9619928532,191.921608633,-304.656281718 ]
            [ 47.4141868906,192.477054346,-306.123272498 ]
            [ 47.7932390352,193.038355687,-307.529127963 ]
            [ 48.1339764308,193.604671976,-308.88719652 ]
            [ 48.4705967805,194.17510578,-310.213825632 ]
            [ 48.8036091858,194.748760091,-311.511027479 ]
            [ 49.1333041118,195.324720315,-312.780731882 ]
            [ 49.4598773313,195.902011545,-314.02461762 ]
            [ 49.783401166,196.479631763,-315.244230228 ]
            [ 50.103849345,197.056554631,-316.440985117 ]
            [ 50.4211018971,197.631741021,-317.616200248 ]
            [ 50.7349704105,198.204137493,-318.771086391 ]
            [ 51.0452358323,198.772665111,-319.906713057 ]
            [ 51.3516474063,199.33622851,-321.024039531 ]
            [ 51.653934376,199.893716578,-322.123919414 ]
            [ 51.9518147074,200.444003693,-323.20710738 ]
            [ 52.2447623137,200.986102802,-324.274661315 ]
            [ 52.5326317352,201.518781338,-325.326921149 ]
            [ 52.8151413623,202.040882733,-326.36438761 ]
            [ 53.0918160784,202.551376295,-327.387816552 ]
            [ 53.3623068777,203.049154683,-328.397707443 ]
            [ 53.6265359937,203.532928957,-329.394089518 ]
            [ 53.8838848507,204.001786587,-330.377822861 ]
            [ 54.1342227608,204.454489209,-331.34896511 ]
            [ 54.3773785439,204.889829577,-332.307622675 ]
            [ 54.6126646656,205.306987721,-333.25468977 ]
            [ 54.8403948479,205.704419902,-334.189488053 ]
            [ 55.0595901956,206.081553602,-335.113330365 ]
            [ 55.2707179035,206.436735704,-336.02528527 ]
            [ 55.4728327654,206.769401895,-336.926580981 ]
            [ 55.6663461306,207.077939225,-337.816356261 ]
            [ 55.8502588313,207.361856072,-338.695884445 ]
            [ 56.0250773316,207.619453263,-339.564135209 ]
            [ 56.189664274,207.850373198,-340.42254397 ]
            [ 56.3444659879,208.052947091,-341.270131342 ]
            [ 56.4917785734,208.239716319,-342.105565807 ]
            [ 56.6348733605,208.423296044,-342.926482446 ]
            [ 56.7739881528,208.603517647,-343.73284438 ]
            [ 56.9086057556,208.780888909,-344.525733501 ]
            [ 57.0394671364,208.954802845,-345.30435763 ]
            [ 57.166275519,209.125583871,-346.069463322 ]
            [ 57.2890304111,209.293300963,-346.821352743 ]
            [ 57.4081949455,209.45759159,-347.559642117 ]
            [ 57.5234549033,209.618824164,-348.285091468 ]
            [ 57.6349224982,209.776975081,-348.997828766 ]
            [ 57.7429834683,209.9317542,-349.697579277 ]
            [ 57.8474966387,210.083383409,-350.384839407 ]
            [ 57.9483016968,210.232116421,-351.060129358 ]
            [ 58.0458980336,210.377551358,-351.723002603 ]
            [ 58.140346486,210.519719792,-352.373652565 ]
            [ 58.2312962375,210.659082248,-353.012869502 ]
            [ 58.3191000092,210.795384056,-353.640415357 ]
            [ 58.4039670428,210.928512269,-354.256259878 ]
            [ 58.4859623032,211.058503889,-354.860580551 ]
            [ 58.5648031484,211.185771457,-355.454056556 ]
            [ 58.6407861,211.310114609,-356.03652336 ]
            [ 58.7141145554,211.431427161,-356.607949819 ]
            [ 58.7848552757,211.549749598,-357.168500492 ]
            [ 58.8530327644,211.665170344,-357.718398353 ]
            [ 58.9183966031,211.778088311,-358.258260962 ]
            [ 58.9813897459,211.888130387,-358.787700188 ]
            [ 59.0420787194,211.995339007,-359.306869962 ]
            [ 59.100529848,212.099756896,-359.815921635 ]
            [ 59.1568091454,212.201426989,-360.315004102 ]
            [ 59.2107677564,212.300641877,-360.804573229 ]
            [ 59.2625820334,212.39731945,-361.284612566 ]
            [ 59.312432262,212.491368605,-361.755097268 ]
            [ 59.3603818137,212.582832518,-362.216168154 ]
            [ 59.4064933148,212.671754276,-362.667964052 ]
            [ 59.4508285717,212.758176827,-363.110621889 ]
            [ 59.4934485041,212.842142937,-363.544276765 ]
            [ 59.5341807977,212.92397731,-363.969396336 ]
            [ 59.5733119157,213.003448949,-364.385784692 ]
            [ 59.6109142782,213.08058196,-364.793551005 ]
            [ 59.6470443445,213.155418074,-365.192824269 ]
            [ 59.6817574336,213.227998664,-365.583731957 ]
            [ 59.7151076849,213.298364713,-365.966400076 ]
            [ 59.7471480231,213.366556788,-366.340953224 ]
            [ 59.7779301259,213.432615019,-366.707514631 ]
            [ 59.8075017133,213.496582464,-367.066210074 ]
            [ 59.8357518109,213.55870125,-367.417390246 ]
            [ 59.862898229,213.618796151,-367.760930177 ]
            [ 59.8889871783,213.676905469,-368.096948447 ]
            [ 59.9140635277,213.733066981,-368.425562473 ]
            [ 59.9381707934,213.787317927,-368.746888547 ]
            [ 59.9613511297,213.839695003,-369.061041867 ]
            [ 59.983645323,213.890234348,-369.368136573 ]
            [ 60.0050927881,213.938971536,-369.668285783 ]
            [ 60.0257315667,213.985941573,-369.961601619 ]
            [ 60.0455983286,214.031178886,-370.24819524 ]
            [ 60.0647283741,214.074717321,-370.528176874 ]
            [ 60.0831556391,214.116590142,-370.801655841 ]
            [ 60.1009127017,214.156830021,-371.068740583 ]
            [ 60.1180307906,214.195469046,-371.329538689 ]
            [ 60.1344901076,214.232604392,-371.584228269 ]
            [ 60.1503423615,214.268236709,-371.832882041 ]
            [ 60.1656456594,214.302355536,-372.075560874 ]
            [ 60.1804258097,214.334990714,-372.312369394 ]
            [ 60.1947073383,214.3661715,-372.543411487 ]
            [ 60.2085135049,214.395926562,-372.768790325 ]
            [ 60.2218663189,214.424283989,-372.988608387 ]
            [ 60.2347865578,214.451271291,-373.202967482 ]
            [ 60.2472937851,214.476915402,-373.411968769 ]
            [ 60.25940637,214.501242686,-373.615712777 ]
            [ 60.2711415064,214.524278942,-373.814299428 ]
            [ 60.2825152338,214.546049407,-374.007828055 ]
            [ 60.2935424581,214.566578764,-374.196397424 ]
            [ 60.3042369722,214.585891143,-374.38010575 ]
            [ 60.3146114782,214.604010133,-374.55905072 ]
            [ 60.3246776092,214.620958783,-374.733329508 ]
            [ 60.3344459509,214.636759613,-374.903038795 ]
            [ 60.3439260647,214.651434615,-375.06827479 ]
            [ 60.3531265092,214.665005265,-375.229133242 ]
            [ 60.3620548636,214.677492527,-375.385709464 ]
            [ 60.3707177494,214.688916861,-375.538098345 ]
            [ 60.3791208535,214.699298231,-375.686394369 ]
            [ 60.3872689507,214.70865611,-375.830691636 ]
            [ 60.3951659255,214.717009491,-375.97108387 ]
            [ 60.4028147949,214.72437689,-376.107664443 ]
            [ 60.41021773,214.730776359,-376.240526387 ]
            [ 60.4173760782,214.73622549,-376.369762412 ]
            [ 60.4242903847,214.740741423,-376.49546492 ]
            [ 60.4309604134,214.744340855,-376.61772602 ]
            [ 60.4373851684,214.747040049,-376.736637546 ]
            [ 60.4435629142,214.748854838,-376.852291068 ]
            [ 60.449491196,214.749800638,-376.96477791 ]
            [ 60.4551668599,214.749892452,-377.074189161 ]
            [ 60.4605860715,214.749144879,-377.180615692 ]
            [ 60.4657443356,214.747572122,-377.284148167 ]
            [ 60.4706365138,214.745187999,-377.38487706 ]
            [ 60.4752568431,214.742005945,-377.482892665 ]
            [ 60.4795989525,214.738039026,-377.57828511 ]
            [ 60.4836558802,214.733299942,-377.671144371 ]
            [ 60.4874200895,214.727801039,-377.761560282 ]
            [ 60.4908834843,214.721554315,-377.849622549 ]
            [ 60.4940374239,214.714571426,-377.935420763 ]
            [ 60.496872737,214.706863699,-378.019044406 ]
            [ 60.4993797353,214.698442134,-378.100582869 ]
            [ 60.5015482262,214.689317416,-378.180125459 ]
            [ 60.5033675246,214.679499923,-378.257761411 ]
            [ 60.5047901174,214.668870465,-378.333580502 ]
            [ 60.5053305644,214.65575427,-378.407678728 ]
            [ 60.5048271116,214.639630875,-378.480144542 ]
            [ 60.5032621442,214.620495542,-378.551063761 ]
            [ 60.5006171013,214.59834324,-378.620522228 ]
            [ 60.4968724711,214.573168665,-378.688605813 ]
            [ 60.4920077838,214.544966247,-378.755400402 ]
            [ 60.4860016041,214.513730168,-378.820991894 ]
            [ 60.4788315226,214.479454373,-378.885466194 ]
            [ 60.4704741464,214.442132585,-378.948909207 ]
            [ 60.4609050878,214.40175832,-379.011406827 ]
            [ 60.450098953,214.358324902,-379.073044933 ]
            [ 60.4380293286,214.311825477,-379.133909376 ]
            [ 60.424668768,214.262253032,-379.194085969 ]
            [ 60.4099887757,214.209600408,-379.253660479 ]
            [ 60.3939540313,214.153867919,-379.312726881 ]
            [ 60.3765020562,214.095090114,-379.371416523 ]
            [ 60.3576381644,214.033210526,-379.429761735 ]
            [ 60.3373295167,213.968221551,-379.487847922 ]
            [ 60.3155421301,213.90011553,-379.545760369 ]
            [ 60.292240856,213.828884771,-379.603584225 ]
            [ 60.2673893561,213.754521566,-379.661404483 ]
            [ 60.2409500775,213.677018216,-379.719305964 ]
            [ 60.2128842269,213.59636705,-379.777373288 ]
            [ 60.1831517427,213.512560449,-379.835690858 ]
            [ 60.1517112667,213.425590867,-379.89434283 ]
            [ 60.1185201143,213.335450859,-379.953413087 ]
            [ 60.0835342435,213.242133104,-380.012985215 ]
            [ 60.0467082223,213.145630429,-380.073142465 ]
            [ 60.007995196,213.045935841,-380.133967728 ]
            [ 59.967346852,212.943042551,-380.195543497 ]
            [ 59.9247133848,212.836944002,-380.257951831 ]
            [ 59.8800434587,212.727633905,-380.321274317 ]
            [ 59.8332841705,212.615106265,-380.385592028 ]
            [ 59.7843810107,212.499355413,-380.45098548 ]
            [ 59.7332778234,212.380376046,-380.517534587 ]
            [ 59.6799167665,212.258163255,-380.585318607 ]
            [ 59.6242382694,212.132712566,-380.654416098 ]
            [ 59.5661809914,212.004019973,-380.724904857 ]
            [ 59.5056817789,211.872081986,-380.796861864 ]
            [ 59.4426756215,211.736895662,-380.870363221 ]
            [ 59.3770956087,211.598458653,-380.945484089 ]
            [ 59.3088728852,211.45676925,-381.022298618 ]
            [ 59.2379366065,211.311826427,-381.100879873 ]
            [ 59.1642138941,211.16362989,-381.181299764 ]
            [ 59.087629791,211.012180126,-381.263628962 ]
            [ 59.0081072172,210.857478456,-381.347936817 ]
            [ 58.9255669255,210.699527086,-381.434291267 ]
            [ 58.8399274578,210.538329164,-381.522758752 ]
            [ 58.7513021784,210.373888277,-381.610856197 ]
            [ 58.6598309344,210.206209044,-381.696051948 ]
            [ 58.5654596223,210.035309729,-381.778352372 ]
            [ 58.4681115088,209.861236228,-381.857794535 ]
            [ 58.3677789927,209.683946437,-381.93431431 ]
            [ 58.264412621,209.503450391,-382.007905894 ]
            [ 58.1579612949,209.319759521,-382.078564029 ]
            [ 58.0483722609,209.132886735,-382.146284027 ]
            [ 57.9355911031,208.942846489,-382.211061798 ]
            [ 57.8195617391,208.749654872,-382.272893872 ]
            [ 57.7002264183,208.553329693,-382.331777431 ]
            [ 57.5775257233,208.353890563,-382.387710335 ]
            [ 57.4513985747,208.151358989,-382.440691152 ]
            [ 57.3217822392,207.945758468,-382.490719191 ]
            [ 57.1886123422,207.737114583,-382.537794531 ]
            [ 57.0518228836,207.525455105,-382.581918052 ]
            [ 56.9113462589,207.310810097,-382.623091474 ]
            [ 56.7671132849,207.093212021,-382.661317386 ]
            [ 56.6190532304,206.872695854,-382.696599286 ]
            [ 56.4670938527,206.649299198,-382.728941614 ]
            [ 56.3111614401,206.423062403,-382.758349791 ]
            [ 56.1511808605,206.194028688,-382.78483026 ]
            [ 55.9870756175,205.962244271,-382.80839052 ]
            [ 55.8193562843,205.727495495,-382.829104957 ]
            [ 55.6485400443,205.489552312,-382.847052859 ]
            [ 55.4745582555,205.24844025,-382.862250543 ]
            [ 55.2973408903,205.004187027,-382.874715219 ]
            [ 55.116816601,204.756822654,-382.884465023 ]
            [ 54.9329127931,204.506379557,-382.891519051 ]
            [ 54.7455557081,204.252892694,-382.895897397 ]
            [ 54.5546705153,203.996399676,-382.897621185 ]
            [ 54.3601814144,203.736940896,-382.896712612 ]
            [ 54.1620117487,203.474559657,-382.893194982 ]
            [ 53.9600841301,203.209302311,-382.887092745 ]
            [ 53.7543205769,202.941218391,-382.878431539 ]
            [ 53.5446426645,202.670360756,-382.867238226 ]
            [ 53.3309716914,202.396785733,-382.853540938 ]
            [ 53.1132288591,202.120553268,-382.837369113 ]
            [ 52.8913350164,201.841726369,-382.818753958 ]
            [ 52.6652057971,201.560363536,-382.797733087 ]
            [ 52.4347612681,201.276533778,-382.774341765 ]
            [ 52.1999240806,200.990313177,-382.748615053 ]
            [ 51.9606179527,200.701782217,-382.720589537 ]
            [ 51.7167679637,200.411025941,-382.690303362 ]
            [ 51.4683008714,200.11813411,-382.657796282 ]
            [ 51.2151454536,199.823201366,-382.623109696 ]
            [ 50.957232875,199.526327384,-382.586286698 ]
            [ 50.6944970809,199.227617028,-382.547372112 ]
            [ 50.4268712575,198.927185288,-382.506418238 ]
            [ 50.1542779228,198.625169923,-382.463499804 ]
            [ 49.876685016,198.321664437,-382.418633957 ]
            [ 49.5940421208,198.016795899,-382.371872841 ]
            [ 49.3063040083,197.710697263,-382.323270528 ]
            [ 49.0134312146,197.403507475,-382.272883053 ]
            [ 48.7153906518,197.095371578,-382.220768446 ]
            [ 48.4121562526,196.786440794,-382.166986762 ]
            [ 48.1037096512,196.476872591,-382.111600106 ]
            [ 47.7900408983,196.166830735,-382.054672662 ]
            [ 47.4711492112,195.856485311,-381.996270712 ]
            [ 47.1470437583,195.546012729,-381.936462651 ]
            [ 46.8177444775,195.235595695,-381.875318999 ]
            [ 46.4832829261,194.925423154,-381.812912412 ]
            [ 46.1437031621,194.615690197,-381.74931768 ]
            [ 45.7990626526,194.306597938,-381.684611723 ]
            [ 45.4494332081,193.998353337,-381.618873582 ]
            [ 45.0949019376,193.691168994,-381.552184397 ]
            [ 44.7355722204,193.385262885,-381.484627382 ]
            [ 44.3715646896,193.080858049,-381.416287788 ]
            [ 44.0030182207,192.778182228,-381.347252857 ]
            [ 43.6300909176,192.47746744,-381.277611767 ]
            [ 43.2529610884,192.178949501,-381.20745556 ]
            [ 42.8718282018,191.882867481,-381.136877065 ]
            [ 42.4869138123,191.589463096,-381.065970806 ]
            [ 42.0984624435,191.298980039,-380.994832889 ]
            [ 41.7067424177,191.011663241,-380.923560885 ]
            [ 41.3120466155,190.727758069,-380.852253688 ]
            [ 40.9146931538,190.447509463,-380.781011365 ]
            [ 40.5150259633,190.17116101,-380.70993498 ]
            [ 40.1134152518,189.898953958,-380.639126412 ]
            [ 39.7102578355,189.631126184,-380.568688144 ]
            [ 39.3010321278,189.373831094,-380.505844925 ]
            [ 38.8811376041,189.133359668,-380.457972991 ]
            [ 38.450898106,188.910167248,-380.425393033 ]
            [ 38.010671465,188.7047284,-380.408412323 ]
            [ 37.560763874,188.517641109,-380.407446922 ]
            [ 37.1015433992,188.349491881,-380.422856877 ]
            [ 36.6335714882,188.200695337,-380.454755454 ]
            [ 36.1573425175,188.0718099,-380.503382234 ]
            [ 35.6733848805,187.963416767,-380.568955494 ]
            [ 35.1822607591,187.876121225,-380.651670225 ]
            [ 34.6843345911,187.810847828,-380.752028323 ]
            [ 34.1802197407,187.768285748,-380.870193685 ]
            [ 33.6707844605,187.748868834,-381.005981284 ]
            [ 33.1567077861,187.753344123,-381.159492318 ]
            [ 32.6381700435,187.783209689,-381.331555154 ]
            [ 32.1164620038,187.838584133,-381.521412027 ]
            [ 31.5921686428,187.920612143,-381.729324198 ]
            [ 31.0658866105,188.03054435,-381.955539137 ]
            [ 30.5388541832,188.168839458,-382.199383907 ]
            [ 30.0113958915,188.337388049,-382.461496711 ]
            [ 29.485002898,188.536519664,-382.740837757 ]
            [ 28.9601295318,188.768255214,-383.037854353 ]
            [ 28.4359284801,189.032259443,-383.351389283 ]
            [ 27.9103605019,189.329001947,-383.681019921 ]
            [ 27.383671069,189.659665813,-384.026082824 ]
            [ 26.8563358581,190.025387166,-384.385664842 ]
            [ 26.3287480003,190.427822875,-384.759060121 ]
            [ 25.8015923212,190.868523117,-385.145233268 ]
            [ 25.2757625904,191.349069412,-385.542943037 ]
            [ 24.7522533873,191.871306858,-385.950906922 ]
            [ 24.2322758915,192.437141752,-386.36763899 ]
            [ 23.7172686771,193.048521618,-386.791439864 ]
            [ 23.2089053198,193.70741303,-387.220390644 ]
            [ 22.7091004003,194.41577074,-387.652347783 ]
            [ 22.2199962795,195.175546057,-388.084965755 ]
            [ 21.7439806893,195.988592778,-388.515669455 ]
            [ 21.2836503365,196.85670863,-388.941707431 ]
            [ 20.841804808,197.781575914,-389.360154991 ]
            [ 20.4214203121,198.764744564,-389.767945308 ]
            [ 20.0256206537,199.807611142,-390.161901625 ]
            [ 19.6576438662,200.911401392,-390.538773243 ]
            [ 19.3210076248,202.075545861,-390.894818334 ]
            [ 19.0189939724,203.300179443,-391.22673218 ]
            [ 18.7546768758,204.587129347,-391.531751586 ]
            [ 18.5313043188,205.936125291,-391.806681168 ]
            [ 18.3504566926,207.337070165,-392.047541469 ]
            [ 18.1841076425,208.802891165,-392.265625287 ]
            [ 18.0215608719,210.33042077,-392.466455856 ]
            [ 17.8630322066,211.907197895,-392.650807278 ]
            [ 17.7083848353,213.54249686,-392.821677407 ]
            [ 17.5575956236,215.23951196,-392.98064814 ]
            [ 17.4106902683,216.998682701,-393.128677195 ]
            [ 17.2676964492,218.820744064,-393.266540242 ]
            [ 17.1286987701,220.7019324,-393.394549352 ]
            [ 16.9937130509,222.644404134,-393.513368313 ]
            [ 16.8627373509,224.653541328,-393.623687553 ]
            [ 16.7358284094,226.730669958,-393.725810325 ]
            [ 16.6130526655,228.877227456,-393.819975012 ]
            [ 16.4944871874,231.094748955,-393.906364395 ]
            [ 16.3802205344,233.384856706,-393.985113145 ]
            [ 16.2703681184,235.746119442,-394.056221632 ]
            [ 16.1650636614,238.179147191,-394.11949198 ]
            [ 16.0644355503,240.689982856,-394.174825838 ]
            [ 15.9686257568,243.280493526,-394.222216557 ]
            [ 15.8777917447,245.952606274,-394.261631535 ]
            [ 15.7921073451,248.708302999,-394.293014379 ]
            [ 15.7117636565,251.549615037,-394.316286741 ]
            [ 15.6369471013,254.470404067,-394.331306337 ]
            [ 15.5678877779,257.480445754,-394.338044175 ]
            [ 15.5048330755,260.582175228,-394.33636632 ]
            [ 15.4480508433,263.777748113,-394.326119934 ]
            [ 15.3978308827,267.069335052,-394.30713678 ]
            [ 15.3544047089,270.449944497,-394.279305445 ]
            [ 15.3181556467,273.929873948,-394.24241179 ]
            [ 15.2894487599,277.512028078,-394.196242718 ]
            [ 15.2686689921,281.198520526,-394.14057783 ]
            [ 15.2560888167,284.981700378,-394.075348253 ]
            [ 15.2522316385,288.871637645,-394.000223028 ]
            [ 15.2577766226,292.87091159,-393.914947872 ]
            [ 15.2756368239,296.966585551,-393.819569617 ]
            [ 15.3069509946,301.156930312,-393.713926636 ]
            [ 15.3522379623,305.44991127,-393.597619333 ]
            [ 15.4117900502,309.840633314,-393.470558062 ]
            [ 15.4860562427,314.330629215,-393.332501513 ]
            [ 15.5756745538,318.927020261,-393.183025273 ]
            [ 15.6808543508,323.619355828,-393.022245519 ]
            [ 15.802384477,328.417519909,-392.849641 ]
            [ 15.9406965758,333.317268526,-392.665144063 ]
            [ 16.0963219329,338.317229403,-392.468606574 ]
            [ 16.2699839205,343.420647304,-392.259706391 ]
            [ 16.4620240148,348.619344236,-392.038571463 ]
            [ 16.6733490893,353.919736766,-391.804755272 ]
            [ 16.9041908422,359.310469254,-391.558555307 ]
            [ 17.1555135409,364.797665765,-391.299535628 ]
            [ 17.4275229262,370.369611795,-391.028059415 ]
            [ 17.7211063442,376.029543997,-390.743827476 ]
            [ 18.0365222102,381.767422684,-390.447177631 ]
            [ 18.3744499334,387.581876613,-390.13805268 ]
            [ 18.735265177,393.465830347,-389.816694628 ]
            [ 19.1193245156,399.412440805,-389.483362468 ]
            [ 19.5271633311,405.418202811,-389.138157851 ]
            [ 19.9587296905,411.470742903,-388.781691792 ]
            [ 20.4146201627,417.568510792,-388.414003292 ]
            [ 20.8946670538,423.699116647,-388.035768239 ]
            [ 21.3991305206,429.857324253,-387.647282144 ]
            [ 21.9279692329,436.034437638,-387.249067749 ]
            [ 22.4809623761,442.220503032,-386.841757867 ]
            [ 23.0581727583,448.410040646,-386.425735125 ]
            [ 23.6590377997,454.591010139,-386.001824852 ]
            [ 24.2835061725,460.75840651,-385.570430157 ]
            [ 24.9310073571,466.90227837,-385.132300786 ]
            [ 25.6011366573,473.015551093,-384.688023499 ]
            [ 26.2933527032,479.090641667,-384.238242282 ]
            [ 27.0070206226,485.119996753,-383.783623165 ]
            [ 27.7415543655,491.097419304,-383.324758035 ]
            [ 28.4962085595,497.016068569,-382.862304384 ]
            [ 29.2703009468,502.870479508,-382.396838265 ]
            [ 30.0630640321,508.655167584,-381.928952809 ]
            [ 30.8737131201,514.365200384,-381.459214731 ]
            [ 31.7014849838,519.996435886,-380.988142995 ]
            [ 32.5455579439,525.544836383,-380.516259408 ]
            [ 33.4051053853,531.006859466,-380.044057083 ]
            [ 34.2794347068,536.38036896,-379.571923654 ]
            [ 35.1675636137,541.661594957,-379.100386137 ]
            [ 36.0689207399,546.849961371,-378.629714723 ]
            [ 36.9826238141,551.943068539,-378.160333027 ]
            [ 37.9077895265,556.938869231,-377.692641055 ]
            [ 38.8439919874,561.838372691,-377.226776947 ]
            [ 39.7903420261,566.639882201,-376.763111322 ]
            [ 40.7460159294,571.342355874,-376.301961271 ]
            [ 41.7104003052,575.946124528,-375.84352177 ]
            [ 42.6832380119,580.453496302,-375.387802544 ]
            [ 43.6634840471,584.862542936,-374.935197047 ]
            [ 44.6505399202,589.173907196,-374.485864095 ]
            [ 45.6438344695,593.388412051,-374.039942098 ]
            [ 46.6429065566,597.507437923,-373.597511852 ]
            [ 47.6475499568,601.533534014,-373.158533721 ]
            [ 48.6568736062,605.465972786,-372.723281823 ]
            [ 49.6703991241,609.306046537,-372.29183214 ]
            [ 50.6876696233,613.055124787,-371.864248105 ]
            [ 51.7082482961,616.714638752,-371.440581958 ]
            [ 52.7317169552,620.286067412,-371.020876018 ]
            [ 53.7576745475,623.770925084,-370.605163873 ]
            [ 54.7908266242,627.190904469,-370.19132928 ]
            [ 55.8361029347,630.566660953,-369.7772638 ]
            [ 56.8934502266,633.898172238,-369.363006365 ]
            [ 57.9628145284,637.185415341,-368.948595304 ]
            [ 59.044140992,640.428366419,-368.53406841 ]
            [ 60.1373737247,643.627000601,-368.119463008 ]
            [ 61.2424556088,646.781291818,-367.70481602 ]
            [ 62.359328108,649.891212648,-367.29016404 ]
            [ 63.4879310597,652.956734158,-366.875543398 ]
            [ 64.6282024504,655.977825754,-366.460990236 ]
            [ 65.7800781745,658.954455038,-366.046540577 ]
            [ 66.943491774,661.886587666,-365.632230406 ]
            [ 68.1183741567,664.774187216,-365.218095745 ]
            [ 69.3046532928,667.617215061,-364.804172734 ]
            [ 70.5022538866,670.415630252,-364.390497715 ]
            [ 71.7110970225,673.169389402,-363.977107319 ]
            [ 72.9310997813,675.878446594,-363.56403856 ]
            [ 74.1621748278,678.542753288,-363.151328926 ]
            [ 75.4042299641,681.162258248,-362.739016478 ]
            [ 76.6571676492,683.736907492,-362.327139958 ]
            [ 77.9158316393,686.269732835,-361.916548361 ]
            [ 79.165962445,688.764971018,-361.509781022 ]
            [ 80.4071640501,691.223863404,-361.106829632 ]
            [ 81.6393816749,693.646594422,-360.707679159 ]
            [ 82.862559708,696.03335353,-360.312314438 ]
            [ 84.0766416458,698.384335252,-359.920720185 ]
            [ 85.2815700294,700.699739204,-359.532881022 ]
            [ 86.4772863814,702.979770125,-359.148781489 ]
            [ 87.6637311407,705.224637899,-358.768406071 ]
            [ 88.8408435973,707.434557579,-358.391739215 ]
            [ 90.0085618245,709.609749404,-358.018765354 ]
            [ 91.1668226117,711.750438814,-357.649468928 ]
            [ 92.315561395,713.856856464,-357.283834408 ]
            [ 93.4547121878,715.929238231,-356.92184632 ]
            [ 94.5842075104,717.967825227,-356.563489268 ]
            [ 95.704710473,719.97449825,-356.208513988 ]
            [ 96.8156183026,721.948291988,-355.857077172 ]
            [ 97.9166969062,723.889097232,-355.509215784 ]
            [ 99.007873702,725.797177266,-355.164914612 ]
            [ 100.089074281,727.67280055,-354.824158651 ]
            [ 101.160222335,729.516240712,-354.48693313 ]
            [ 102.221239584,731.327776536,-354.153223538 ]
            [ 103.272045705,733.107691956,-353.823015654 ]
            [ 104.312558264,734.85627604,-353.496295573 ]
            [ 105.342692644,736.573822976,-353.173049736 ]
            [ 106.362361977,738.260632062,-352.853264959 ]
            [ 107.379005236,739.918102765,-352.537437472 ]
            [ 108.401315356,741.550106862,-352.225688103 ]
            [ 109.428252019,743.1549093,-351.918310682 ]
            [ 110.459553575,744.732416943,-351.61535512 ]
            [ 111.495144008,746.282942625,-351.316811552 ]
            [ 112.534938312,747.806808896,-351.022670217 ]
            [ 113.578842347,749.304347852,-350.732921485 ]
            [ 114.626752694,750.775900969,-350.447555868 ]
            [ 115.678556517,752.221818935,-350.166564036 ]
            [ 116.735430742,753.644896424,-349.88954869 ]
            [ 117.796616768,755.044268974,-349.616691196 ]
            [ 118.861372,756.419173608,-349.348162992 ]
            [ 119.929546362,757.769995678,-349.083955171 ]
            [ 121.000979707,759.097128758,-348.824059063 ]
            [ 122.075501716,760.400974468,-348.568466239 ]
            [ 123.153749013,761.683385986,-348.316929 ]
            [ 124.236300862,762.946084121,-348.069216596 ]
            [ 125.321450557,764.186803705,-347.825764055 ]
            [ 126.408987685,765.405975566,-347.586563653 ]
            [ 127.49869122,766.604037557,-347.351607928 ]
            [ 128.590661778,767.781992269,-347.120793744 ]
            [ 129.686797425,768.943830469,-346.893498925 ]
            [ 130.784461815,770.085963626,-346.670406883 ]
            [ 131.883392248,771.208854034,-346.451510904 ]
            [ 132.983315273,772.312970015,-346.236804481 ]
            [ 134.085942124,773.401965773,-346.025713515 ]
            [ 135.190228113,774.475038834,-345.818449326 ]
            [ 136.294717018,775.530817844,-345.615334336 ]
            [ 137.399093325,776.569790851,-345.416362553 ]
            [ 138.505390589,777.596055866,-345.220863925 ]
            [ 139.612159436,778.608314405,-345.029150216 ]
            [ 140.71790399,779.605291674,-344.84153991 ]
            [ 141.82267643,780.588097058,-344.657912883 ]
            [ 142.929177459,781.561711478,-344.477409405 ]
            [ 144.033652167,782.521591809,-344.300969279 ]
            [ 145.135713506,783.468250648,-344.128586383 ]
            [ 146.238541675,784.40727749,-343.959265099 ]
            [ 147.33884788,785.33498546,-343.793801139 ]
            [ 148.435620751,786.251040058,-343.63235279 ]
            [ 149.532259091,787.161217525,-343.473862588 ]
            [ 150.625241206,788.0616781,-343.319176151 ]
            [ 151.713773504,788.952446064,-343.168382539 ]
            [ 152.80158058,789.839595618,-343.020334131 ]
            [ 153.883832689,790.717709627,-342.876219449 ]
            [ 154.962247378,791.590164573,-342.735434803 ]
            [ 156.037015627,792.45825993,-342.59779246 ]
            [ 157.10489131,793.318880631,-342.464033507 ]
            [ 158.170428381,794.178932985,-342.332782936 ]
            [ 159.228354888,795.032771415,-342.205322852 ]
            [ 160.283072465,795.878528461,-342.080909354 ]
            [ 161.334784504,796.7087547,-341.959980632 ]
            [ 162.383240292,797.523792995,-341.842530346 ]
            [ 163.429617645,798.325702155,-341.72816989 ]
            [ 164.471484991,799.11217015,-341.617478285 ]
            [ 165.51174087,799.887273208,-341.509608402 ]
            [ 166.546694997,800.647239468,-341.405474367 ]
            [ 167.580053738,801.397011637,-341.304016883 ]
            [ 168.607772302,802.132464437,-341.206242353 ]
            [ 169.633471388,802.858343378,-341.111118022 ]
            [ 170.653635065,803.571190516,-341.019507618 ]
            [ 171.670927287,804.274574802,-340.930635505 ]
            [ 172.683220362,804.9666436,-340.844996187 ]
            [ 173.69137609,805.648891439,-340.762293027 ]
            [ 174.695487065,806.321928919,-340.682433761 ]
            [ 175.693796627,806.984357116,-340.605813314 ]
            [ 176.689418828,807.64003035,-340.531544757 ]
            [ 177.678313217,808.285098016,-340.460623602 ]
            [ 178.664027165,808.923810118,-340.39205134 ]
            [ 179.644102926,809.554022333,-340.326406918 ]
            [ 180.618354588,810.176008864,-340.263672482 ]
            [ 181.589317035,810.792826031,-340.203119364 ]
            [ 182.553538662,811.401343371,-340.145584988 ]
            [ 183.513039041,812.004051528,-340.090476535 ]
            [ 184.467829988,812.601352862,-340.037726835 ]
            [ 185.415890005,813.191613912,-339.987798407 ]
            [ 186.359471088,813.777468719,-339.94004073 ]
            [ 187.297790387,814.358497557,-339.894594403 ]
            [ 188.229383624,814.933626928,-339.851776576 ]
            [ 189.155940866,815.504861772,-339.811085183 ]
            [ 190.077491989,816.072554694,-339.772450306 ]
            [ 190.992317551,816.635376217,-339.736255481 ]
            [ 191.90081441,817.194035298,-339.702335481 ]
            [ 192.805306345,817.751035166,-339.670027393 ]
            [ 193.703069474,818.304084579,-339.639974932 ]
            [ 194.594130035,818.853505012,-339.612109883 ]
            [ 195.479690798,819.400694496,-339.586060746 ]
            [ 196.360104664,819.946231572,-339.561676398 ]
            [ 197.233806458,820.488921781,-339.539300707 ]
            [ 198.10081762,821.029036294,-339.518868135 ]
            [ 198.961983488,821.567580547,-339.500101388 ]
            [ 199.818047053,822.105440845,-339.482750361 ]
            [ 200.667405451,822.641378362,-339.467169038 ]
            [ 201.51007586,823.175617795,-339.453294418 ]
            [ 202.346073993,823.708371875,-339.441064255 ]
            [ 203.176962923,824.241208683,-339.430019323 ]
            [ 204.001693277,824.773365392,-339.42037209 ]
            [ 204.819730771,825.304537751,-339.412202719 ]
            [ 205.631087554,825.83489621,-339.405451371 ]
            [ 206.435774519,826.364600366,-339.400058925 ]
            [ 207.234645057,826.894527418,-339.395750791 ]
            [ 208.027762818,827.424854239,-339.392455405 ]
            [ 208.814186271,827.954887654,-339.390358961 ]
            [ 209.593923453,828.484748396,-339.389404668 ]
            [ 210.366981349,829.014547233,-339.389536428 ]
            [ 211.13336594,829.544385137,-339.390698829 ]
            [ 211.893541442,830.074740611,-339.392719748 ]
            [ 212.648047333,830.60614113,-339.395408428 ]
            [ 213.395852529,831.137784688,-339.398975978 ]
            [ 214.136961012,831.669736633,-339.403369258 ]
            [ 214.871375956,832.202053178,-339.4085358 ]
            [ 215.599099774,832.734781518,-339.414423798 ]
            [ 216.320134152,833.267959954,-339.420982112 ]
            [ 217.034480094,833.801617995,-339.428160257 ]
            [ 217.743259152,834.336697026,-339.43562247 ]
            [ 218.44539496,834.872320111,-339.443594163 ]
            [ 219.140814266,835.408431726,-339.452045266 ]
            [ 219.829517124,835.9450287,-339.460927517 ]
            [ 220.511503073,836.48209946,-339.470193294 ]
            [ 221.186771156,837.019624094,-339.47979562 ]
            [ 221.855319956,837.557574414,-339.489688151 ]
            [ 222.517147623,838.095914015,-339.499825178 ]
            [ 223.172279922,838.634620822,-339.510154484 ]
            [ 223.821631863,839.174376772,-339.520398102 ]
            [ 224.464238348,839.714346853,-339.530757113 ]
            [ 225.100097251,840.254463398,-339.541187971 ]
            [ 225.199480248,840.33353993,-339.51591203 ]
            [ 225.297501499,840.41133953,-339.490987641 ]
        ]

        @cameraTgtData = [
            [ -1183.88317871,-90.3306732178,-231.568664551 ]
            [ -1183.41503906,-90.2536392212,-231.469619751 ]
            [ -1182.01330566,-90.0230712891,-231.173202515 ]
            [ -1180.61560059,-89.7933044434,-230.877853394 ]
            [ -1179.22180176,-89.5643310547,-230.583557129 ]
            [ -1177.83154297,-89.3361053467,-230.290237427 ]
            [ -1176.43432617,-89.1068496704,-229.995620728 ]
            [ -1175.04089355,-88.8783874512,-229.702056885 ]
            [ -1173.65136719,-88.6507034302,-229.40953064 ]
            [ -1172.265625,-88.4237976074,-229.118026733 ]
            [ -1170.87536621,-88.1962890625,-228.825775146 ]
            [ -1169.48596191,-87.9690704346,-228.533935547 ]
            [ -1168.1003418,-87.7426223755,-228.243118286 ]
            [ -1166.71838379,-87.5169372559,-227.953292847 ]
            [ -1165.33496094,-87.2911300659,-227.663375854 ]
            [ -1163.94909668,-87.0651092529,-227.373184204 ]
            [ -1162.56713867,-86.8398361206,-227.084014893 ]
            [ -1161.1887207,-86.6153106689,-226.795822144 ]
            [ -1159.81140137,-86.3911132813,-226.508102417 ]
            [ -1158.42895508,-86.166229248,-226.219512939 ]
            [ -1157.0501709,-85.9420852661,-225.931930542 ]
            [ -1155.67492676,-85.7186737061,-225.645309448 ]
            [ -1154.30322266,-85.4959869385,-225.359649658 ]
            [ -1152.92382813,-85.2722015381,-225.072631836 ]
            [ -1151.54785156,-85.0491333008,-224.786560059 ]
            [ -1150.17541504,-84.8267745972,-224.501449585 ]
            [ -1148.80651855,-84.605140686,-224.217285156 ]
            [ -1147.43212891,-84.3827667236,-223.932235718 ]
            [ -1146.05871582,-84.1607208252,-223.647628784 ]
            [ -1144.68884277,-83.9393768311,-223.363967896 ]
            [ -1143.32226563,-83.7187347412,-223.081237793 ]
            [ -1141.95227051,-83.4976806641,-222.798034668 ]
            [ -1140.58117676,-83.2766113281,-222.514846802 ]
            [ -1139.21350098,-83.0562286377,-222.232589722 ]
            [ -1137.84899902,-82.8365402222,-221.951248169 ]
            [ -1136.48278809,-82.6167068481,-221.669784546 ]
            [ -1135.11364746,-82.3965606689,-221.387954712 ]
            [ -1133.74780273,-82.1770935059,-221.107025146 ]
            [ -1132.38525391,-81.9583053589,-220.827026367 ]
            [ -1131.0222168,-81.7396011353,-220.547180176 ]
            [ -1129.65466309,-81.5203323364,-220.266647339 ]
            [ -1128.29040527,-81.3017349243,-219.987030029 ]
            [ -1126.92919922,-81.0838012695,-219.708312988 ]
            [ -1125.56872559,-80.8661270142,-219.429962158 ]
            [ -1124.20263672,-80.6476974487,-219.15071106 ]
            [ -1122.83947754,-80.4299240112,-218.872329712 ]
            [ -1121.47961426,-80.2127990723,-218.594833374 ]
            [ -1120.12109375,-79.996055603,-218.317886353 ]
            [ -1118.75585938,-79.7784118652,-218.039840698 ]
            [ -1117.39379883,-79.561416626,-217.762664795 ]
            [ -1116.03466797,-79.3450622559,-217.486358643 ]
            [ -1114.67749023,-79.12915802,-217.210693359 ]
            [ -1113.31298828,-78.9122619629,-216.933822632 ]
            [ -1111.95153809,-78.6960067749,-216.657806396 ]
            [ -1110.59301758,-78.4803695679,-216.382644653 ]
            [ -1109.2364502,-78.2652053833,-216.108139038 ]
            [ -1107.87243652,-78.0490188599,-215.832382202 ]
            [ -1106.51135254,-77.8334579468,-215.557479858 ]
            [ -1105.15307617,-77.6185073853,-215.283432007 ]
            [ -1103.79650879,-77.4039840698,-215.009979248 ]
            [ -1102.43273926,-77.1884689331,-214.735305786 ]
            [ -1101.07165527,-76.9735565186,-214.461486816 ]
            [ -1099.71337891,-76.7592544556,-214.188491821 ]
            [ -1098.35620117,-76.5452804565,-213.915985107 ]
            [ -1096.9921875,-76.3303833008,-213.642364502 ]
            [ -1095.63085938,-76.1160964966,-213.36958313 ]
            [ -1094.27233887,-75.9023971558,-213.097625732 ]
            [ -1092.91394043,-75.688873291,-212.825942993 ]
            [ -1091.54943848,-75.474571228,-212.553344727 ]
            [ -1090.18762207,-75.2608566284,-212.281555176 ]
            [ -1088.82861328,-75.0477371216,-212.010604858 ]
            [ -1087.46813965,-74.8345565796,-211.739639282 ]
            [ -1086.10290527,-74.6208114624,-211.468017578 ]
            [ -1084.74035645,-74.4076461792,-211.197219849 ]
            [ -1083.38049316,-74.19506073,-210.927215576 ]
            [ -1082.01733398,-73.982131958,-210.65687561 ]
            [ -1080.65112305,-73.7689056396,-210.38621521 ]
            [ -1079.28759766,-73.5562591553,-210.116363525 ]
            [ -1077.92663574,-73.3441772461,-209.847305298 ]
            [ -1076.56018066,-73.1314086914,-209.577453613 ]
            [ -1075.19274902,-72.9186706543,-209.307723999 ]
            [ -1073.82788086,-72.7065048218,-209.038787842 ]
            [ -1072.46557617,-72.4948883057,-208.770645142 ]
            [ -1071.09509277,-72.2821884155,-208.501205444 ]
            [ -1069.72619629,-72.0699081421,-208.232391357 ]
            [ -1068.35974121,-71.8581924438,-207.964355469 ]
            [ -1066.99365234,-71.646697998,-207.69670105 ]
            [ -1065.62060547,-71.4342880249,-207.427978516 ]
            [ -1064.25,-71.222442627,-207.16003418 ]
            [ -1062.88171387,-71.011138916,-206.892883301 ]
            [ -1061.51037598,-70.7995300293,-206.625427246 ]
            [ -1060.13537598,-70.5875320435,-206.357574463 ]
            [ -1058.76281738,-70.376083374,-206.090515137 ]
            [ -1057.39257813,-70.165184021,-205.824234009 ]
            [ -1056.01513672,-69.9533538818,-205.556884766 ]
            [ -1054.63793945,-69.7417449951,-205.289901733 ]
            [ -1053.26318359,-69.5306777954,-205.023696899 ]
            [ -1051.88842773,-69.3198013306,-204.757827759 ]
            [ -1050.50646973,-69.1080093384,-204.490921021 ]
            [ -1049.12695313,-68.8967590332,-204.22479248 ]
            [ -1047.74975586,-68.6860427856,-203.959442139 ]
            [ -1046.36767578,-68.4747772217,-203.693496704 ]
            [ -1044.9831543,-68.2633361816,-203.427429199 ]
            [ -1043.60107422,-68.0524215698,-203.162155151 ]
            [ -1042.22045898,-67.8419342041,-202.897521973 ]
            [ -1040.83105469,-67.6302871704,-202.631530762 ]
            [ -1039.44384766,-67.4191665649,-202.366317749 ]
            [ -1038.05883789,-67.2085723877,-202.101882935 ]
            [ -1036.66967773,-66.9975280762,-201.836990356 ]
            [ -1035.27722168,-66.7861862183,-201.571853638 ]
            [ -1033.88708496,-66.5753707886,-201.307495117 ]
            [ -1032.49816895,-66.364944458,-201.043746948 ]
            [ -1031.10046387,-66.1533737183,-200.778686523 ]
            [ -1029.70495605,-65.9423294067,-200.514404297 ]
            [ -1028.31164551,-65.731803894,-200.250900269 ]
            [ -1026.91271973,-65.5206375122,-199.986709595 ]
            [ -1025.51184082,-65.3093566895,-199.722518921 ]
            [ -1024.11303711,-65.0985946655,-199.459091187 ]
            [ -1022.71325684,-64.8878860474,-199.195892334 ]
            [ -1021.3067627,-64.6763534546,-198.931777954 ]
            [ -1019.90234375,-64.4653396606,-198.668457031 ]
            [ -1018.50006104,-64.2548446655,-198.405929565 ]
            [ -1017.08898926,-64.0432357788,-198.14213562 ]
            [ -1015.67889404,-63.8319664001,-197.878921509 ]
            [ -1014.27087402,-63.6212120056,-197.616500854 ]
            [ -1012.85778809,-63.4099082947,-197.353530884 ]
            [ -1011.4418335,-63.1983795166,-197.090438843 ]
            [ -1010.02801514,-62.9873657227,-196.828140259 ]
            [ -1008.61236572,-62.7762908936,-196.56590271 ]
            [ -1007.19049072,-62.5644950867,-196.302947998 ]
            [ -1005.77075195,-62.3532180786,-196.040786743 ]
            [ -1004.35198975,-62.1422996521,-195.77923584 ]
            [ -1002.92407227,-61.9302368164,-195.516433716 ]
            [ -1001.49829102,-61.7186927795,-195.254425049 ]
            [ -1000.07452393,-61.5076637268,-194.993240356 ]
            [ -998.641845703,-61.2955245972,-194.73085022 ]
            [ -997.209899902,-61.0837097168,-194.469024658 ]
            [ -995.780029297,-60.8724098206,-194.208023071 ]
            [ -994.343078613,-60.660282135,-193.946182251 ]
            [ -992.904907227,-60.4481964111,-193.684570313 ]
            [ -991.468811035,-60.2366294861,-193.423782349 ]
            [ -990.026977539,-60.0244369507,-193.162414551 ]
            [ -988.582519531,-59.8120803833,-192.901031494 ]
            [ -987.140136719,-59.6002464294,-192.640487671 ]
            [ -985.692932129,-59.3879241943,-192.37953186 ]
            [ -984.242126465,-59.1753005981,-192.118423462 ]
            [ -982.793395996,-58.9631996155,-191.858139038 ]
            [ -981.340270996,-58.7506790161,-191.597564697 ]
            [ -979.882995605,-58.5377883911,-191.336746216 ]
            [ -978.427856445,-58.3254203796,-191.076766968 ]
            [ -976.968200684,-58.1126365662,-190.816513062 ]
            [ -975.504516602,-57.8994865417,-190.556015015 ]
            [ -974.04284668,-57.6868591309,-190.296386719 ]
            [ -972.576171875,-57.4737434387,-190.036392212 ]
            [ -971.105957031,-57.2603378296,-189.776260376 ]
            [ -969.637756348,-57.0474586487,-189.51701355 ]
            [ -968.163513184,-56.833946228,-189.257247925 ]
            [ -966.686706543,-56.6202888489,-188.997528076 ]
            [ -965.211914063,-56.4071655273,-188.738708496 ]
            [ -963.729675293,-56.193195343,-188.479125977 ]
            [ -962.24621582,-55.9792938232,-188.219863892 ]
            [ -960.764831543,-55.7659339905,-187.961517334 ]
            [ -959.273925781,-55.5514411926,-187.702072144 ]
            [ -957.783813477,-55.337310791,-187.443328857 ]
            [ -956.294677734,-55.1235542297,-187.185302734 ]
            [ -954.795776367,-54.9086532593,-186.926177979 ]
            [ -953.299072266,-54.6942977905,-186.667999268 ]
            [ -951.800231934,-54.4799003601,-186.410049438 ]
            [ -950.29473877,-54.2647857666,-186.151519775 ]
            [ -948.791259766,-54.0502204895,-185.893951416 ]
            [ -947.282409668,-53.8351249695,-185.636047363 ]
            [ -945.770141602,-53.619808197,-185.378173828 ]
            [ -944.260070801,-53.4050483704,-185.121292114 ]
            [ -942.740539551,-53.189201355,-184.863418579 ]
            [ -941.221618652,-52.9736976624,-184.606277466 ]
            [ -939.702026367,-52.7583503723,-184.349655151 ]
            [ -938.174255371,-52.5421028137,-184.092285156 ]
            [ -936.648620605,-52.326423645,-183.8359375 ]
            [ -935.117492676,-52.1102180481,-183.579299927 ]
            [ -933.583007813,-51.8938102722,-183.322769165 ]
            [ -932.05078125,-51.6779747009,-183.067276001 ]
            [ -930.507568359,-51.4608573914,-182.810638428 ]
            [ -928.966491699,-51.244304657,-182.555023193 ]
            [ -927.421875,-51.0275192261,-182.299514771 ]
            [ -925.871948242,-50.810256958,-182.043823242 ]
            [ -924.324279785,-50.5935745239,-181.789215088 ]
            [ -922.766723633,-50.3757820129,-181.533691406 ]
            [ -921.210205078,-50.158405304,-181.279052734 ]
            [ -919.650390625,-49.9408416748,-181.024612427 ]
            [ -918.085021973,-49.7227706909,-180.769989014 ]
            [ -916.521972656,-49.5052986145,-180.516494751 ]
            [ -914.948425293,-49.2866363525,-180.262039185 ]
            [ -913.376525879,-49.06848526,-180.008636475 ]
            [ -911.799926758,-48.8499526978,-179.755218506 ]
            [ -910.219238281,-48.6311340332,-179.501937866 ]
            [ -908.639221191,-48.4126815796,-179.249542236 ]
            [ -907.049743652,-48.1932029724,-178.996429443 ]
            [ -905.46270752,-47.9743461609,-178.744522095 ]
            [ -903.867614746,-47.7546577454,-178.492141724 ]
            [ -902.271850586,-47.53515625,-178.240493774 ]
            [ -900.672546387,-47.3154525757,-177.989105225 ]
            [ -899.068054199,-47.0953178406,-177.737747192 ]
            [ -897.464172363,-46.8755607605,-177.487350464 ]
            [ -895.850952148,-46.654800415,-177.236343384 ]
            [ -894.240356445,-46.4346809387,-176.986633301 ]
            [ -892.620300293,-46.2135658264,-176.736328125 ]
            [ -891.001037598,-45.9928436279,-176.487045288 ]
            [ -889.375671387,-45.7715835571,-176.237731934 ]
            [ -887.747802734,-45.5502662659,-175.988952637 ]
            [ -886.116882324,-45.3288154602,-175.740631104 ]
            [ -884.48046875,-45.1069145203,-175.492401123 ]
            [ -882.843505859,-44.8852348328,-175.245056152 ]
            [ -881.198547363,-44.6627616882,-174.997467041 ]
            [ -879.555358887,-44.4408111572,-174.751098633 ]
            [ -877.901916504,-44.2177772522,-174.504196167 ]
            [ -876.251403809,-43.9954223633,-174.258712769 ]
            [ -874.590270996,-43.7719306946,-174.012664795 ]
            [ -872.931396484,-43.5490341187,-173.767974854 ]
            [ -871.263244629,-43.3251914978,-173.522964478 ]
            [ -869.596069336,-43.101764679,-173.279144287 ]
            [ -867.920715332,-42.877532959,-173.035186768 ]
            [ -866.245361328,-42.653591156,-172.792297363 ]
            [ -864.56237793,-42.4289283752,-172.5493927 ]
            [ -862.87890625,-42.2044868469,-172.307525635 ]
            [ -861.188049316,-41.9793548584,-172.065704346 ]
            [ -859.496520996,-41.7544212341,-171.824935913 ]
            [ -857.797546387,-41.5287857056,-171.584228516 ]
            [ -856.098083496,-41.3033714294,-171.344619751 ]
            [ -854.390625,-41.0771942139,-171.105072021 ]
            [ -852.683288574,-40.85131073,-170.866714478 ]
            [ -850.967163086,-40.6245536804,-170.628356934 ]
            [ -849.25201416,-40.3982162476,-170.391342163 ]
            [ -847.526977539,-40.1708450317,-170.154190063 ]
            [ -845.803710938,-39.9439964294,-169.918548584 ]
            [ -844.069885254,-39.7160377502,-169.682723999 ]
            [ -842.337097168,-39.488494873,-169.44833374 ]
            [ -840.595825195,-39.2601089478,-169.214080811 ]
            [ -838.85333252,-39.0318412781,-168.981002808 ]
            [ -837.104614258,-38.8030357361,-168.748428345 ]
            [ -835.352172852,-38.5740089417,-168.516708374 ]
            [ -833.596252441,-38.3447914124,-168.285888672 ]
            [ -831.833618164,-38.1149673462,-168.055603027 ]
            [ -830.070617676,-37.885345459,-167.826644897 ]
            [ -828.297607422,-37.6546897888,-167.597839355 ]
            [ -826.524841309,-37.4243164063,-167.370513916 ]
            [ -824.74407959,-37.1931533813,-167.143615723 ]
            [ -822.960510254,-36.9618759155,-166.91784668 ]
            [ -821.172973633,-36.7303237915,-166.693084717 ]
            [ -819.378479004,-36.4981040955,-166.468963623 ]
            [ -817.583374023,-36.2660484314,-166.246322632 ]
            [ -815.778686523,-36.0329742432,-166.024047852 ]
            [ -813.972290039,-35.7999038696,-165.803146362 ]
            [ -812.161193848,-35.566444397,-165.583282471 ]
            [ -810.343261719,-35.3323249817,-165.364227295 ]
            [ -808.524169922,-35.0982513428,-165.14666748 ]
            [ -806.696533203,-34.8632698059,-164.929748535 ]
            [ -804.865600586,-34.6280708313,-164.714141846 ]
            [ -803.031982422,-34.3927001953,-164.499938965 ]
            [ -801.189208984,-34.1563339233,-164.286392212 ]
            [ -799.344543457,-33.9198951721,-164.074401855 ]
            [ -797.494995117,-33.6829872131,-163.863632202 ]
            [ -795.638183594,-33.4453010559,-163.653839111 ]
            [ -793.77911377,-33.2074661255,-163.445617676 ]
            [ -791.914123535,-32.96900177,-163.238571167 ]
            [ -790.042663574,-32.7298316956,-163.032714844 ]
            [ -788.168640137,-32.490436554,-162.828460693 ]
            [ -786.288574219,-32.250377655,-162.625473022 ]
            [ -784.401977539,-32.0095596313,-162.423736572 ]
            [ -782.512390137,-31.7684345245,-162.223648071 ]
            [ -780.617797852,-31.5267333984,-162.025039673 ]
            [ -778.715515137,-31.2840900421,-161.827636719 ]
            [ -776.809936523,-31.0410556793,-161.631942749 ]
            [ -774.900817871,-30.7975940704,-161.437973022 ]
            [ -772.982849121,-30.5529918671,-161.245193481 ]
            [ -771.060913086,-30.3078632355,-161.054138184 ]
            [ -769.135131836,-30.0622158051,-160.864868164 ]
            [ -767.203796387,-29.8157997131,-160.677215576 ]
            [ -765.265075684,-29.5683708191,-160.491043091 ]
            [ -763.322387695,-29.3203372955,-160.306732178 ]
            [ -761.375549316,-29.0716571808,-160.124267578 ]
            [ -759.422485352,-28.8220481873,-159.943496704 ]
            [ -757.462585449,-28.5714054108,-159.764404297 ]
            [ -755.498291016,-28.3200206757,-159.587234497 ]
            [ -753.529541016,-28.0678501129,-159.412017822 ]
            [ -751.555786133,-27.8148040771,-159.238723755 ]
            [ -749.573974609,-27.5604667664,-159.067138672 ]
            [ -747.587463379,-27.3052387238,-158.897567749 ]
            [ -745.596191406,-27.049079895,-158.730056763 ]
            [ -743.600036621,-26.7919387817,-158.564590454 ]
            [ -741.598449707,-26.5337181091,-158.401168823 ]
            [ -739.589233398,-26.2741088867,-158.239654541 ]
            [ -737.575073242,-26.0134029388,-158.080291748 ]
            [ -735.555725098,-25.7515525818,-157.923080444 ]
            [ -733.53125,-25.4885082245,-157.768035889 ]
            [ -731.501403809,-25.2242202759,-157.615203857 ]
            [ -729.466003418,-24.9586048126,-157.464569092 ]
            [ -727.423339844,-24.69140625,-157.316055298 ]
            [ -725.375366211,-24.422826767,-157.169799805 ]
            [ -723.321899414,-24.1528129578,-157.025848389 ]
            [ -721.263000488,-23.8813076019,-156.88420105 ]
            [ -719.198547363,-23.6082553864,-156.744873047 ]
            [ -717.128479004,-23.3335971832,-156.607894897 ]
            [ -715.052734375,-23.0572738647,-156.47328186 ]
            [ -712.971313477,-22.7792243958,-156.341033936 ]
            [ -710.883666992,-22.4993305206,-156.211151123 ]
            [ -708.789794922,-22.2175197601,-156.083648682 ]
            [ -706.690185547,-21.9338092804,-155.958557129 ]
            [ -704.584838867,-21.6481361389,-155.835906982 ]
            [ -702.473754883,-21.3604297638,-155.715682983 ]
            [ -700.356872559,-21.0706233978,-155.597915649 ]
            [ -698.234191895,-20.7786445618,-155.48260498 ]
            [ -696.105651855,-20.4844226837,-155.369735718 ]
            [ -693.971252441,-20.1878852844,-155.25932312 ]
            [ -691.830932617,-19.8889560699,-155.151367188 ]
            [ -689.684814453,-19.5875587463,-155.045852661 ]
            [ -687.532714844,-19.2836170197,-154.942779541 ]
            [ -685.374755859,-18.9770507813,-154.842147827 ]
            [ -683.21081543,-18.6677799225,-154.743927002 ]
            [ -681.041015625,-18.35572052,-154.648117065 ]
            [ -678.865234375,-18.0407905579,-154.554702759 ]
            [ -676.683532715,-17.7229061127,-154.463653564 ]
            [ -674.495910645,-17.4019813538,-154.374938965 ]
            [ -672.302368164,-17.0779247284,-154.288543701 ]
            [ -670.102905273,-16.7506523132,-154.204437256 ]
            [ -667.897460938,-16.4200706482,-154.122589111 ]
            [ -665.686096191,-16.0860900879,-154.042953491 ]
            [ -663.46875,-15.7486200333,-153.965484619 ]
            [ -661.245483398,-15.4075641632,-153.890151978 ]
            [ -659.016235352,-15.0628204346,-153.816894531 ]
            [ -656.780700684,-14.714261055,-153.745651245 ]
            [ -654.538818359,-14.3639574051,-153.676376343 ]
            [ -652.290466309,-14.0133771896,-153.609085083 ]
            [ -650.035583496,-13.6625127792,-153.543777466 ]
            [ -647.774108887,-13.3113546371,-153.480453491 ]
            [ -645.506103516,-12.9598922729,-153.419128418 ]
            [ -643.231567383,-12.6081161499,-153.359832764 ]
            [ -640.950378418,-12.2560148239,-153.302536011 ]
            [ -638.662658691,-11.9035768509,-153.247283936 ]
            [ -636.367675781,-11.5506916046,-153.194061279 ]
            [ -634.066040039,-11.1974382401,-153.142883301 ]
            [ -631.757751465,-10.8438091278,-153.09375 ]
            [ -629.442810059,-10.4897909164,-153.046691895 ]
            [ -627.12121582,-10.1353693008,-153.001693726 ]
            [ -624.79296875,-9.78053092957,-152.958786011 ]
            [ -622.457580566,-9.42517948151,-152.917938232 ]
            [ -620.115112305,-9.06933116913,-152.879165649 ]
            [ -617.765991211,-8.71301555634,-152.842483521 ]
            [ -615.41015625,-8.35621547699,-152.807907104 ]
            [ -613.047607422,-7.99891281128,-152.775405884 ]
            [ -610.677856445,-7.6410150528,-152.745010376 ]
            [ -608.30090332,-7.28250837326,-152.716705322 ]
            [ -605.917236328,-6.92343902588,-152.690505981 ]
            [ -603.526855469,-6.56378746033,-152.666397095 ]
            [ -601.129516602,-6.20350885391,-152.644378662 ]
            [ -598.72454834,-5.8424706459,-152.624465942 ]
            [ -596.312805176,-5.48078012466,-152.606628418 ]
            [ -593.894348145,-5.11841344833,-152.590896606 ]
            [ -591.46875,-4.75530433655,-152.57723999 ]
            [ -589.035644531,-4.39134502411,-152.565658569 ]
            [ -586.59564209,-4.02662944794,-152.556152344 ]
            [ -584.148925781,-3.66112995148,-152.548706055 ]
            [ -581.694580078,-3.29469490051,-152.543319702 ]
            [ -579.233032227,-2.92736816406,-152.539978027 ]
            [ -576.764709473,-2.55916571617,-152.53868103 ]
            [ -574.2890625,-2.1899740696,-152.539398193 ]
            [ -571.805908203,-1.81974720955,-152.542114258 ]
            [ -569.315917969,-1.44854414463,-152.546844482 ]
            [ -566.818603516,-1.07625067234,-152.553543091 ]
            [ -564.313720703,-0.702806949615,-152.562225342 ]
            [ -561.802001953,-0.328276157379,-152.5728302 ]
            [ -559.282714844,0.0474897809327,-152.585372925 ]
            [ -556.75604248,0.42449721694,-152.599822998 ]
            [ -554.22253418,0.802713632584,-152.616149902 ]
            [ -551.680969238,1.18235015869,-152.634338379 ]
            [ -549.132507324,1.5633007288,-152.654373169 ]
            [ -546.576660156,1.94565927982,-152.676193237 ]
            [ -544.013122559,2.32952880859,-152.699813843 ]
            [ -541.442687988,2.71483612061,-152.72517395 ]
            [ -538.864196777,3.10180282593,-152.752258301 ]
            [ -536.278747559,3.49032497406,-152.781021118 ]
            [ -533.68560791,3.88054728508,-152.811431885 ]
            [ -531.085021973,4.27249574661,-152.843460083 ]
            [ -528.477111816,4.66620731354,-152.877059937 ]
            [ -525.861450195,5.06180381775,-152.912200928 ]
            [ -523.238647461,5.45924758911,-152.948822021 ]
            [ -520.607849121,5.85872650146,-152.986907959 ]
            [ -517.969970703,6.26015663147,-153.026382446 ]
            [ -515.324035645,6.66376256943,-153.067230225 ]
            [ -512.671020508,7.06944274902,-153.109359741 ]
            [ -510.009918213,7.47743368149,-153.152755737 ]
            [ -507.341705322,7.88763856888,-153.197341919 ]
            [ -504.665405273,8.30028438568,-153.243087769 ]
            [ -501.981903076,8.71529865265,-153.289901733 ]
            [ -499.290374756,9.13288116455,-153.337753296 ]
            [ -496.591491699,9.55300331116,-153.386566162 ]
            [ -493.884735107,9.97581672668,-153.436279297 ]
            [ -491.170410156,10.4013538361,-153.486816406 ]
            [ -488.448425293,10.829706192,-153.538116455 ]
            [ -485.718597412,11.2609777451,-153.590103149 ]
            [ -482.981323242,11.6951875687,-153.642715454 ]
            [ -480.235931396,12.132525444,-153.695877075 ]
            [ -477.483093262,12.5729675293,-153.74949646 ]
            [ -474.722381592,13.0166721344,-153.803497314 ]
            [ -471.953887939,13.4637012482,-153.857803345 ]
            [ -469.177825928,13.9141168594,-153.912338257 ]
            [ -466.393676758,14.3680906296,-153.966995239 ]
            [ -463.601928711,14.8256311417,-154.021697998 ]
            [ -460.802398682,15.2868690491,-154.076339722 ]
            [ -457.994903564,15.7519159317,-154.130844116 ]
            [ -455.179779053,16.220823288,-154.185119629 ]
            [ -452.356719971,16.693731308,-154.239044189 ]
            [ -449.525817871,17.1707286835,-154.292526245 ]
            [ -446.687194824,17.6518878937,-154.345474243 ]
            [ -443.840637207,18.1373519897,-154.397781372 ]
            [ -440.986206055,18.6272068024,-154.449325562 ]
            [ -438.12399292,19.1215381622,-154.500015259 ]
            [ -435.25390625,19.6204719543,-154.549713135 ]
            [ -432.37588501,20.1241207123,-154.598342896 ]
            [ -429.490081787,20.6325683594,-154.645751953 ]
            [ -426.596435547,21.1459255219,-154.691848755 ]
            [ -423.694793701,21.6643295288,-154.736495972 ]
            [ -420.785339355,22.1878585815,-154.779586792 ]
            [ -417.757446289,22.7367515564,-154.822509766 ]
            [ -414.509155273,23.3302841187,-154.866256714 ]
            [ -411.052703857,23.9673137665,-154.91003418 ]
            [ -407.399169922,24.6469116211,-154.952972412 ]
            [ -403.558776855,25.3683547974,-154.994186401 ]
            [ -399.540893555,26.1310977936,-155.03276062 ]
            [ -395.354248047,26.9347515106,-155.067672729 ]
            [ -391.006774902,27.7790775299,-155.097915649 ]
            [ -386.506011963,28.6639518738,-155.122390747 ]
            [ -381.858886719,29.589548111,-155.139953613 ]
            [ -377.071807861,30.5555744171,-155.149642944 ]
            [ -372.150604248,31.5610466003,-155.150436401 ]
            [ -367.10067749,32.6048774719,-155.141357422 ]
            [ -361.927032471,33.6858634949,-155.121444702 ]
            [ -356.634368896,34.8027000427,-155.08972168 ]
            [ -351.226959229,35.9539642334,-155.045227051 ]
            [ -345.708740234,37.1381340027,-154.987014771 ]
            [ -340.08392334,38.3534545898,-154.914154053 ]
            [ -334.35559082,39.5982704163,-154.825775146 ]
            [ -328.526733398,40.8707923889,-154.720977783 ]
            [ -322.601409912,42.1688537598,-154.598953247 ]
            [ -316.581268311,43.4907073975,-154.458908081 ]
            [ -310.469940186,44.8340682983,-154.300094604 ]
            [ -304.269012451,46.1969871521,-154.121795654 ]
            [ -297.981842041,47.5770874023,-153.923400879 ]
            [ -291.609313965,48.9724464417,-153.70425415 ]
            [ -285.155212402,50.38048172,-153.463882446 ]
            [ -278.619781494,51.7993583679,-153.20173645 ]
            [ -272.006103516,53.2266044617,-152.917434692 ]
            [ -265.315368652,54.66015625,-152.610580444 ]
            [ -258.548828125,56.0979728699,-152.280822754 ]
            [ -251.709609985,57.5376205444,-151.928009033 ]
            [ -244.797363281,58.9774513245,-151.551803589 ]
            [ -237.814941406,60.4151916504,-151.152160645 ]
            [ -230.763259888,61.8490371704,-150.728942871 ]
            [ -223.643005371,63.2772750854,-150.282058716 ]
            [ -216.457382202,64.6977844238,-149.811630249 ]
            [ -209.205169678,66.1093673706,-149.3175354 ]
            [ -201.890319824,67.5099258423,-148.800033569 ]
            [ -194.511520386,68.8984451294,-148.259063721 ]
            [ -187.072067261,70.273109436,-147.694961548 ]
            [ -179.571212769,71.6329574585,-147.107757568 ]
            [ -172.012084961,72.9763946533,-146.497817993 ]
            [ -164.393356323,74.3027267456,-145.865203857 ]
            [ -156.719284058,75.6103286743,-145.210449219 ]
            [ -148.987625122,76.8988113403,-144.533554077 ]
            [ -141.201919556,78.1668701172,-143.83505249 ]
            [ -133.3621521,79.4138717651,-143.11517334 ]
            [ -125.468254089,80.6392440796,-142.374145508 ]
            [ -117.523727417,81.8419342041,-141.612564087 ]
            [ -109.528007507,83.0216064453,-140.830627441 ]
            [ -101.481445313,84.1778182983,-140.028640747 ]
            [ -93.3851318359,85.3100662231,-139.207000732 ]
            [ -85.2332763672,86.4156570435,-138.448898315 ]
            [ -77.0079956055,87.4876022339,-138.011199951 ]
            [ -68.7222137451,88.5251235962,-137.908050537 ]
            [ -60.390247345,89.5281143188,-138.133865356 ]
            [ -52.0256462097,90.496673584,-138.682403564 ]
            [ -43.6414604187,91.4309997559,-139.546875 ]
            [ -35.2487182617,92.3316040039,-140.720336914 ]
            [ -26.8582553864,93.1990127563,-142.195785522 ]
            [ -18.4801826477,94.0338439941,-143.966217041 ]
            [ -10.124540329,94.8367233276,-146.024658203 ]
            [ -1.79972410202,95.6084365845,-148.364654541 ]
            [ 6.48595476151,96.3497543335,-150.980026245 ]
            [ 14.7244024277,97.0614471436,-153.864944458 ]
            [ 22.9075317383,97.7442703247,-157.013900757 ]
            [ 31.0279521942,98.399017334,-160.421981812 ]
            [ 39.078250885,99.0264587402,-164.084777832 ]
            [ 47.0508346558,99.6273345947,-167.99822998 ]
            [ 54.9380226135,100.20236969,-172.158813477 ]
            [ 62.7320709229,100.75226593,-176.563476563 ]
            [ 70.4247512817,101.277694702,-181.209564209 ]
            [ 78.0076904297,101.779296875,-186.095046997 ]
            [ 85.4718399048,102.25769043,-191.218170166 ]
            [ 92.8071975708,102.713439941,-196.577377319 ]
            [ 100.004020691,103.147125244,-202.172180176 ]
            [ 107.050384521,103.559242249,-208.001434326 ]
            [ 113.934173584,103.950286865,-214.064926147 ]
            [ 120.641975403,104.320732117,-220.362518311 ]
            [ 127.15851593,104.670982361,-226.893661499 ]
            [ 133.467605591,105.001472473,-233.65838623 ]
            [ 139.55078125,105.312568665,-240.655944824 ]
            [ 145.387130737,105.604606628,-247.884399414 ]
            [ 150.955291748,105.877967834,-255.343154907 ]
            [ 156.228805542,106.132919312,-263.026733398 ]
            [ 161.179855347,106.369743347,-270.928955078 ]
            [ 165.777984619,106.588752747,-279.040466309 ]
            [ 169.989181519,106.790176392,-287.34552002 ]
            [ 173.775894165,106.974212646,-295.817993164 ]
            [ 177.097702026,107.140960693,-304.414703369 ]
            [ 179.956924438,107.292800903,-313.212982178 ]
            [ 182.339309692,107.431900024,-322.318878174 ]
            [ 184.175720215,107.557991028,-331.702728271 ]
            [ 185.397354126,107.671066284,-341.326171875 ]
            [ 185.938644409,107.771362305,-351.141265869 ]
            [ 185.717529297,107.911094666,-361.087493896 ]
            [ 184.677978516,108.1876297,-371.092315674 ]
            [ 182.851135254,108.595077515,-381.084503174 ]
            [ 180.277557373,109.123703003,-391.006072998 ]
            [ 177.001647949,109.763237,-400.80770874 ]
            [ 173.068939209,110.503372192,-410.447113037 ]
            [ 168.522003174,111.334472656,-419.892425537 ]
            [ 163.401138306,112.247337341,-429.114868164 ]
            [ 157.743774414,113.233337402,-438.088562012 ]
            [ 151.582015991,114.284744263,-446.792541504 ]
            [ 144.94519043,115.394256592,-455.205474854 ]
            [ 137.859451294,116.555038452,-463.306091309 ]
            [ 130.347595215,117.76071167,-471.072875977 ]
            [ 122.429763794,119.0051651,-478.483001709 ]
            [ 114.124397278,120.282394409,-485.511016846 ]
            [ 105.448013306,121.586471558,-492.129058838 ]
            [ 96.4167327881,122.911254883,-498.305297852 ]
            [ 87.0467224121,124.250305176,-504.003662109 ]
            [ 77.3535308838,125.596916199,-509.184051514 ]
            [ 67.3573760986,126.943336487,-513.799377441 ]
            [ 57.0790901184,128.281311035,-517.798217773 ]
            [ 46.5477485657,129.601104736,-521.121948242 ]
            [ 35.7965621948,130.892059326,-523.707702637 ]
            [ 24.8723335266,132.141586304,-525.487731934 ]
            [ 13.8318681717,133.335845947,-526.393920898 ]
            [ 2.74674201012,134.459671021,-526.36151123 ]
            [ -8.29572296143,135.496948242,-525.335998535 ]
            [ -19.1964817047,136.431869507,-523.280578613 ]
            [ -29.8476467133,137.249908447,-520.184020996 ]
            [ -40.1423683167,137.93951416,-516.065551758 ]
            [ -49.9852485657,138.493225098,-510.975097656 ]
            [ -59.2952537537,138.908050537,-504.991943359 ]
            [ -68.019821167,139.185852051,-498.212036133 ]
            [ -76.1301956177,139.332199097,-490.740814209 ]
            [ -83.743850708,139.412384033,-482.790710449 ]
            [ -91.0249023438,139.522979736,-474.587280273 ]
            [ -97.9480667114,139.671234131,-466.127929688 ]
            [ -104.479034424,139.864196777,-457.411437988 ]
            [ -110.577644348,140.110031128,-448.439971924 ]
            [ -116.197921753,140.418121338,-439.219512939 ]
            [ -121.288833618,140.799362183,-429.758392334 ]
            [ -125.793312073,141.266433716,-420.068084717 ]
            [ -129.645675659,141.833892822,-410.168395996 ]
            [ -132.771606445,142.518173218,-400.090240479 ]
            [ -135.089172363,143.337539673,-389.878601074 ]
            [ -136.511672974,144.312301636,-379.589416504 ]
            [ -136.948913574,145.462631226,-369.309173584 ]
            [ -136.317901611,146.80758667,-359.14730835 ]
            [ -134.554519653,148.361938477,-349.241516113 ]
            [ -131.629745483,150.132675171,-339.751647949 ]
            [ -127.565734863,152.11541748,-330.846954346 ]
            [ -122.443649292,154.293014526,-322.682556152 ]
            [ -116.397857666,156.637298584,-315.37600708 ]
            [ -109.597541809,159.113082886,-308.992584229 ]
            [ -102.221061707,161.683944702,-303.542510986 ]
            [ -94.4408721924,164.314590454,-298.994567871 ]
            [ -86.4014663696,166.976486206,-295.284210205 ]
            [ -78.2233047485,169.645828247,-292.333465576 ]
            [ -70.0087127686,172.301513672,-290.061187744 ]
            [ -61.8277359009,174.930206299,-288.384185791 ]
            [ -53.7420158386,177.518951416,-287.226806641 ]
            [ -45.7969551086,180.05821228,-286.518859863 ]
            [ -38.0368270874,182.537384033,-286.197357178 ]
            [ -30.4873790741,184.950714111,-286.204589844 ]
            [ -23.1721172333,187.291183472,-286.484893799 ]
            [ -16.1325569153,189.542434692,-286.996520996 ]
            [ -9.38508415222,191.701904297,-287.751342773 ]
            [ -2.97038316727,193.760620117,-288.763793945 ]
            [ 3.06064343452,195.707199097,-290.044281006 ]
            [ 8.67102050781,197.535552979,-291.60244751 ]
            [ 13.7887239456,199.228790283,-293.430389404 ]
            [ 18.3490600586,200.772003174,-295.503112793 ]
            [ 22.2916240692,202.149795532,-297.76751709 ]
            [ 25.5557785034,203.341567993,-300.121398926 ]
            [ 28.1162166595,204.330291748,-302.417449951 ]
            [ 30.1693935394,205.179992676,-304.690338135 ]
            [ 31.9038639069,205.964401245,-307.077972412 ]
            [ 33.317276001,206.683288574,-309.546783447 ]
            [ 34.4193763733,207.338470459,-312.05871582 ]
            [ 35.2316856384,207.933929443,-314.575897217 ]
            [ 35.7845230103,208.47543335,-317.065429688 ]
            [ 36.1127128601,208.969863892,-319.501953125 ]
            [ 36.2514152527,209.424072266,-321.866821289 ]
            [ 36.2336006165,209.844909668,-324.149932861 ]
            [ 36.0884666443,210.238098145,-326.344024658 ]
            [ 35.8409347534,210.608917236,-328.448181152 ]
            [ 35.5119247437,210.961578369,-330.462493896 ]
            [ 35.1187591553,211.299575806,-332.388793945 ]
            [ 34.6756477356,211.625732422,-334.230102539 ]
            [ 34.1941490173,211.942352295,-335.990112305 ]
            [ 33.6836624146,212.251342773,-337.672821045 ]
            [ 33.1521568298,212.553970337,-339.28125 ]
            [ 32.6058502197,212.851470947,-340.819580078 ]
            [ 32.0497245789,213.144851685,-342.291870117 ]
            [ 31.4883670807,213.434585571,-343.700653076 ]
            [ 30.9249305725,213.721389771,-345.050018311 ]
            [ 30.3622760773,214.005645752,-346.342926025 ]
            [ 29.8029918671,214.287521362,-347.581695557 ]
            [ 29.2486629486,214.567382813,-348.769714355 ]
            [ 28.7008705139,214.845352173,-349.909393311 ]
            [ 28.1608924866,215.121505737,-351.003082275 ]
            [ 27.6297607422,215.395874023,-352.052947998 ]
            [ 27.1082553864,215.66847229,-353.061126709 ]
            [ 26.5969524384,215.939315796,-354.029663086 ]
            [ 26.0963306427,216.208358765,-354.960449219 ]
            [ 25.606754303,216.47555542,-355.855163574 ]
            [ 25.1284790039,216.740829468,-356.715454102 ]
            [ 24.6616668701,217.004135132,-357.542907715 ]
            [ 24.2064056396,217.265365601,-358.339019775 ]
            [ 23.7627372742,217.52444458,-359.105133057 ]
            [ 23.330663681,217.781295776,-359.842529297 ]
            [ 22.910150528,218.035797119,-360.552398682 ]
            [ 22.5011405945,218.287841797,-361.235870361 ]
            [ 22.1033115387,218.537460327,-361.894378662 ]
            [ 21.7167053223,218.784469604,-362.528656006 ]
            [ 21.3412094116,219.0287323,-363.13961792 ]
            [ 20.9765014648,219.270263672,-363.728424072 ]
            [ 20.6223659515,219.509002686,-364.296051025 ]
            [ 20.278837204,219.7447052,-364.842926025 ]
            [ 19.9453964233,219.977539063,-365.370330811 ]
            [ 19.6219959259,220.207275391,-365.878845215 ]
            [ 19.3085327148,220.433807373,-366.368927002 ]
            [ 19.0043773651,220.657333374,-366.84197998 ]
            [ 18.7098903656,220.87739563,-367.297698975 ]
            [ 18.4241333008,221.094451904,-367.737854004 ]
            [ 18.1476097107,221.307922363,-368.16192627 ]
            [ 17.8794116974,221.518280029,-368.571533203 ]
            [ 17.6199913025,221.724960327,-368.966186523 ]
            [ 17.368396759,221.928497314,-369.347564697 ]
            [ 17.1251926422,222.128250122,-369.714935303 ]
            [ 16.8893184662,222.324874878,-370.070098877 ]
            [ 16.6613197327,222.517730713,-370.412353516 ]
            [ 16.4404792786,222.707214355,-370.742919922 ]
            [ 16.2268009186,222.8931427,-371.061920166 ]
            [ 16.0202541351,223.0753479,-371.369476318 ]
            [ 15.8200531006,223.254348755,-371.666870117 ]
            [ 15.6266775131,223.429550171,-371.953491211 ]
            [ 15.4395685196,223.601272583,-372.230224609 ]
            [ 15.2584686279,223.769607544,-372.497558594 ]
            [ 15.0835866928,223.934173584,-372.755249023 ]
            [ 14.914358139,224.095367432,-373.004150391 ]
            [ 14.7506465912,224.253158569,-373.244537354 ]
            [ 14.5925960541,224.407272339,-373.476257324 ]
            [ 14.4398231506,224.557937622,-373.699951172 ]
            [ 14.2919311523,224.705413818,-373.916168213 ]
            [ 14.1491889954,224.849304199,-374.124603271 ]
            [ 14.0114269257,224.989639282,-374.325531006 ]
            [ 13.8780708313,225.12689209,-374.519805908 ]
            [ 13.7492513657,225.260803223,-374.707275391 ]
            [ 13.624961853,225.391296387,-374.887969971 ]
            [ 13.5050554276,225.518386841,-375.062133789 ]
            [ 13.3890399933,225.642501831,-375.230499268 ]
            [ 13.2770090103,225.763442993,-375.392974854 ]
            [ 13.168964386,225.881118774,-375.549530029 ]
            [ 13.0647773743,225.995574951,-375.700408936 ]
            [ 12.9642810822,226.106903076,-375.845825195 ]
            [ 12.8670368195,226.215515137,-375.986450195 ]
            [ 12.7733039856,226.321029663,-376.121948242 ]
            [ 12.6829710007,226.42350769,-376.252441406 ]
            [ 12.5959272385,226.522994995,-376.378112793 ]
            [ 12.5120687485,226.619537354,-376.499145508 ]
            [ 12.4310789108,226.713439941,-376.615966797 ]
            [ 12.352971077,226.804626465,-376.728607178 ]
            [ 12.277765274,226.893005371,-376.837036133 ]
            [ 12.2053718567,226.978637695,-376.941345215 ]
            [ 12.1357011795,227.061569214,-377.041717529 ]
            [ 12.0686664581,227.141830444,-377.138244629 ]
            [ 12.0041875839,227.219497681,-377.231079102 ]
            [ 11.941950798,227.294891357,-377.320678711 ]
            [ 11.882106781,227.367782593,-377.406799316 ]
            [ 11.824596405,227.438217163,-377.489532471 ]
            [ 11.7693462372,227.506210327,-377.569000244 ]
            [ 11.7162885666,227.571853638,-377.645324707 ]
            [ 11.665353775,227.635162354,-377.718566895 ]
            [ 11.61647892,227.696182251,-377.788818359 ]
            [ 11.569601059,227.754989624,-377.856201172 ]
            [ 11.5246553421,227.811599731,-377.920806885 ]
            [ 11.481423378,227.866287231,-377.982940674 ]
            [ 11.4400196075,227.918869019,-378.042449951 ]
            [ 11.400387764,227.969390869,-378.099395752 ]
            [ 11.3624763489,228.01789856,-378.153869629 ]
            [ 11.3262319565,228.064437866,-378.205932617 ]
            [ 11.2916049957,228.109054565,-378.25567627 ]
            [ 11.2585487366,228.151779175,-378.303161621 ]
            [ 11.227016449,228.192672729,-378.348449707 ]
            [ 11.1969614029,228.231750488,-378.391601563 ]
            [ 11.1683416367,228.269088745,-378.43270874 ]
            [ 11.1411132813,228.3046875,-378.471832275 ]
            [ 11.115237236,228.338623047,-378.508972168 ]
            [ 11.0906734467,228.370910645,-378.544250488 ]
            [ 11.0673828125,228.401596069,-378.577697754 ]
            [ 11.0452785492,228.430786133,-378.609436035 ]
            [ 11.024348259,228.458480835,-378.63949585 ]
            [ 11.0045881271,228.484680176,-378.667877197 ]
            [ 10.9859638214,228.509414673,-378.694610596 ]
            [ 10.9684419632,228.532745361,-378.71975708 ]
            [ 10.9519910812,228.554672241,-378.743377686 ]
            [ 10.936580658,228.575241089,-378.76550293 ]
            [ 10.9221801758,228.594497681,-378.786193848 ]
            [ 10.9087600708,228.612472534,-378.805450439 ]
            [ 10.8962917328,228.629196167,-378.823364258 ]
            [ 10.8847484589,228.644683838,-378.839935303 ]
            [ 10.8741035461,228.658996582,-378.855194092 ]
            [ 10.8643312454,228.672134399,-378.869232178 ]
            [ 10.8554048538,228.684158325,-378.882049561 ]
            [ 10.8473014832,228.695083618,-378.893676758 ]
            [ 10.8399972916,228.704940796,-378.904174805 ]
            [ 10.8334674835,228.713745117,-378.913543701 ]
            [ 10.8276910782,228.721542358,-378.921844482 ]
            [ 10.8226461411,228.728363037,-378.929077148 ]
            [ 10.8183097839,228.734222412,-378.935302734 ]
            [ 10.8146629333,228.73916626,-378.940551758 ]
            [ 10.8116846085,228.74319458,-378.944824219 ]
            [ 10.8093557358,228.746337891,-378.948150635 ]
            [ 10.8076562881,228.748641968,-378.950592041 ]
            [ 10.8065681458,228.75012207,-378.952148438 ]
            [ 10.8060731888,228.750778198,-378.952880859 ]
            [ 10.8061532974,228.750671387,-378.952758789 ]
            [ 10.8067913055,228.749816895,-378.951843262 ]
            [ 10.8079710007,228.748214722,-378.950134277 ]
            [ 10.809674263,228.745910645,-378.947692871 ]
            [ 10.8118877411,228.742919922,-378.944519043 ]
            [ 10.8145933151,228.739257813,-378.940643311 ]
            [ 10.81777668,228.734954834,-378.936065674 ]
            [ 10.8214235306,228.730010986,-378.930847168 ]
            [ 10.8255186081,228.724487305,-378.924957275 ]
            [ 10.8300476074,228.71836853,-378.918457031 ]
            [ 10.8349971771,228.711685181,-378.911346436 ]
            [ 10.8403539658,228.704452515,-378.903656006 ]
            [ 10.8461036682,228.69670105,-378.89541626 ]
            [ 10.8522348404,228.688430786,-378.88659668 ]
            [ 10.8587331772,228.679672241,-378.877258301 ]
            [ 10.8655872345,228.670455933,-378.867431641 ]
            [ 10.8727846146,228.660766602,-378.857086182 ]
            [ 10.8803138733,228.650650024,-378.846282959 ]
            [ 10.8881635666,228.640106201,-378.835021973 ]
            [ 10.8963222504,228.629150391,-378.823303223 ]
            [ 10.9047784805,228.61781311,-378.811157227 ]
            [ 10.913520813,228.60609436,-378.798614502 ]
            [ 10.9225406647,228.594024658,-378.785675049 ]
            [ 10.9318256378,228.581604004,-378.772338867 ]
            [ 10.9413671494,228.568847656,-378.758636475 ]
            [ 10.9511537552,228.555786133,-378.744598389 ]
            [ 10.9611768723,228.542419434,-378.730194092 ]
            [ 10.9714269638,228.528762817,-378.715484619 ]
            [ 10.9818935394,228.514831543,-378.700439453 ]
            [ 10.9925680161,228.500640869,-378.685119629 ]
            [ 11.0034418106,228.486206055,-378.669525146 ]
            [ 11.0145053864,228.4715271,-378.653625488 ]
            [ 11.0257501602,228.456619263,-378.637481689 ]
            [ 11.0371685028,228.441513062,-378.62109375 ]
            [ 11.0487518311,228.426193237,-378.60446167 ]
            [ 11.0604858398,228.410690308,-378.587615967 ]
            [ 11.0723304749,228.395065308,-378.570587158 ]
            [ 11.0843153,228.379272461,-378.553375244 ]
            [ 11.0964336395,228.363327026,-378.535980225 ]
            [ 11.1086759567,228.347244263,-378.5184021 ]
            [ 11.1210355759,228.331008911,-378.500640869 ]
            [ 11.1335067749,228.314651489,-378.482757568 ]
            [ 11.1460809708,228.298187256,-378.464691162 ]
            [ 11.1587505341,228.281616211,-378.446502686 ]
            [ 11.1715106964,228.264938354,-378.428161621 ]
            [ 11.1843528748,228.248184204,-378.409729004 ]
            [ 11.197271347,228.23135376,-378.391174316 ]
            [ 11.2102594376,228.214447021,-378.372528076 ]
            [ 11.2233104706,228.197479248,-378.353759766 ]
            [ 11.2364187241,228.180465698,-378.33493042 ]
            [ 11.2495775223,228.163406372,-378.316040039 ]
            [ 11.2627811432,228.14630127,-378.297088623 ]
            [ 11.2760238647,228.129180908,-378.278045654 ]
            [ 11.2892999649,228.112030029,-378.258972168 ]
            [ 11.3026027679,228.094863892,-378.239868164 ]
            [ 11.3159275055,228.077697754,-378.220733643 ]
            [ 11.3292684555,228.060531616,-378.201568604 ]
            [ 11.3426198959,228.043380737,-378.182373047 ]
            [ 11.3559770584,228.026229858,-378.163208008 ]
            [ 11.3693342209,228.009109497,-378.144012451 ]
            [ 11.3826856613,227.992019653,-378.124816895 ]
            [ 11.396027565,227.974960327,-378.105651855 ]
            [ 11.4093542099,227.957946777,-378.086517334 ]
            [ 11.4226608276,227.940963745,-378.067382813 ]
            [ 11.4359426498,227.924057007,-378.048309326 ]
            [ 11.4491949081,227.907196045,-378.029266357 ]
            [ 11.4624137878,227.890396118,-378.010253906 ]
            [ 11.4755926132,227.873672485,-377.991333008 ]
            [ 11.4887285233,227.857025146,-377.972442627 ]
            [ 11.5018177032,227.840454102,-377.953643799 ]
            [ 11.5148534775,227.823974609,-377.934906006 ]
            [ 11.5278244019,227.807601929,-377.916259766 ]
            [ 11.5406942368,227.791366577,-377.897766113 ]
            [ 11.5535001755,227.775238037,-377.879364014 ]
            [ 11.5662374496,227.759216309,-377.861053467 ]
            [ 11.5789012909,227.743301392,-377.842834473 ]
            [ 11.5914897919,227.727493286,-377.824737549 ]
            [ 11.6039981842,227.71182251,-377.806762695 ]
            [ 11.6164226532,227.696258545,-377.788909912 ]
            [ 11.6287584305,227.680831909,-377.771179199 ]
            [ 11.6410036087,227.665527344,-377.753570557 ]
            [ 11.6531534195,227.650360107,-377.736083984 ]
            [ 11.6652050018,227.635345459,-377.718780518 ]
            [ 11.677154541,227.62046814,-377.701599121 ]
            [ 11.688999176,227.605728149,-377.684539795 ]
            [ 11.7007350922,227.591156006,-377.667663574 ]
            [ 11.7123584747,227.576721191,-377.650970459 ]
            [ 11.7238664627,227.562454224,-377.634399414 ]
            [ 11.7352561951,227.548355103,-377.618041992 ]
            [ 11.7465238571,227.534408569,-377.601837158 ]
            [ 11.7576675415,227.520629883,-377.58581543 ]
            [ 11.7686824799,227.507034302,-377.569946289 ]
            [ 11.7795677185,227.493606567,-377.554290771 ]
            [ 11.7903184891,227.480361938,-377.538848877 ]
            [ 11.8009328842,227.467300415,-377.52355957 ]
            [ 11.8114089966,227.454406738,-377.508514404 ]
            [ 11.8217420578,227.441711426,-377.493621826 ]
            [ 11.8319301605,227.429214478,-377.478973389 ]
            [ 11.8419704437,227.416900635,-377.464538574 ]
            [ 11.8518610001,227.404785156,-377.450317383 ]
            [ 11.8615989685,227.392852783,-377.436279297 ]
            [ 11.871181488,227.381134033,-377.422515869 ]
            [ 11.8806056976,227.369613647,-377.408935547 ]
            [ 11.8898696899,227.358306885,-377.395599365 ]
            [ 11.8989715576,227.347198486,-377.382507324 ]
            [ 11.907907486,227.33631897,-377.369659424 ]
            [ 11.9166765213,227.325637817,-377.357025146 ]
            [ 11.9252758026,227.315170288,-377.344665527 ]
            [ 11.9337034225,227.304916382,-377.332550049 ]
            [ 11.9419565201,227.294891357,-377.320648193 ]
            [ 11.9500331879,227.285079956,-377.309020996 ]
            [ 11.9579315186,227.275497437,-377.297668457 ]
            [ 11.9656486511,227.266143799,-377.286560059 ]
            [ 11.9731845856,227.257003784,-377.275726318 ]
            [ 11.9805345535,227.24810791,-377.265136719 ]
            [ 11.987698555,227.239440918,-377.254821777 ]
            [ 11.9946737289,227.231002808,-377.244781494 ]
            [ 12.0014543533,227.222808838,-377.235015869 ]
            [ 12.0080213547,227.214874268,-377.22555542 ]
            [ 12.0143938065,227.207183838,-377.216400146 ]
            [ 12.0205717087,227.19972229,-377.207489014 ]
            [ 12.0265522003,227.192520142,-377.198883057 ]
            [ 12.0323343277,227.185546875,-377.190551758 ]
            [ 12.0379161835,227.178817749,-377.182525635 ]
            [ 12.043296814,227.172348022,-377.17477417 ]
            [ 12.0484724045,227.166107178,-377.167327881 ]
            [ 12.0534439087,227.160125732,-377.16015625 ]
            [ 12.0582084656,227.154403687,-377.153320313 ]
            [ 12.0627641678,227.148925781,-377.146759033 ]
            [ 12.0671110153,227.143707275,-377.14050293 ]
            [ 12.0712461472,227.13873291,-377.134521484 ]
            [ 12.0751686096,227.134033203,-377.128875732 ]
            [ 12.0788764954,227.129577637,-377.123535156 ]
            [ 12.0823698044,227.12538147,-377.118530273 ]
            [ 12.0856456757,227.121459961,-377.113800049 ]
            [ 12.0887041092,227.117797852,-377.109405518 ]
            [ 12.0915431976,227.114395142,-377.105316162 ]
            [ 12.0941610336,227.111251831,-377.101531982 ]
            [ 12.0965576172,227.108383179,-377.098083496 ]
            [ 12.098731041,227.105773926,-377.094940186 ]
            [ 12.1006803513,227.103439331,-377.092163086 ]
            [ 12.1024036407,227.101379395,-377.089660645 ]
            [ 12.1039009094,227.099578857,-377.087524414 ]
            [ 12.1051712036,227.098068237,-377.085693359 ]
            [ 12.1062116623,227.096817017,-377.08416748 ]
            [ 12.1070232391,227.095840454,-377.083007813 ]
            [ 12.1076040268,227.095153809,-377.082183838 ]
            [ 12.1079540253,227.094726563,-377.081665039 ]
            [ 12.1080703735,227.094589233,-377.081512451 ]
            [ 12.1030082703,227.100646973,-377.088806152 ]
            [ 12.0877151489,227.118972778,-377.110809326 ]
            [ 12.0620384216,227.149795532,-377.147796631 ]
            [ 12.0258302689,227.193389893,-377.199920654 ]
            [ 11.9788665771,227.25012207,-377.26751709 ]
            [ 11.9209623337,227.320419312,-377.350860596 ]
            [ 11.8520994186,227.40447998,-377.449951172 ]
            [ 11.7721719742,227.502731323,-377.564941406 ]
            [ 11.6810855865,227.615570068,-377.695922852 ]
            [ 11.5787611008,227.743469238,-377.843048096 ]
            [ 11.4649057388,227.887237549,-378.00668335 ]
            [ 11.3394584656,228.047439575,-378.186920166 ]
            [ 11.2026023865,228.224411011,-378.383514404 ]
            [ 11.0543212891,228.418838501,-378.596466064 ]
            [ 10.8940935135,228.632141113,-378.826507568 ]
            [ 10.7225055695,228.8644104,-379.072845459 ]
            [ 10.539434433,229.116760254,-379.335632324 ]
            [ 10.3447751999,229.390426636,-379.615112305 ]
            [ 10.1390695572,229.685882568,-379.910491943 ]
            [ 9.92195415497,230.0050354,-380.222412109 ]
            [ 9.69424724579,230.348251343,-380.549743652 ]
            [ 9.45574474335,230.717605591,-380.892913818 ]
            [ 9.2072353363,231.113876343,-381.250915527 ]
            [ 8.94898319244,231.538864136,-381.623565674 ]
            [ 8.68157577515,231.994155884,-382.010223389 ]
            [ 8.40580844879,232.481231689,-382.41003418 ]
            [ 8.12237453461,233.002059937,-382.82232666 ]
            [ 7.83223962784,233.558517456,-383.24609375 ]
            [ 7.53656435013,234.15246582,-383.680114746 ]
            [ 7.23659276962,234.785995483,-384.123168945 ]
            [ 6.93377304077,235.461257935,-384.573760986 ]
            [ 6.62976789474,236.180435181,-385.030273438 ]
            [ 6.32646417618,236.945678711,-385.490753174 ]
            [ 6.02597856522,237.759140015,-385.953125 ]
            [ 5.73064661026,238.622970581,-386.415039063 ]
            [ 5.44303894043,239.539154053,-386.873962402 ]
            [ 5.16592884064,240.509658813,-387.327178955 ]
            [ 4.90228319168,241.536315918,-387.771728516 ]
            [ 4.65523958206,242.620788574,-388.204650879 ]
            [ 4.42807626724,243.764587402,-388.622711182 ]
            [ 4.22417879105,244.969055176,-389.022735596 ]
            [ 4.04720830917,246.233718872,-389.400939941 ]
            [ 3.90058326721,247.558807373,-389.754119873 ]
            [ 3.78750991821,248.946212769,-390.079437256 ]
            [ 3.71136379242,250.395767212,-390.373809814 ]
            [ 3.67384767532,251.89743042,-390.633178711 ]
            [ 3.64705443382,253.464172363,-390.868927002 ]
            [ 3.6204020977,255.092895508,-391.086547852 ]
            [ 3.594217062,256.771179199,-391.286834717 ]
            [ 3.56847000122,258.508361816,-391.472839355 ]
            [ 3.54324126244,260.307617188,-391.646118164 ]
            [ 3.51865696907,262.169464111,-391.807647705 ]
            [ 3.49484205246,264.094665527,-391.958221436 ]
            [ 3.47197508812,266.079437256,-392.098175049 ]
            [ 3.45016312599,268.12600708,-392.228179932 ]
            [ 3.4294924736,270.239715576,-392.348907471 ]
            [ 3.41010570526,272.421936035,-392.460693359 ]
            [ 3.392152071,274.674102783,-392.563812256 ]
            [ 3.37578892708,276.997772217,-392.658447266 ]
            [ 3.3611831665,279.39453125,-392.744689941 ]
            [ 3.34852552414,281.862945557,-392.822631836 ]
            [ 3.33799815178,284.403656006,-392.892272949 ]
            [ 3.32977604866,287.022705078,-392.953857422 ]
            [ 3.32406973839,289.721923828,-393.007324219 ]
            [ 3.32110357285,292.503234863,-393.052642822 ]
            [ 3.32111620903,295.368591309,-393.089813232 ]
            [ 3.32436132431,298.320068359,-393.118713379 ]
            [ 3.33108568192,301.35144043,-393.139221191 ]
            [ 3.341578722,304.47253418,-393.151306152 ]
            [ 3.35614466667,307.685760498,-393.154876709 ]
            [ 3.37510633469,310.993225098,-393.149719238 ]
            [ 3.3988070488,314.397094727,-393.13571167 ]
            [ 3.42753005028,317.890380859,-393.112731934 ]
            [ 3.46170926094,321.48336792,-393.080596924 ]
            [ 3.50175786018,325.178924561,-393.039031982 ]
            [ 3.54810833931,328.979156494,-392.987884521 ]
            [ 3.6010787487,332.876373291,-392.927062988 ]
            [ 3.661236763,336.88067627,-392.856262207 ]
            [ 3.72910690308,340.995269775,-392.775177002 ]
            [ 3.80511641502,345.216339111,-392.683685303 ]
            [ 3.889783144,349.544708252,-392.581634521 ]
            [ 3.98379945755,353.988098145,-392.468597412 ]
            [ 4.08762454987,358.541351318,-392.344482422 ]
            [ 4.20186901093,363.205749512,-392.209106445 ]
            [ 4.32732582092,367.988189697,-392.062011719 ]
            [ 4.46435451508,372.877929688,-391.90335083 ]
            [ 4.61388778687,377.88470459,-391.732574463 ]
            [ 4.77649688721,383.003936768,-391.549682617 ]
            [ 4.95284843445,388.234100342,-391.354492188 ]
            [ 5.14379549026,393.578155518,-391.146728516 ]
            [ 5.34980487823,399.027709961,-390.926483154 ]
            [ 5.57190513611,404.588989258,-390.693328857 ]
            [ 5.81044578552,410.250396729,-390.447601318 ]
            [ 6.06650447845,416.017822266,-390.188842773 ]
            [ 6.3403968811,421.879364014,-389.917419434 ]
            [ 6.63311767578,427.838012695,-389.633087158 ]
            [ 6.94502735138,433.883544922,-389.336120605 ]
            [ 7.27690649033,440.014373779,-389.026519775 ]
            [ 7.62922716141,446.223236084,-388.704528809 ]
            [ 8.00244045258,452.503051758,-388.370391846 ]
            [ 8.39717388153,458.850158691,-388.024230957 ]
            [ 8.81346225739,465.251953125,-387.666656494 ]
            [ 9.2519903183,471.706695557,-387.297698975 ]
            [ 9.71267414093,478.201782227,-386.91809082 ]
            [ 10.1958551407,484.731842041,-386.528076172 ]
            [ 10.7015714645,491.28793335,-386.128234863 ]
            [ 11.2296791077,497.859954834,-385.719146729 ]
            [ 11.7803182602,504.442230225,-385.301239014 ]
            [ 12.3529977798,511.022491455,-384.875335693 ]
            [ 12.9477396011,517.59564209,-384.441833496 ]
            [ 13.564043045,524.151489258,-384.001525879 ]
            [ 14.2015714645,530.682800293,-383.554962158 ]
            [ 14.8598508835,537.181762695,-383.102783203 ]
            [ 15.5383119583,543.64074707,-382.645690918 ]
            [ 16.2364330292,550.053344727,-382.184265137 ]
            [ 16.9535312653,556.412475586,-381.719177246 ]
            [ 17.6889858246,562.712585449,-381.25100708 ]
            [ 18.4420890808,568.948059082,-380.780334473 ]
            [ 19.2121162415,575.113708496,-380.307769775 ]
            [ 19.9983634949,581.20526123,-379.833770752 ]
            [ 20.8000640869,587.218505859,-379.358917236 ]
            [ 21.6164493561,593.149780273,-378.88369751 ]
            [ 22.4468803406,598.996704102,-378.408508301 ]
            [ 23.2904319763,604.755432129,-377.933837891 ]
            [ 24.1465835571,610.425231934,-377.460021973 ]
            [ 25.014509201,616.003479004,-376.987426758 ]
            [ 25.8933753967,621.488037109,-376.51651001 ]
            [ 26.7828083038,626.879760742,-376.047363281 ]
            [ 27.681968689,632.176757813,-375.580413818 ]
            [ 28.5900859833,637.377868652,-375.115936279 ]
            [ 29.5065937042,642.483276367,-374.654144287 ]
            [ 30.4312858582,647.495117188,-374.195068359 ]
            [ 31.3631649017,652.411315918,-373.739074707 ]
            [ 32.3016815186,657.23236084,-373.286376953 ]
            [ 33.2463150024,661.958984375,-372.837036133 ]
            [ 34.1966438293,666.592346191,-372.391204834 ]
            [ 35.1525192261,671.134887695,-371.948822021 ]
            [ 36.1130905151,675.58581543,-371.510162354 ]
            [ 37.0779266357,679.946166992,-371.075317383 ]
            [ 38.0466194153,684.217163086,-370.644317627 ]
            [ 39.0187759399,688.40020752,-370.217254639 ]
            [ 39.9940261841,692.496582031,-369.794189453 ]
            [ 40.9720115662,696.507629395,-369.37512207 ]
            [ 41.9574813843,700.45489502,-368.957946777 ]
            [ 42.9554176331,704.359008789,-368.540557861 ]
            [ 43.9658050537,708.219665527,-368.123016357 ]
            [ 44.9886398315,712.036804199,-367.705352783 ]
            [ 46.0239105225,715.810241699,-367.287597656 ]
            [ 47.0716056824,719.539855957,-366.869781494 ]
            [ 48.1317100525,723.225402832,-366.45199585 ]
            [ 49.2042121887,726.866760254,-366.034240723 ]
            [ 50.2890968323,730.463806152,-365.616546631 ]
            [ 51.3863449097,734.016296387,-365.198944092 ]
            [ 52.4959373474,737.524108887,-364.781524658 ]
            [ 53.6178512573,740.987121582,-364.364318848 ]
            [ 54.7520637512,744.405090332,-363.947296143 ]
            [ 55.8985481262,747.777893066,-363.530578613 ]
            [ 57.05727005,751.10534668,-363.11416626 ]
            [ 58.2281951904,754.387268066,-362.6980896 ]
            [ 59.4112854004,757.623535156,-362.282409668 ]
            [ 60.6064987183,760.813842773,-361.867156982 ]
            [ 61.8137893677,763.958129883,-361.452392578 ]
            [ 63.0331001282,767.056213379,-361.038116455 ]
            [ 64.2593231201,770.110900879,-360.625244141 ]
            [ 65.4782409668,773.126342773,-360.216247559 ]
            [ 66.6894989014,776.10369873,-359.811157227 ]
            [ 67.8930969238,779.04296875,-359.409973145 ]
            [ 69.089012146,781.944274902,-359.012634277 ]
            [ 70.2772369385,784.807556152,-358.61920166 ]
            [ 71.4577636719,787.633056641,-358.22958374 ]
            [ 72.6305770874,790.420715332,-357.843841553 ]
            [ 73.7956542969,793.170654297,-357.461914063 ]
            [ 74.9529876709,795.882995605,-357.08380127 ]
            [ 76.1025543213,798.557739258,-356.709472656 ]
            [ 77.2443466187,801.195068359,-356.33895874 ]
            [ 78.3783340454,803.79510498,-355.972229004 ]
            [ 79.5045013428,806.357849121,-355.60925293 ]
            [ 80.6228179932,808.883483887,-355.250030518 ]
            [ 81.7340087891,811.373779297,-354.894348145 ]
            [ 82.8374938965,813.827575684,-354.542297363 ]
            [ 83.9331054688,816.244628906,-354.193969727 ]
            [ 85.0208053589,818.62512207,-353.849334717 ]
            [ 86.1005630493,820.969238281,-353.508361816 ]
            [ 87.1723556519,823.276977539,-353.171081543 ]
            [ 88.2361373901,825.548583984,-352.837463379 ]
            [ 89.291885376,827.784240723,-352.507507324 ]
            [ 90.339553833,829.984008789,-352.181182861 ]
            [ 91.3791046143,832.148071289,-351.858459473 ]
            [ 92.4104995728,834.276672363,-351.539367676 ]
            [ 93.4336929321,836.369873047,-351.223907471 ]
            [ 94.4498596191,838.430419922,-350.911651611 ]
            [ 95.4579849243,840.456359863,-350.602905273 ]
            [ 96.457824707,842.447631836,-350.297729492 ]
            [ 97.4493103027,844.40423584,-349.996124268 ]
            [ 98.4323959351,846.326538086,-349.698059082 ]
            [ 99.4070205688,848.214660645,-349.403533936 ]
            [ 100.373130798,850.068786621,-349.112548828 ]
            [ 101.33065033,851.889160156,-348.82510376 ]
            [ 102.280815125,853.678344727,-348.540802002 ]
            [ 103.222938538,855.435424805,-348.25982666 ]
            [ 104.156333923,857.159423828,-347.982330322 ]
            [ 105.080924988,858.850524902,-347.708343506 ]
            [ 105.996650696,860.509033203,-347.437835693 ]
            [ 106.903411865,862.135070801,-347.170837402 ]
            [ 107.801956177,863.73046875,-346.907073975 ]
            [ 108.692955017,865.296569824,-346.646331787 ]
            [ 109.574813843,866.831115723,-346.389068604 ]
            [ 110.44744873,868.33416748,-346.135253906 ]
            [ 111.310760498,869.806091309,-345.88494873 ]
            [ 112.164985657,871.247680664,-345.637969971 ]
            [ 113.012153625,872.662658691,-345.393798828 ]
            [ 113.849784851,874.047302246,-345.153045654 ]
            [ 114.677772522,875.401794434,-344.915771484 ]
            [ 115.496002197,876.726501465,-344.681976318 ]
            [ 116.306365967,878.024719238,-344.451080322 ]
            [ 117.10799408,879.295593262,-344.223297119 ]
            [ 117.899620056,880.537414551,-343.998962402 ]
            [ 118.681129456,881.750488281,-343.778106689 ]
            [ 119.45475769,882.938720703,-343.560089111 ]
            [ 120.219261169,884.100524902,-343.345184326 ]
            [ 120.973381042,885.23449707,-343.133758545 ]
            [ 121.717391968,886.341430664,-342.925689697 ]
            [ 122.454231262,887.426147461,-342.720184326 ]
            [ 123.180389404,888.483825684,-342.518127441 ]
            [ 123.895751953,889.514770508,-342.319549561 ]
            [ 124.603744507,890.524353027,-342.123504639 ]
            [ 125.301368713,891.508666992,-341.930786133 ]
            [ 125.987884521,892.467102051,-341.741577148 ]
            [ 126.666984558,893.405212402,-341.554840088 ]
            [ 127.335456848,894.319030762,-341.371429443 ]
            [ 127.992805481,895.208251953,-341.191467285 ]
            [ 128.643081665,896.078735352,-341.013824463 ]
            [ 129.281784058,896.924865723,-340.83972168 ]
            [ 129.910964966,897.749755859,-340.668548584 ]
            [ 130.531173706,898.55456543,-340.500183105 ]
            [ 131.13949585,899.335876465,-340.335357666 ]
            [ 131.740875244,900.100402832,-340.172729492 ]
            [ 132.33039856,900.842285156,-340.01361084 ]
            [ 132.911102295,901.565734863,-339.857147217 ]
            [ 133.481689453,902.26953125,-339.703704834 ]
            [ 134.042068481,902.953857422,-339.553253174 ]
            [ 134.593612671,903.620788574,-339.405456543 ]
            [ 135.134033203,904.267883301,-339.260864258 ]
            [ 135.666412354,904.899169922,-339.118682861 ]
            [ 136.187210083,905.510864258,-338.979797363 ]
            [ 136.700332642,906.107788086,-338.843170166 ]
            [ 137.201873779,906.685791016,-338.709838867 ]
            [ 137.695663452,907.249572754,-338.578765869 ]
            [ 138.178314209,907.795532227,-338.450836182 ]
            [ 138.652694702,908.327331543,-338.325286865 ]
            [ 139.116836548,908.842895508,-338.202606201 ]
            [ 139.571762085,909.343811035,-338.082519531 ]
            [ 140.017745972,909.830505371,-337.964935303 ]
            [ 140.453216553,910.301696777,-337.850280762 ]
            [ 140.881439209,910.761047363,-337.737670898 ]
            [ 141.298553467,911.204711914,-337.628112793 ]
            [ 141.708282471,911.636962891,-337.520629883 ]
            [ 142.108337402,912.055541992,-337.415802002 ]
            [ 142.498718262,912.460693359,-337.313598633 ]
            [ 142.882125854,912.855407715,-337.213348389 ]
            [ 143.255264282,913.236633301,-337.115875244 ]
            [ 143.620361328,913.606750488,-337.020599365 ]
            [ 143.97756958,913.966186523,-336.927490234 ]
            [ 144.325057983,914.313232422,-336.836975098 ]
            [ 144.665252686,914.650512695,-336.748474121 ]
            [ 144.997558594,914.977600098,-336.662078857 ]
            [ 145.320648193,915.293395996,-336.578155518 ]
            [ 145.636413574,915.599914551,-336.49621582 ]
            [ 145.945068359,915.897521973,-336.416168213 ]
            [ 146.245040894,916.184875488,-336.338439941 ]
            [ 146.536911011,916.462585449,-336.2628479 ]
            [ 146.823196411,916.733276367,-336.188781738 ]
            [ 147.101318359,916.994628906,-336.116882324 ]
            [ 147.371490479,917.246948242,-336.047088623 ]
            [ 147.63508606,917.491699219,-335.979034424 ]
            [ 147.892623901,917.729431152,-335.912567139 ]
            [ 148.142730713,917.95892334,-335.848083496 ]
            [ 148.385604858,918.180541992,-335.785491943 ]
            [ 148.622238159,918.395324707,-335.72454834 ]
            [ 148.853546143,918.604187012,-335.665008545 ]
            [ 149.078125,918.805847168,-335.60723877 ]
            [ 149.296142578,919.000671387,-335.551177979 ]
            [ 149.507797241,919.188842773,-335.496795654 ]
            [ 149.714797974,919.372009277,-335.443603516 ]
            [ 149.916305542,919.549438477,-335.391876221 ]
            [ 150.111907959,919.72088623,-335.341674805 ]
            [ 150.301818848,919.88659668,-335.29296875 ]
            [ 150.486206055,920.04675293,-335.245697021 ]
            [ 150.666091919,920.202392578,-335.199584961 ]
            [ 150.841705322,920.353637695,-335.154602051 ]
            [ 151.012268066,920.499938965,-335.110931396 ]
            [ 151.177947998,920.641479492,-335.068511963 ]
            [ 151.338928223,920.778503418,-335.02734375 ]
            [ 151.495361328,920.911132813,-334.987335205 ]
            [ 151.647888184,921.039978027,-334.94833374 ]
            [ 151.797195435,921.165588379,-334.91015625 ]
            [ 151.94241333,921.287414551,-334.873046875 ]
            [ 152.083724976,921.405517578,-334.83694458 ]
            [ 152.221252441,921.520019531,-334.801849365 ]
            [ 152.355194092,921.631225586,-334.76763916 ]
            [ 152.485671997,921.739196777,-334.734344482 ]
            [ 152.612854004,921.844116211,-334.701904297 ]
            [ 152.738021851,921.947021484,-334.66998291 ]
            [ 152.860244751,922.047241211,-334.638793945 ]
            [ 152.979598999,922.144775391,-334.608398438 ]
            [ 153.096221924,922.239807129,-334.578674316 ]
            [ 153.210266113,922.332519531,-334.549591064 ]
            [ 153.321884155,922.422973633,-334.521179199 ]
            [ 153.43119812,922.511291504,-334.49331665 ]
            [ 153.538375854,922.597717285,-334.466033936 ]
            [ 153.643554688,922.682250977,-334.43927002 ]
            [ 153.747817993,922.765869141,-334.412719727 ]
            [ 153.850311279,922.847839355,-334.386657715 ]
            [ 153.951187134,922.928283691,-334.360992432 ]
            [ 154.050582886,923.007385254,-334.335723877 ]
            [ 154.148590088,923.085144043,-334.310791016 ]
        ]