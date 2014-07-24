class App

    app                 : @

    animFPS             : 25

    container           : null
    stats               : null

    camera              : null
    scene               : null
    renderer            : null
    materialDepth       : null
    composer            : null

    renderTarget        : null
    renderPass          : null
    fxaa                : null
    colorCorr           : null
    bloom               : null
    film                : null
    bleach              : null
    hblur               : null
    vblur               : null
    renderToScreenPass  : null
            
    creatureMesh            : null
    skyCube                 : null
    skyCubeTexture          : null
    creatureShaderUniforms  : null
    currentAnimation        : null
    lastKeyFrame            : null

    # wings
    wingMesh        : null
    wingMesh2       : null
    wingAnim        : 0
            
    # currectly intersected object with mouse
    pickMouse           : null

    dandelionMeshes     : null

    projector           : new THREE.Projector

    sunLight            : null
    ambientLight        : null
    screenSpacePosition : new THREE.Vector3

    mouseX              : 0
    mouseY              : 0

    SCREEN_WIDTH        : window.innerWidth
    SCREEN_HEIGHT       : window.innerHeight

    windowHalfX         : @SCREEN_WIDTH / 2
    windowHalfY         : @SCREEN_HEIGHT / 2

    postprocessing      : null
    params : 
        animated:true,
        enableFXAA: false,
        enableBloom: true,
        bloomIntensity: 0.9,
        enableFilmEffect: true,
        filmEffectScanlinesIntensity: 0.8,
        filmEffectNoiseIntensity: 0.4,
        enableGodRays: true,
        enableColorCorrection:false,
        godRaysColor:[255,249,230],
        godRaysIntensity: 0.7,

        enableShadows:true,
        sunColor: [255,242,204],
        sunIntensity:1.2,
        ambientColor: [255,242,204],
        enableAmbientOcclusion:true,
        enableNormalMap:true,
        normalMapScale: 7,
        enableSpecular:false,
        enableReflection:true,
        reflectionStrength:0.05

    clock : new THREE.Clock

    constructor : ->
        @postprocessing = {}
        @pickMouse = { x : 0, y : 0 }
        @init()
        @


    init : -> 

        @container = document.createElement 'div' 
        document.body.appendChild @container 

        @camera = new THREE.PerspectiveCamera( 50, @SCREEN_WIDTH / @SCREEN_HEIGHT, 1, 5000 )
        @camera.position.z = 300

        @scene = new THREE.Scene()
        
        # SKY
        @initSky()

        @materialDepth = new THREE.MeshDepthMaterial
        @materialDepth.morphTargets = @params.animated

        # RENDERER
        @renderer = new THREE.WebGLRenderer { antialias: false }
        @renderer.setSize( @SCREEN_WIDTH, @SCREEN_HEIGHT )
        @renderer.sortObjects = true
        @renderer.autoClear = false
        @renderer.setClearColorHex( @params.bgColor, 1 )
        @renderer.domElement.style.position = 'absolute'
        @renderer.domElement.style.top = "0px"
        @renderer.domElement.style.left = "0px"
        @renderer.shadowMapEnabled = @params.enableShadows
        @renderer.shadowMapSoft = true
        @renderer.shadowMapSoft = true
        @renderer.gammaInput = true
        @renderer.gammaOutput = true
        @container.appendChild @renderer.domElement 


        # STATS
        @stats = new Stats()
        @stats.domElement.style.position = 'absolute'
        @stats.domElement.style.top = '0px'
        @container.appendChild( @stats.domElement )

        @stats.domElement.children[ 0 ].children[ 0 ].style.color = "#888"
        @stats.domElement.children[ 0 ].style.background = "transparent"
        @stats.domElement.children[ 0 ].children[ 1 ].style.display = "none"

        # LISTENERS
        document.addEventListener( 'mousemove', @onDocumentMouseMove, false )
        document.addEventListener( 'mousedown', @onDocumentMouseClick, false )
        document.addEventListener( 'touchstart', @onDocumentTouchStart, false )
        document.addEventListener( 'touchmove', @onDocumentTouchMove, false )
        window.addEventListener( 'resize', @onWindowResize, false )

        #initBlurScene()
        @initLights()
        @initPostprocessing()
        @initRenderPasses()
        @initComposer(null)
        @initGUI()
        @initDandelions()

        # LOADING
        loader = new THREE.GeometryLoader
        loader.addEventListener( 'load', @initCreature)
        loader.load("sophie/sophie_anim3.js")

        @

    initGUI :->
            
        onEnableShadowsChange : (value) ->
            @renderer.shadowMapEnabled = @sunLight.castShadow = @creatureMesh.castShadow = @creatureMesh.receiveShadow = value
            @creatureShaderUniforms[ "shadowMap" ].value = []

        onSunColorChange                     : (value) -> @sunLight.color.setRGB( @params.sunColor[0]/255, @params.sunColor[1]/255, @params.sunColor[2]/255 )
        onSunIntensityChange                 : (value) -> @sunLight.intensity = value
        onAmbientColorChange                 : (value) -> @ambientLight.color.setRGB( @params.ambientColor[0]/255, @params.ambientColor[1]/255, @params.ambientColor[2]/255)
        onBloomIntensityChange               : (value) -> @bloom.strength = bloom.screenUniforms[ "opacity" ].value = value
        onFilmEffectScanLinesIntensityChange : (value) -> @film.uniforms['sIntensity'].value = value
        onFilmEffectNoiseIntensityChange     : (value) -> @film.uniforms['nIntensity'].value = value

        controller = null
        gui = new dat.GUI {width:400}
                
        postProcFolder = gui.addFolder "Post Processing"

        controller = postProcFolder.add(@params, 'enableFXAA').name('Enable Antialiasing')
        controller.onChange @initComposer

        controller = postProcFolder.add(@params, 'enableBloom').name('Enable Bloom')
        controller.onChange @initComposer

        controller = postProcFolder.add(@params, 'bloomIntensity',0,2).name('Bloom Intensity')
        controller.onChange @onBloomIntensityChange

        controller = postProcFolder.add(@params, 'enableFilmEffect').name('Enable Film Effect')
        controller.onChange @initComposer

        controller = postProcFolder.add(@params, 'filmEffectScanlinesIntensity',0,5).name('Film Scanlines Intensity')
        controller.onChange @onFilmEffectScanLinesIntensityChange

        controller = postProcFolder.add(@params, 'filmEffectNoiseIntensity',0,5).name('Film Noise Intensity')
        controller.onChange @onFilmEffectNoiseIntensityChange

        controller = postProcFolder.add(@params, 'enableGodRays').name('Enable Fog')
        controller.onChange @initComposer

        controller = postProcFolder.addColor(@params, 'godRaysColor').name('Fog Color')
        controller = postProcFolder.add(@params, 'godRaysIntensity',0,2).name('Fog Intensity')


        creatureFolder = gui.addFolder "Lighting"

        controller = creatureFolder.add(@params, 'enableShadows').name('Enable Shadows')
        controller.onChange @onEnableShadowsChange

        controller = creatureFolder.addColor(@params, 'sunColor').name('Sun Color')
        controller.onChange @onSunColorChange

        controller = creatureFolder.add(@params, 'sunIntensity',0,10).name('Sun Intensity')
        controller.onChange @onSunIntensityChange

        controller = creatureFolder.addColor(@params, 'ambientColor').name('Ambient Color')
        controller.onChange @onAmbientColorChange

        controller = creatureFolder.add(@params, 'normalMapScale',0,50).name('Normal Mapping Intensity')
        controller.onChange @onCreatureShaderChange

        controller = creatureFolder.add(@params, 'enableAmbientOcclusion').name('Enable Ambient Occlusion')
        controller.onChange @onCreatureShaderChange

        controller = creatureFolder.add(@params, 'enableSpecular').name('Enable Specular')
        controller.onChange @onCreatureShaderChange

        controller = creatureFolder.add(@params, 'enableReflection').name('Enable Reflection')
        controller.onChange @onCreatureShaderChange

        controller = creatureFolder.add(@params, 'reflectionStrength',0,1).name('Reflection Strength')
        controller.onChange @onCreatureShaderChange

        @

    initDandelions :->
        @dandelionTexture = THREE.ImageUtils.loadTexture( "textures/dandelion.png" )
        geom = new THREE.PlaneGeometry( 10, 10 )

        if(@params.animated)
            geom.morphTargets[0] = {name:"fake",vertices:geom.vertices};

        @mat = new THREE.MeshBasicMaterial
            map: @dandelionTexture, 
            transparent: true, 
            wireframe:false, 
            wireframeLinewidth:10

        @dandelionMeshes = []

        for i in [0..400]
            dandelion = new THREE.Mesh( geom, @mat )
            dandelion.name = "dandelion"+i
            dandelion.position.x = Math.random() * 1000 - 500
            dandelion.position.y = Math.random() * 1000 - 500
            dandelion.position.z = @camera.position.z - 20 - ( Math.random() * 1000 )
            dandelion.CCW = Math.random() > 0.5
            dandelion.speed = 1+Math.random()*10

            @dandelionMeshes.push(dandelion)
            @scene.add(dandelion)
        @

    
    onCreatureShaderChange : (value) ->

        @creatureShaderUniforms[ "enableAO" ].value = @params.enableAmbientOcclusion;
        @creatureShaderUniforms[ "enableSpecular" ].value = @params.enableSpecular;
        @creatureShaderUniforms[ "enableReflection" ].value = @params.enableReflection;
        @creatureShaderUniforms[ "uNormalScale" ].value.set( @params.normalMapScale, @params.normalMapScale );
        @creatureShaderUniforms[ "uReflectivity" ].value = @params.reflectionStrength;
        @


    initLights :->
        @sunLight = new THREE.DirectionalLight
        @sunLight.color.setRGB( @params.sunColor[0]/255, @params.sunColor[1]/255, @params.sunColor[2]/255)
        @sunLight.position.set( 0, 400, -400 )
        @sunLight.intensity = @params.sunIntensity
        @sunLight.castShadow = true
        @sunLight.shadowCameraNear = 1
        @sunLight.shadowCameraFov = 70
        #dirLight.shadowBias = 0.001
        @sunLight.shadowMapWidth = 1024
        @sunLight.shadowMapHeight = 1024
        @sunLight.shadowCameraLeft = 150
        @sunLight.shadowCameraRight = -150
        @sunLight.shadowCameraTop = 250
        @sunLight.shadowCameraBottom = -250
        #sunLight.shadowCameraVisible = true
        @scene.add @sunLight 

        @ambientLight = new THREE.AmbientLight()
        @ambientLight.color.setRGB(@params.ambientColor[0]/255, @params.ambientColor[1]/255, @params.ambientColor[2]/255)
        @scene.add @ambientLight
        
        @
            
    initCreature :(event)=>

        geometry = event.content
        geometry.computeTangents()

        faceMaterial = @getFairyMaterial()
        faceMaterial.morphTargets = @params.animated

        @creatureMesh = new THREE.MorphAnimMesh( geometry, faceMaterial )
        @creatureMesh.name = "creature";
        @creatureMesh.setAnimationLabel("idle",0,10)
        @creatureMesh.setAnimationLabel("fly",11,29)
        @creatureMesh.setAnimationLabel("interact",30,38)

        @creatureMesh.castShadow = true
        @creatureMesh.receiveShadow = true
        @creatureMesh.duration = 1000
        @creatureMesh.position.set( 100, 1000, -2500 )

        sc = 1;
        @creatureMesh.scale.set( sc, sc, sc )

        @creatureMesh.matrixAutoUpdate = false
        @creatureMesh.updateMatrix()

        loader = new THREE.GeometryLoader()
        loader.addEventListener( 'load', @initWings)
        loader.load("sophie/wing.js")

        @

    initWings : (event) =>
            
        geometry = event.content
        geometry.computeTangents()

        mat = geometry.materials[0]
        mat.reflectivity = 1
        mat.morphTargets = true

        morphTargetsFake = [{name:"fake",vertices:geometry.vertices}]
        geometry.morphTargets = morphTargetsFake

        @wingMesh = new THREE.Mesh( geometry, mat )
        @creatureMesh.add @wingMesh

        @wingMesh2 = new THREE.Mesh( geometry, mat )
        @wingMesh2.position.x -= 20
        @creatureMesh.add @wingMesh2

        @scene.add @creatureMesh 

        #// sun is child of creature, this way shadows are always right
        @creatureMesh.add(@sunLight)

        tween = new TWEEN.Tween(@creatureMesh.position).to(new THREE.Vector3(0,-130,0), 5000)
        tween.easing TWEEN.Easing.Cubic.InOut
        tween.onUpdate => @creatureMesh.updateMatrix()
        tween.onComplete => 
            @creatureMesh.playAnimation("idle",@animFPS)
            @currentAnimation = "idle"
            

        tween.start()

        @animate()

        @
        
    initSky : ->
    
        path = "textures/cube/forest/"
        format = '.jpg';
        urls = [
                path + 'posx' + format, path + 'negx' + format,
                path + 'posy' + format, path + 'negy' + format,
                path + 'posz' + format, path + 'negz' + format
            ]

        @skyCubeTexture = THREE.ImageUtils.loadTextureCube( urls )
        @skyCubeTexture.format = THREE.RGBFormat

        geom = new THREE.CubeGeometry( 3000, 3000, 3000 )

        if @params.animated
            geom.morphTargets[0] = {name:"fake",vertices:geom.vertices}

        @skyCube = new THREE.Mesh( geom, @getCubeMaterial() )
        @skyCube.name = "skyCube"
        @scene.add @skyCube 
        @

    initRenderPasses :->
    
        # RENDER PASS
        @renderPass = new THREE.RenderPass( @scene, @camera, null,false,false )

        # BLUR
        bluriness = 1
        @hblur = new THREE.ShaderPass THREE.ShaderExtras[ "horizontalTiltShift" ]
        @hblur.uniforms[ 'h' ].value = bluriness / @SCREEN_WIDTH
        @hblur.renderToScreen = false
        
        @vblur = new THREE.ShaderPass THREE.ShaderExtras[ "verticalTiltShift" ]
        @vblur.uniforms[ 'v' ].value = bluriness / @SCREEN_HEIGHT
        @vblur.renderToScreen = false

        @hblur.uniforms[ 'r' ].value = @vblur.uniforms[ 'r' ].value = 0.5

        # COLOR CORRECTION
        @colorCorr = new THREE.ShaderPass THREE.ShaderExtras[ "colorCorrection" ]
        @colorCorr.uniforms['powRGB'].value = new THREE.Vector3( 2, 2, 2 )
        @colorCorr.uniforms['mulRGB'].value = new THREE.Vector3( 1, 1, 1 )
        @colorCorr.renderToScreen = false

        # FXAA
        @fxaa = new THREE.ShaderPass THREE.ShaderExtras[ "fxaa" ]
        @fxaa.uniforms['resolution'].value = new THREE.Vector2( 1 / @SCREEN_WIDTH, 1 / @SCREEN_HEIGHT )
        @fxaa.renderToScreen = false
        #fxaa.clear = true;

        # BLEACH
        @bleach = new THREE.ShaderPass THREE.ShaderExtras["bleachbypass"]
        @bleach.renderToScreen = false

        # BLOOM
        @bloom = new THREE.BloomPass @params.bloomIntensity 
        @bloom.renderToScreen = false
        #bloom.clear = true;

        # FILM
        @film = new THREE.FilmPass( 0.35, 0.95, @SCREEN_HEIGHT * 2, false )
        @film.uniforms['sCount'].value = @SCREEN_HEIGHT * 2
        @film.uniforms['sIntensity'].value = @params.filmEffectScanlinesIntensity
        @film.uniforms['nIntensity'].value = @params.filmEffectNoiseIntensity
        
        @film.renderToScreen = false

        @renderToScreenPass = new THREE.ShaderPass THREE.ShaderExtras[ "screen" ]
        @

    initComposer :(event) ->
    
        # RENDER TARGET

        if @params.enableGodRays
            @renderTarget = @postprocessing.rtTextureColors
        else
            @renderTargetParameters = minFilter: THREE.LinearFilter, magFilter: THREE.LinearFilter, format: THREE.RGBFormat
            @renderTarget = new THREE.WebGLRenderTarget( @SCREEN_WIDTH, @SCREEN_HEIGHT, @renderTargetParameters )

        @composer = new THREE.EffectComposer( @renderer, @renderTarget )
        @composer.addPass( @renderPass )

        lastEffect = false

        @composer.addPass( @bloom ) if @params.enableBloom?
        

        if @params.enableFXAA
            @composer.addPass @fxaa
            @fxaa.renderToScreen = false
            lastEffect = @fxaa
        

        if @params.enableFilmEffect
            @composer.addPass @film 
            @film.renderToScreen = false
            lastEffect = @film

        #composer.addPass( colorCorr );
        #composer.addPass( bleach );
        #composer.addPass( hblur );
        #composer.addPass( vblur );

        if !lastEffect
            @renderToScreenPass.renderToScreen = !@params.enableGodRays
            @composer.addPass @renderToScreenPass
        else
            lastEffect.renderToScreen = !@params.enableGodRays
        
        @

    getCubeMaterial :->

        cubeShader = THREE.ShaderUtils.lib[ "cube" ]
        cubeShader.uniforms[ "tCube" ].value = @skyCubeTexture

        material = new THREE.ShaderMaterial
            fragmentShader: cubeShader.fragmentShader,
            vertexShader: cubeShader.vertexShader,
            uniforms: cubeShader.uniforms,
            depthWrite: false,
            side: THREE.BackSide
        
        material
    
    getFairyMaterial : =>
    
        ambient = 0x505050
        diffuse = 0xbbbbbb
        specular = 0x111111
        shininess = 0.1

        shader = THREE.ShaderUtils.lib[ "normal" ]
        @creatureShaderUniforms = THREE.UniformsUtils.clone( shader.uniforms )

        # diffuse
        @creatureShaderUniforms[ "tDiffuse" ].value = THREE.ImageUtils.loadTexture "sophie/texturemapfairy.jpg" 
        @creatureShaderUniforms[ "enableDiffuse" ].value = true

        # specular
        @creatureShaderUniforms[ "tSpecular" ].value = THREE.ImageUtils.loadTexture "sophie/specularfairy.jpg"

        # ambient occlusion
        @creatureShaderUniforms[ "tAO" ].value = THREE.ImageUtils.loadTexture "sophie/ao.png"

        # normal map
        @creatureShaderUniforms[ "tNormal" ].value = THREE.ImageUtils.loadTexture "sophie/normal-tangent-last.jpg"
        @onCreatureShaderChange()

        # reflection map
        @creatureShaderUniforms[ "tCube" ].value = @skyCubeTexture


        @creatureShaderUniforms[ "uDiffuseColor" ].value.setHex diffuse
        @creatureShaderUniforms[ "uSpecularColor" ].value.setHex specular
        @creatureShaderUniforms[ "uAmbientColor" ].value.setHex ambient
        @creatureShaderUniforms[ "uShininess" ].value = shininess

        @creatureShaderUniforms[ "wrapRGB" ].value.set( 0.575, 0.5, 0.5 )

        material = new THREE.ShaderMaterial
            fragmentShader: shader.fragmentShader,
            vertexShader: shader.vertexShader, 
            uniforms: @creatureShaderUniforms, 
            lights: true, 
            morphTargets: @params.animated

        material.wrapAround = true;

        material


     onDocumentMouseClick : ( event ) =>

        console.log @mouseOverCreature
     
        if @mouseOverCreature and @params.animated and @currentAnimation == "idle"
            @creatureMesh.playAnimation("interact", @animFPS)
            @currentAnimation = "interact"


    onDocumentMouseMove : ( event ) =>

        console.log 'mousemove'

        return

        @mouseX = event.clientX - @windowHalfX
        @mouseY = event.clientY - @windowHalfY

        @pickMouse.x = ( event.clientX / window.innerWidth ) * 2 - 1
        @pickMouse.y = - ( event.clientY / window.innerHeight ) * 2 + 1

    onDocumentTouchStart : ( event ) ->

        if event.touches.length == 1

            event.preventDefault()

            mouseX = event.touches[ 0 ].pageX - @windowHalfX
            mouseY = event.touches[ 0 ].pageY - @windowHalfY

    onDocumentTouchMove : ( event ) ->

        if event.touches.length == 1

            event.preventDefault()

            @mouseX = event.touches[ 0 ].pageX - @windowHalfX
            @mouseY = event.touches[ 0 ].pageY - @windowHalfY

    onWindowResize : ( event ) ->

        @SCREEN_WIDTH = window.innerWidth
        @SCREEN_HEIGHT = window.innerHeight

        @windowHalfX = @SCREEN_WIDTH >> 1
        @windowHalfY = @SCREEN_HEIGHT >> 1

        @renderer.setSize( @SCREEN_WIDTH, @SCREEN_HEIGHT )

        @camera.aspect = @postprocessing.camera.aspect = @SCREEN_WIDTH / @SCREEN_HEIGHT
        @camera.updateProjectionMatrix()
        @postprocessing.camera.updateProjectionMatrix()
        @fxaa.uniforms['resolution'].value = new THREE.Vector2( 1 / @SCREEN_WIDTH, 1 / @SCREEN_HEIGHT )
        @film.uniforms['sCount'].value = @SCREEN_HEIGHT * 2


        @initPostprocessingRenderTargets()
        @initComposer()
        @
    
    initPostprocessing :-> 
    
        @postprocessing.scene = new THREE.Scene()

        @postprocessing.camera = new THREE.OrthographicCamera( @SCREEN_WIDTH / - 2, @SCREEN_WIDTH / 2, @SCREEN_HEIGHT / 2, @SCREEN_HEIGHT / - 2, -10000, 10000 )
        @postprocessing.camera.position.z = 1000

        @postprocessing.scene.add @postprocessing.camera

        @initPostprocessingRenderTargets()

        # god-ray shaders
        godraysGenShader = THREE.ShaderGodRays[ "godrays_generate" ]
        @postprocessing.godrayGenUniforms = THREE.UniformsUtils.clone( godraysGenShader.uniforms )
        @postprocessing.materialGodraysGenerate = new THREE.ShaderMaterial
            uniforms: @postprocessing.godrayGenUniforms,
            vertexShader: godraysGenShader.vertexShader,
            fragmentShader: godraysGenShader.fragmentShader

        godraysCombineShader = THREE.ShaderGodRays[ "godrays_combine" ]
        @postprocessing.godrayCombineUniforms = THREE.UniformsUtils.clone( godraysCombineShader.uniforms )
        @postprocessing.materialGodraysCombine = new THREE.ShaderMaterial
            uniforms: @postprocessing.godrayCombineUniforms,
            vertexShader: godraysCombineShader.vertexShader,
            fragmentShader: godraysCombineShader.fragmentShader

        @postprocessing.quad = new THREE.Mesh( new THREE.PlaneGeometry( @SCREEN_WIDTH, @SCREEN_HEIGHT ), @postprocessing.materialGodraysGenerate )
        #postprocessing.quad.position.z = -9900;
        @postprocessing.scene.add @postprocessing.quad

        @
    
    initPostprocessingRenderTargets :->
    
        pars = 
            minFilter: THREE.LinearFilter, 
            magFilter: THREE.LinearFilter, 
            format: THREE.RGBFormat

        @postprocessing.rtTextureColors = new THREE.WebGLRenderTarget( @SCREEN_WIDTH, @SCREEN_HEIGHT, pars )

        # Aggressive downsize god-ray ping-pong render targets to minimize cost
        w = @SCREEN_WIDTH / 4.0
        h = @SCREEN_HEIGHT / 4.0

        # Switching the depth formats to luminance from rgb doesn't seem to work. I didn't
        # investigate further for now.
        #pars.format = THREE.LuminanceFormat;

        # I would have this quarter size and use it as one of the ping-pong render
        # targets but the aliasing causes some temporal flickering
        @postprocessing.rtTextureDepth = new THREE.WebGLRenderTarget( w, h, pars )
        @postprocessing.rtTextureGodRays1 = new THREE.WebGLRenderTarget( w, h, pars )
        @postprocessing.rtTextureGodRays2 = new THREE.WebGLRenderTarget( w, h, pars )

        @

    animate :=>

        window.requestAnimationFrame( @animate )
        TWEEN.update()
        delta = @clock.getDelta()

        if @creatureMesh and @params.animated
        
            @creatureMesh.updateAnimation( delta * 200 )
            currKey = @creatureMesh.currentKeyframe

            if !@currentAnimation
                @creatureMesh.playAnimation("fly",@animFPS)
                @currentAnimation = "fly"
            
            if @currentAnimation == "interact"
                if @lastKeyFrame > currKey
                    @creatureMesh.playAnimation("idle",@animFPS)
                    @currentAnimation = "idle"

            @lastKeyFrame = currKey;

        @render()
        @stats.update()
    

    render :=>
    
        time = Date.now() / 4000

        # animate sun
        @sunLight.position.x = 50 * Math.cos( time * 5 ) 
        @sunLight.position.y = 50 * Math.sin( time * 3 ) + 200
        @sunLight.updateMatrix()

        # animate wings
        if @wingMesh and @wingMesh2
            @wingAnim++
            if @wingAnim % 4 == 0
                @wingMesh.rotation.y = (Math.PI/4) + (Math.random()*.1)
                @wingMesh2.rotation.y = -( Math.PI/4 ) - (Math.random()*.1)
            
            else
                @wingMesh.rotation.y = Math.random() * .1
                @wingMesh2.rotation.y = -( Math.random() * .1 )


        # animate dandelions
        for i in [0..@dandelionMeshes.length - 1]
        
            dandelion = @dandelionMeshes[i]
            
            distance = dandelion.position.distanceTo(@scene.position)

            if !dandelion.CCW
                dandelion.position.x += Math.cos(time) / dandelion.speed
                dandelion.position.y += Math.sin(time) / dandelion.speed
            else
                dandelion.position.x -= Math.cos(time) / dandelion.speed
                dandelion.position.y -= Math.sin(time) / dandelion.speed
            
            dandelion.lookAt(@camera.position)
            dandelion.rotation.z = (Math.PI/4) * Math.sin(time * dandelion.speed)
            dandelion.updateMatrix()

        # move camera
        @camera.position.x += ( @mouseX - @camera.position.x ) * 0.016
        @camera.position.y += ( - ( @mouseY ) - @camera.position.y ) * 0.016

        # limit camera
        @camera.position.x = Math.max(-200,Math.min(200,@camera.position.x))
        @camera.position.y = Math.max(-60,Math.min(60,@camera.position.y))

        @camera.lookAt @scene.position

        # picking
        vector = new THREE.Vector3( @pickMouse.x, @pickMouse.y, 1 )
        @projector.unprojectVector( vector, @camera )

        ray = new THREE.Ray( @camera.position, vector.subSelf( @camera.position ).normalize() )
        intersects = ray.intersectObjects @scene.children
        over = false

        for i in [0..intersects.length - 1]
            if intersects[i].object == @creatureMesh
                over = true
        
        @mouseOverCreature = over

        # godrays adds 4 render passes (a lot)
        if @params.enableGodRays
        
            @postprocessing.godrayCombineUniforms.fGodRayIntensity.value = @params.godRaysIntensity
            @postprocessing.godrayCombineUniforms.vRayColors.value.x  = @params.godRaysColor[0]/255
            @postprocessing.godrayCombineUniforms.vRayColors.value.y  = @params.godRaysColor[1]/255
            @postprocessing.godrayCombineUniforms.vRayColors.value.z  = @params.godRaysColor[2]/255

            # Find the screenspace position of the sun
            @screenSpacePosition.copy( @sunLight.position )
            @projector.projectVector( @screenSpacePosition, @camera )
            @screenSpacePosition.x = ( @screenSpacePosition.x + 1 ) / 2
            @screenSpacePosition.y = ( @screenSpacePosition.y + 1 ) / 2

            #Give it to the god-ray shader
            @postprocessing.godrayGenUniforms[ "vSunPositionScreenSpace" ].value.x = @screenSpacePosition.x
            @postprocessing.godrayGenUniforms[ "vSunPositionScreenSpace" ].value.y = @screenSpacePosition.y


            # Clear colors and depths, will clear to sky color
            @renderer.clearTarget( @postprocessing.rtTextureColors, true, true, false )
            #renderer.clearTarget( postprocessing.rtTextureDepth, true, true, false )


            # -- Draw scene objects --
            # Colors
            @scene.overrideMaterial = null
            @composer.render(0.1)
            #renderer.render( scene, camera, postprocessing.rtTextureColors );


            # Depth
            @scene.overrideMaterial = @materialDepth
            @renderer.render( @scene, @camera, @postprocessing.rtTextureDepth, true )

            # -- Render god-rays --
            # Maximum length of god-rays (in texture space [0,1]X[0,1])
            filterLen = 1.0

            # Samples taken by filter
            TAPS_PER_PASS = 6.0

            # Pass order could equivalently be 3,2,1 (instead of 1,2,3), which
            # would start with a small filter support and grow to large. however
            # the large-to-small order produces less objectionable aliasing artifacts that
            # appear as a glimmer along the length of the beams

            # pass 1 - render into first ping-pong target
            pass = 1.0
            stepLen = filterLen * Math.pow( TAPS_PER_PASS, -pass )
            @postprocessing.godrayGenUniforms[ "fStepSize" ].value = stepLen
            @postprocessing.godrayGenUniforms[ "tInput" ].value = @postprocessing.rtTextureDepth
            @postprocessing.scene.overrideMaterial = @postprocessing.materialGodraysGenerate
            @renderer.render( @postprocessing.scene, @postprocessing.camera, @postprocessing.rtTextureGodRays2 )

            # pass 2 - render into second ping-pong target
            pass = 2.0
            stepLen = filterLen * Math.pow( TAPS_PER_PASS, -pass )
            @postprocessing.godrayGenUniforms[ "fStepSize" ].value = stepLen
            @postprocessing.godrayGenUniforms[ "tInput" ].value = @postprocessing.rtTextureGodRays2
            @renderer.render( @postprocessing.scene, @postprocessing.camera, @postprocessing.rtTextureGodRays1  )

            # pass 3 - 1st RT
            pass = 3.0;
            stepLen = filterLen * Math.pow( TAPS_PER_PASS, -pass )
            @postprocessing.godrayGenUniforms[ "fStepSize" ].value = stepLen
            @postprocessing.godrayGenUniforms[ "tInput" ].value = @postprocessing.rtTextureGodRays1
            @renderer.render( @postprocessing.scene, @postprocessing.camera , @postprocessing.rtTextureGodRays2  )

            # final pass - composite god-rays onto colors
            @postprocessing.godrayCombineUniforms["tColors"].value = @postprocessing.rtTextureColors
            @postprocessing.godrayCombineUniforms["tGodRays"].value = @postprocessing.rtTextureGodRays2
            @postprocessing.scene.overrideMaterial = @postprocessing.materialGodraysCombine
            @renderer.render( @postprocessing.scene, @postprocessing.camera )
            @postprocessing.scene.overrideMaterial = null;

        else 
        
            @renderer.clear()
            @composer.render(0.1)
    @