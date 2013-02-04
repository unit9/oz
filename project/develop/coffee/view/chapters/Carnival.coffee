class Carnival extends Base3DChapter

    settings: null
    loadedScene : null
    mouseInteraction : null
    hotspotManager : null
    materialManager : null
    
    enableRender : false
    debugPaths: null
    
    mouseDownObjects : null
    mouseUpObjects : null
    mouseOverObjects : null
    lastMouseX : 0
    lastMouseY : 0
    mouseDownPoint : null
    mouseUpPoint : null

    isGoingToInteractive : false   
    currentView : null
    currentCutout : null

    # dust system 
    dustSystems: null
    dustSystemMinX: -300
    dustSystemMinY: 0
    dustSystemMinZ: -200
    dustSystemMaxX: 80
    dustSystemMaxY: 100
    dustSystemMaxZ: 80

    windGenerator : null
    cutoutsDynamicTextures : null

    animatedSprites : null

    # audio
    audiolistener: null
    isInIntro : true
    nearPoint : null
    showTime : -1
    pickVector : null
    pickRay : null
    sceneDescendants : null
    minIndex : 0
    maxIndex : 75    
    dandelionsSettings : null
    dustSettings : null
    initialOptimization : false

    init:->
        @mouseDownPoint = new THREE.Vector2()
        @mouseUpPoint = new THREE.Vector2()
        @dandelionsSettings = []
        @dustSettings = []

        # Add Instructions Over
        @addChapterInstructions()

        IFLModelManager.getInstance().cacheTextures(@oz().appView.enablePrefetching)
        IFLModelManager.getInstance().prefetchEnabled = @oz().appView.enablePrefetching

        @animatedSprites = []
        @dustSystems = []
        @mouseDownObjects = []
        @mouseUpObjects = []
        @mouseOverObjects = []
        @pickVector = new THREE.Vector3
        @pickRay = new THREE.Ray

        super()
       

        @renderer.gammaInput = false
        @renderer.gammaOutput = false
        @renderer.sortObjects = false
        @renderer.shadowMapEnabled = false
        @renderer.shadowMapSoft = false

        @camera.position.x = 100;
        @camera.position.y = 100;
        @camera.position.z = 100;
        @camera.fov = 35
        @camera.near = 1
        @camera.far = 5000
        @camera.target =  new THREE.Vector3( 0, 0, 0 )

        @mouseInteraction = new IFLCameraPathInteraction @camera
        @mouseInteraction.maxIndex = 170
        @mouseInteraction.currentIndex = 0
        @mouseInteraction.mouseEnabled = false

        if SoundController.active
            @audiolistener = new THREE.AudioListenerObject @camera
            @audiolistener.position.set 0, 150, 400
            @scene.add @audiolistener

        # @controls = new THREE.OrbitControls(@camera,@oz().appView.wrapper.el)

        if @oz().appView.debugMode
            @controls = new THREE.FlyControls(@camera,@oz().appView.wrapper.el)
            @controls.movementSpeed = 20
            @controls.rollSpeed = 0.005*10
            @controls.enabled = false
            @controls.dragToLook = true
            @camera.useQuaternion = false

        @materialManager = new IFLMaterialManager
        @materialManager.forcePNGTextures = !@oz().appView.ddsSupported

        @hotspotManager = new IFLHotspotManager

        @params.cameraFOV = @camera.fov
        
        @params.fogcolor = "#2c2016"
        @scene.fog.far = 1065
        @scene.fog.near = 0
        @scene.fog.color.copy @stringToColor(@params.fogcolor)

        @params.colorCorrectionPow = "#2e3359"
        @params.colorCorrectionPowM = 1.4
        @params.colorCorrectionMul = "#edc9a4"
        @params.colorCorrectionMulM = 1.5
        @params.colorCorrectionSaturation = -50
        @params.colorCorrectionSaturationColors = "#524b4b"

        @dofpost.focus = @dofpost.bokeh_uniforms[ "focus" ].value = 0.97
        @dofpost.aperture = @dofpost.bokeh_uniforms[ "aperture" ].value = 0.009
        @dofpost.maxblur = @dofpost.bokeh_uniforms[ "maxblur" ].value = 0.007
        @dofpost.cameranear = 0.001
        @dofpost.camerafar = 956 
        

        @params.bloomPower = @effectBloom.screenUniforms.opacity.value = 0.75
        @effectBloom.enabled = true


        
        @debugPaths = new THREE.Object3D    
        @windGenerator = new IFLWindGenerator()
        @windGenerator.enabled = if @oz().appView.displayQuality != "low" then true else false

        @colorCorrection.uniforms.vignetteOffset.value = 1
        @colorCorrection.uniforms.vignetteDarkness.value = 1.3        

        if @oz().appView.debugMode
            @initGUI()
        @onColorCorrectionChange()
       

        @autoPerformance.steps.push 
            name : "Wind"
            enabled : @windGenerator.enabled
            priority : 50
            disableFunc : @onWindEnabledChange

     

        @onResize()

        # @colorCorrection.uniforms["tOverlay"].value = THREE.ImageUtils.loadCompressedTexture( "/models/textures/drops.dds" )

        @lastMouseY = @mouseY + @APP_HALF_Y
        @lastMouseX = @mouseX + @APP_HALF_X

       # @addChild(new RainDrops)

        @



    render:=>
        super
        $.ajax( {url : "/models/s001_settings.json", dataType: 'json', success : @onSettingsLoaded });

    onSettingsLoaded:(settings)=>
        @settings = settings

        # @cameraPositionPoints = []
        for i in [0...settings.positions.length] by 3
            @mouseInteraction.cameraPositionPoints.push(new THREE.Vector3(settings.positions[i],settings.positions[i+1],settings.positions[i+2]))

        # @cameraLookatPoints = []
        for i in [0...settings.lookAt.length] by 3
            @mouseInteraction.cameraLookatPoints.push(new THREE.Vector3(settings.lookAt[i],settings.lookAt[i+1],settings.lookAt[i+2]))
        

        # @createDebugPath(@mouseInteraction.cameraPositionPoints)
        # @createDebugPath(@mouseInteraction.cameraLookatPoints)

        settings.renderer = @renderer
        settings.onProgress = @onTextureProgress
        settings.onComplete = @onTextureComplete
        settings.textureQuality = if @oz().appView.ddsSupported then @oz().appView.textureQuality else "low"

        @materialManager.init(settings)
        @materialManager.load()
        IFLModelManager.getInstance().load(@settings.pickables, @materialManager.instanceMaterial, @settings.modelURL, @onSceneLoaded, @onSceneProgress)


        # @initDustSystems()
        @

    sceneLoadedPerc : 0
    sceneLoaded : false
    textureLoadedPerc : 0
    textureLoaded : false
    loadingDone : false

    onTextureProgress:(percent) =>
        @textureLoadedPerc = percent
        @advanceLoading()
        @

    onTextureComplete:() =>
        @textureLoaded = true
        @advanceLoading()
        @

    onSceneProgress : (loaded,total) => 
        # l : total = x : 100
        @sceneLoadedPerc = loaded / total
        @advanceLoading()
        @
    onSceneLoaded:(loader,loadedScene) =>
        # console.log "Carnival world loaded"
        SoundController.send 'load_scene_1', ['load_scene_5','scene_carnival_start']
        @sceneLoaded = true
        @loader = loader
        @advanceLoading()
        @

    advanceLoading : ()=>
        total = @sceneLoadedPerc * 0.5 + @textureLoadedPerc * 0.5
        @onWorldProgress(total)

        if @textureLoaded == true && @sceneLoaded == true && !@loadingDone
            @loadingDone = true
            @instanceWorld()
            @onWorldProgress(1)
            @onWorldLoaded()
        return

    show:()=>
        # console.log "Carnival Show"
        # @instanceWorld()
        @showTime = Date.now()
        super
    
    instanceWorld:=>
        # console.log "Carnival instance world"
        @loadedScene = @loader.createModel(true)
        @createBirdFlocks()
        @initOrganCharacters()


        @cutoutsDynamicTextures = []
        desc = @loadedScene.getDescendants()
        for elem in desc
            # elem.position.set(0,0,0)
            # elem.rotation.set(0,0,0)
            # elem.scale.set(1,1,1)

            if elem.material?.uniforms?.tWindForce? && elem.material.vertexColors == THREE.VertexColors
                elem.material.uniforms.tWindForce.value = @windGenerator.noiseMap
                elem.material.uniforms.windDirection.value.copy @windGenerator.windDirection

            if elem.name == "characterCutouts_spec_right" || elem.name == "characterCutouts_spec_middle" || elem.name == "characterCutouts_spec_left"
                @cutoutsDynamicTextures.push elem

            if elem.name.toLowerCase().indexOf("signpost_simple") != -1
                elem.position.x = 20
                elem.position.z = -28

            # if elem.name.toLowerCase().indexOf("terrain") != -1
            #      @scene.add elem

            #Frustum Hack
            foundObj = null
            if @settings.customBounds?
                for cfm of @settings.customBounds
                    if elem.name.toLowerCase().indexOf(cfm) != -1
                       foundObj = @settings.customBounds[cfm]
                       break

                if foundObj?
                    customFrustumPos = foundObj.position
                    customFrustumRad = foundObj.radius
                    elem.customFrustumMatrix = new THREE.Matrix4
                    elem.customFrustumMatrix.setPosition(new THREE.Vector3(customFrustumPos[0],customFrustumPos[1],customFrustumPos[2]))
                    elem.geometry.boundingSphere.radius = customFrustumRad

            if @oz().appView.displayQuality != "hi"
                blacklist = ["grass","branch"]
                isBlacklisted = false
                for blacklisted in blacklist
                    if elem.name.toLowerCase().indexOf(blacklisted.toLowerCase()) != -1
                        isBlacklisted = true
                        break

                if !isBlacklisted
                    @scene.add elem
            else
                @scene.add elem


        # @scene.add @skyCube
        # @scene.add loadedScene
        @initSun()
        if @oz().appView.showInterface
            @hotspotManager.init(@settings,@scene,@materialManager,@oz().localeTexture,@camera)
        @initDustSystems()

        @onResize()

        # @loader.dispose();
        # @loader = null

        @setupIntroParams()

        @sceneDescendants = @scene.getDescendants()

        @pickableObjects = []
        for object in @sceneDescendants when object.pickable == true
            @pickableObjects.push object

        @enableRender = true




        @doInitialOptimizationPass()
        return null


    doInitialOptimizationPass:->
        @initialOptimization = true
        @mouseInteraction.currentIndex = 120
        prevCamerafov = @camera.fov
        @camera.fov = 120
        @camera.updateProjectionMatrix()
        @onEnterFrame()
        
        # @enableRender = false

        @camera.fov = prevCamerafov
        @camera.updateProjectionMatrix()
        @mouseInteraction.currentIndex = 0
        @initialOptimization = false
        # @renderer.clearTarget(@renderTarget,true,true,true)
        # if @composer.enabled        
        #     @renderer.clearTarget(@composer.renderTarget1,true,true,true)
        #     @renderer.clearTarget(@composer.renderTarget2,true,true,true)
        # @renderer.clear(true,true,true)
        @onEnterFrame()
        return null

    setupIntroParams:->
        @introParams = [
                {
                    object : @camera
                    param : "fov"
                    min : 25
                    max : @camera.fov
                }

                
                # yForce :
                #     object : @mouseInteraction
                #     param : "forcePathYLookAt"
                #     min : -20
                #     max : @mouseInteraction.forcePathYLookAt                
                # yForcePos :
                #     object : @mouseInteraction
                #     param : "forcePathYPosition"
                #     min : -20
                #     max : @mouseInteraction.forcePathYPosition


                {
                    object : @mouseInteraction
                    param : "maxXLookDeviation"
                    min : 30
                    max : @mouseInteraction.maxXLookDeviation
                }

                {
                    object : @mouseInteraction
                    param : "maxYLookDeviation"
                    min : 10
                    max : @mouseInteraction.maxYLookDeviation
                }

                # cameraSpeed :
                #     object : @mouseInteraction
                #     param : "maxspeed"
                #     min : 0.90
                #     max : @mouseInteraction.maxspeed

                {
                    object : @scene.fog
                    param : "near"
                    min : 237
                    max : @scene.fog.near    
                }        

                {
                    object : @scene.fog
                    param : "far"
                    min : 1065
                    max : @scene.fog.far
                }

                {
                    type : "color"
                    object : @params
                    param : "fogcolor"
                    min : "#252c16"
                    max : @params.fogcolor
                }

                {
                    object : @colorCorrection.uniforms.vignetteOffset
                    param : "value"
                    min : 0
                    max : @colorCorrection.uniforms.vignetteOffset.value
                }
                
                {
                    object : @effectBloom.screenUniforms.opacity
                    param : "value"
                    min : 0.77
                    max : @effectBloom.screenUniforms.opacity.value
                }

                {
                    type : "color"
                    object : @params
                    param : "colorCorrectionPow"
                    min : "#1d2f50"
                    max : @params.colorCorrectionPow
                }


                {
                    object :  @params
                    param : "colorCorrectionPowM"
                    min : 1.4
                    max : @params.colorCorrectionPowM
                }


                {
                    type : "color"
                    object : @params
                    param : "colorCorrectionMul"
                    min : "#d2a669"
                    max : @params.colorCorrectionMul
                }

                {
                    object :  @params
                    param : "colorCorrectionMulM"
                    min : 2
                    max : @params.colorCorrectionMulM                
                }

                {
                    type : "color"
                    object : @params
                    param : "colorCorrectionSaturationColors"
                    min : "#9b9fa0"
                    max : @params.colorCorrectionSaturationColors
                }

                {
                    object :  @params
                    param : "colorCorrectionSaturation"
                    min : -51
                    max : @params.colorCorrectionSaturation
                }
        ]


    initOrganCharacters:->
        shader = new IFLBasicShader()
        params = {}
        params.fragmentShader   = shader.fragmentShader
        params.vertexShader     = shader.vertexShader
        params.uniforms         = shader.uniforms
        # shader.uniforms["offsetRepeat"].value = new THREE.Vector4(0,0,1,0.5)

        mat  = new THREE.ShaderMaterial(params)
        mat.map = shader.uniforms["map"].value = @materialManager.getPreloadedTexture("organ_characters.dds") #THREE.ImageUtils.loadTexture("/models/textures/s001_b/preload_jpg/organ_characters.png")
        mat.map.wrapS = mat.map.wrapT = THREE.RepeatWrapping
        shader.uniforms["diffuseMultiplier"].value = .5

        mat.transparent = true
        mat.side = THREE.DoubleSide
        mat.time = 0
        mat.spritenum = 0
        mat.totalframes = 2
        mat.spritex = 1
        mat.spritey = 2
        mat.frametime = 1

        @materialManager.matLib.push mat
        # @materialManager.texLib.push mat.map

        geom = new THREE.PlaneGeometry(12,12,1,1)
        for uv in geom.faceVertexUvs[0][0]
            uv.v = 1-uv.v       
        plane = new THREE.Mesh(geom,mat)
        plane.name = "organ_characters"
        plane.position.set -8.5,22,-75
        plane.rotation.y = -0.37

        @animatedSprites.push plane

        @scene.add plane  
        return null
    
    createBirdFlocks:()->
        geom = new THREE.PlaneGeometry(10,10,1,1)
        
        for uv in geom.faceVertexUvs[0][0]
            uv.v = 1-uv.v

        tex = @materialManager.getPreloadedTexture("bird.dds")#THREE.ImageUtils.loadTexture("/models/textures/s001_b/preload_jpg/bird.png")
        # @materialManager.texLib.push tex

        shader = new IFLBasicShader()
        params = {}
        params.fragmentShader   = shader.fragmentShader
        params.vertexShader     = shader.vertexShader
        params.uniforms         = shader.uniforms

        num = if @oz().appView.displayQuality != "low" then 50 else 25

        for i in [0...num] by 1
            mat  = new THREE.ShaderMaterial(params)
            mat.map = shader.uniforms["map"].value = tex
            mat.transparent = true
            mat.time = 0
            mat.spritenum = Math.round(@randRange(0,8))
            mat.totalframes = 8
            mat.spritex = 4
            mat.spritey = 2
            mat.frametime = 1/15

            @materialManager.matLib.push mat

            plane = new THREE.Mesh(geom,mat)
            plane.position.set(@randRange(-1000,1000),@randRange(100,350),@randRange(-1000,-400))
            plane.originalPosition = plane.position.clone()
            plane.name = "bird_#{i}"
            plane.isBird = true
            @scene.add plane


            @animatedSprites.push plane
        @      

    initDustSystems:()->

        for i in [0...5] by 1
            shader = new IFLWindyParticlesShader()
            params = {}
            params.fragmentShader   = shader.fragmentShader
            params.vertexShader     = shader.vertexShader
            params.uniforms         = shader.uniforms
            params.attributes       = { speed: { type: 'f', value: [] } }

            mat  = new THREE.ShaderMaterial(params)
            mat.map = shader.uniforms["map"].value = @materialManager.getPreloadedTexture("/models/textures/particles/dust#{i}.dds")
            mat.size = shader.uniforms["size"].value = Math.random()
            mat.scale = shader.uniforms["scale"].value = @APP_HEIGHT / 2
            mat.transparent = true
            mat.sizeAttenuation = true
            mat.blending = THREE.AdditiveBlending

            @materialManager.matLib.push mat
            @materialManager.texLib.push mat.map

            shader.uniforms["tWindForce"].value = @windGenerator.noiseMap


            geom = new THREE.Geometry()
            geom.vertices = []


            num = if @oz().appView.displayQuality != "low" then 300 else 150
            
            for k in [0...num] by 1

                setting = {}

                vert = new THREE.Vector3
                vert.x = setting.startX = @randRange(@dustSystemMinX,@dustSystemMaxX)
                vert.y = setting.startY = @randRange(@dustSystemMinY,@dustSystemMaxY)
                vert.z = setting.startZ = @randRange(@dustSystemMinZ,@dustSystemMaxZ)

                setting.speed =  params.attributes.speed.value[k] = 1 + Math.random() * 10
                
                setting.sinX = Math.random()
                setting.sinXR = if Math.random() < 0.5 then 1 else -1
                setting.sinY = Math.random()
                setting.sinYR = if Math.random() < 0.5 then 1 else -1
                setting.sinZ = Math.random()
                setting.sinZR = if Math.random() < 0.5 then 1 else -1

                setting.rangeX = Math.random() * 5
                setting.rangeY = Math.random() * 5
                setting.rangeZ = Math.random() * 5

                setting.vert = vert
                geom.vertices.push vert
                @dustSettings.push setting



            particlesystem = new THREE.ParticleSystem( geom , mat )
            @dustSystems.push particlesystem
            @scene.add particlesystem


        #dandelions


        dandelionShader = new IFLDandelionParticlesShader()

        params = {}
        params.fragmentShader   = dandelionShader.fragmentShader
        params.vertexShader     = dandelionShader.vertexShader
        params.uniforms         = dandelionShader.uniforms
        params.attributes       = { rotation: { type: 'f', value: [] } }

        dandelionMaterial  = new THREE.ShaderMaterial(params)
        dandelionMaterial.map = dandelionShader.uniforms["map"].value = @materialManager.getPreloadedTexture("/models/textures/particles/dandelion.dds")
        dandelionMaterial.size = dandelionShader.uniforms["size"].value = 2
        dandelionMaterial.scale = dandelionShader.uniforms["scale"].value = @APP_HEIGHT / 2
        dandelionMaterial.transparent = true
        dandelionMaterial.sizeAttenuation = true

        @materialManager.matLib.push dandelionMaterial
        @materialManager.texLib.push dandelionMaterial.map        

        dandelionGeometry = new THREE.Geometry()
        dandelionGeometry.vertices = []

        num = if @oz().appView.displayQuality != "low" then 200 else 100

        for k in [0...num] by 1
            setting = {}

            dandelion = new THREE.Vector3
            dandelion.x = setting.startX = @randRange(@dustSystemMinX,@dustSystemMaxX)
            dandelion.y = setting.startY = @randRange(@dustSystemMinY,@dustSystemMaxY)
            dandelion.z = setting.startZ = @randRange(@dustSystemMinZ,@dustSystemMaxZ)
            setting.speed = 0.001 + Math.random() * 0.003
            setting.CCW = Math.random() > 0.5;
            setting.rotation = params.attributes.rotation.value[k] = Math.random() * (Math.PI/4)
            dandelionGeometry.vertices.push dandelion
            @dandelionsSettings.push setting

        @dandelionParticleSystem = new THREE.ParticleSystem( dandelionGeometry , dandelionMaterial )
        @scene.add @dandelionParticleSystem

        @



    initGUI:(settings)->
        super(settings)

        # fresnel = @gui.addFolder("Fresnel Material")
        @gui.add( {value:-2.5}, 'value',-5,20 ).name('Fresnel Power').onChange(@materialManager.changeFresnelPower)
        # @gui.add( {value:1.0}, 'value',0,10 ).name('Normal Scale').onChange(@materialManager.changeNormalScale)
        @gui.add( {value:@windGenerator.enabled}, 'value').name('Enable Wind').onChange(@onWindEnabledChange)

        @gui.add(@mouseInteraction,"constantSpeed").name("Use Constant Speed")
        @gui.add(@mouseInteraction,"maxspeed",0,2).name("Maximum slide speed")
        @gui.add(@mouseInteraction,"maxYLookDeviation",0,100).name("Maximum Y Look")
        @gui.add(@mouseInteraction,"maxXLookDeviation",0,100).name("Maximum X Look")
        @gui.add({value:false},"value").name("Show Camera Paths").onChange @onShowDebugPathChange
        @gui.add(@controls,"enabled").name("Exit Camera Path").onChange (value)=> @camera.useQuaternion = value
        # @gui.add({value:2},"value",0,2).name("Texture Quality").step(1).onChange @onTextureQualityChange
        @   

    onWindEnabledChange:(value)=>

        val = if !value? then false else ( if value? && value == true then true else false )

        @materialManager.vertexColorsEnabled(val)
        @windGenerator.enabled = val
        @loader.geometryAttributeEnabled("color",val)

    onShowDebugPathChange:(value)=>
        if value
            @scene.add @debugPaths
        else
            @scene.remove @debugPaths
        @

    createDebugPath:(arr)->
        root = new THREE.Object3D

        linegeom = new THREE.Geometry
        linerenderable = new THREE.Line(linegeom)
        root.add linerenderable

        
        for point,index in arr
            dMesh = new THREE.Mesh(new THREE.SphereGeometry(.1,3,2), new THREE.MeshBasicMaterial({wireframe:true,color:0xFF0000,lights:false}) )
            dMesh.name = "debugPathNode_#{index}"
            dMesh.position.copy point
            root.add( dMesh );
            linegeom.vertices.push(point)
        
        @debugPaths.add root
        @


    initSun:()->
        mainSprite = @materialManager.getPreloadedTexture( @settings.sun.mainSprite );
        flareSprite = @materialManager.getPreloadedTexture( @settings.sun.flareSprite );

        @materialManager.texLib.push mainSprite
        @materialManager.texLib.push flareSprite
        
        @lensFlare = new THREE.LensFlare( mainSprite, @settings.sun.size , 0.0, THREE.AdditiveBlending, new THREE.Color( 0xFFFFFF ) );
        @lensFlare.position.set(@settings.sun.position[0],@settings.sun.position[1],@settings.sun.position[2])

        for flare in @settings.sun.flares
            @lensFlare.add( flareSprite, flare[0], flare[1], THREE.AdditiveBlending );
        
        for flare in @lensFlare.lensFlares
            flare.originalSize = flare.size

        @lensFlare.customUpdateCallback = ( object ) =>
            vecX = -object.positionScreen.x * 2;
            vecY = -object.positionScreen.y * 2;
            for flare in object.lensFlares
                flare.x = object.positionScreen.x + vecX * flare.distance;
                flare.y = object.positionScreen.y + vecY * flare.distance;
                flare.rotation = 0;
            object.lensFlares[ 2 ].y += 0.025;
            object.lensFlares[ 3 ].rotation = object.positionScreen.x * 0.5 + 45 * Math.PI / 180

        @scene.add @lensFlare

        @   

      


    onEnterFrame : =>
        # console.log "CARNIVAL 1 ENTERFRAME"
        return unless @enableRender
        super
        # 7.94
        @adjustInitialSettings()
        # # 8.05
        @mouseOverObjects = @checkPicking()
        @handlePointer()
        # 7.34
        # INTRO Camera Management
        if !@initialOptimization
            @introCameraManagement()
        # 6.81
        #animated sprites
        @handleAnimatedSprites()
        # 6.06
        @moveBirds()    
        # 3.07
        @hotspotManager.update(@delta)
        # 2.94
        # DANDELIONS
        @moveDandelions()
        # 2.01
        # dust movement
        @moveDust()
        # 0.57
        #mouse interaction
        @handleMultiCamera()

        # 0.53

        @renderer.clear()
        @windGenerator.update(@renderer,@delta)
        @doRender()
        
        if @capturer
            @capturer.capture( @oz().appView.renderCanvas3D )

    handleMultiCamera:->

        # try catch error

        if !@isGoingToInteractive
            if ( (!@controls? || (@controls? && !@controls.enabled)) && @enableMouse )
                @camera.matrixAutoUpdate = false
                @mouseInteraction.update(@delta,@mouseX,@mouseY)
            else
                @camera.matrixAutoUpdate = true
        else
            @camera.matrixAutoUpdate = false

    adjustInitialSettings:->
        if !@windinitialSettings? then @windinitialSettings = 0
        if @windinitialSettings == 2
            @onWindEnabledChange(@windGenerator.enabled)
            @windinitialSettings++
        else
            @windinitialSettings++

        if @showTime != -1
            if Date.now() - @showTime > 300
                @showTime = -1
                @mouseInteraction.mouseEnabled = true        


    colorIntroParam : "color"

    introCameraManagement:->

        # try catch error

        if @mouseInteraction.currentIndex < @maxIndex && !@isGoingToInteractive

            @mouseInteraction.minIndex = @minIndex
            indexNorm = @mouseInteraction.currentIndex + @mouseInteraction.currentProgress

            for obj in @introParams
                # obj = @introParams[prop]
                if obj.type != @colorIntroParam
                    @adjustIntroParam(obj.object,obj.param,obj.min,obj.max,indexNorm,@minIndex,@maxIndex)
                else
                    @adjustIntroColor(obj.object,obj.param,obj.min,obj.max,indexNorm,@minIndex,@maxIndex)

            
            #update stuff
            @camera.updateProjectionMatrix()
            @onFogColorChange(@params.fogcolor)
            @onColorCorrectionChange()

        else if @passedIntro != true
            for obj in @introParams
                # obj = @introParams[prop]
                if obj.type != @colorIntroParam
                    @adjustIntroParam(obj.object,obj.param,obj.min,obj.max,@maxIndex,@minIndex,@maxIndex)
                else
                    @adjustIntroColor(obj.object,obj.param,obj.min,obj.max,@maxIndex,@minIndex,@maxIndex)
            @mouseInteraction.minIndex = @maxIndex
            @passedIntro = true
            @oz().appView.showMenu()

        return null        

    moveBirds:->
        for sprite in @animatedSprites when sprite.isBird == true
            sprite.position.x += 0.5 * (@delta*100)
            if sprite.position.x > 2000
                sprite.position.x = @randRange( -2000, -1000 )

            sprite.lookAt(@camera.position)      
        return null      



    moveDandelions:->

        if @dandelionParticleSystem
            for dandelion,index in @dandelionParticleSystem.geometry.vertices

                setting = @dandelionsSettings[index]

                dandelion.rotation = @dandelionParticleSystem.material.attributes.rotation.value[index] = (Math.PI/4) * Math.sin(@clock.oldTime * setting.speed);
                if !setting.CCW
                    dandelion.x = setting.startX + Math.cos(@clock.oldTime * setting.speed * 0.01) * 50
                    dandelion.y = setting.startY + Math.sin(@clock.oldTime * setting.speed * 0.01) * 50
                else
                    dandelion.x = setting.startX - Math.cos(@clock.oldTime * setting.speed * 0.01) * 50
                    dandelion.y = setting.startY - Math.sin(@clock.oldTime * setting.speed * 0.01) * 50

            @dandelionParticleSystem.material.attributes.rotation.needsUpdate = true
            @dandelionParticleSystem.geometry.verticesNeedUpdate = true    

        return null    


    moveDust:->
        for setting in @dustSettings

            vert = setting.vert
            setting.sinX = setting.sinX + (( 0.002 * setting.speed) * setting.sinXR)
            setting.sinY = setting.sinY + (( 0.002 * setting.speed) * setting.sinYR)
            setting.sinZ = setting.sinZ + (( 0.002 * setting.speed) * setting.sinZR) 

            vert.x = setting.startX + ( Math.sin(setting.sinX) * setting.rangeX )
            vert.y = setting.startY + ( Math.sin(setting.sinY) * setting.rangeY )
            vert.z = setting.startZ + ( Math.sin(setting.sinZ) * setting.rangeZ )

        for obj in @dustSystems
            obj.material.uniforms.time.value += @delta
            obj.geometry.verticesNeedUpdate = true

        return false  

    adjustIntroParam:(obj,param,initialValue,finalValue,indexNorm,minIndex,maxIndex)->
        valExcursion = finalValue - initialValue
        indexExcursion = maxIndex - minIndex

        obj[param] = initialValue + (indexNorm * valExcursion ) / indexExcursion   
        @

    adjustIntroColor:(obj,param,initialValue,finalValue,indexNorm,minIndex,maxIndex)->


        initColor = @stringToColor(initialValue)
        finalColor = @stringToColor(finalValue)


        r = initColor.r + (indexNorm * (finalColor.r - initColor.r)) / (maxIndex - minIndex)
        g = initColor.g + (indexNorm * (finalColor.g - initColor.g)) / (maxIndex - minIndex)
        b = initColor.b + (indexNorm * (finalColor.b - initColor.b)) / (maxIndex - minIndex)

        initColor.r = r
        initColor.g = g
        initColor.b = b

        obj[param] = "#"+initColor.getHex().toString(16)
        @



    changeCutout:(name)->
        
        return unless @currentView == "cutout" && @currentCutout != name

        afterInteractivePosition = new THREE.Vector3(@settings.cutout[name].position[0],@settings.cutout[name].position[1],@settings.cutout[name].position[2])
        afterInteractiveLookat = new THREE.Vector3(@settings.cutout[name].lookat[0],@settings.cutout[name].lookat[1],@settings.cutout[name].lookat[2])

        currentlookat = new THREE.Vector3(@settings.cutout[@currentCutout].lookat[0],@settings.cutout[@currentCutout].lookat[1],@settings.cutout[@currentCutout].lookat[2])

        @hotspotManager.interactiveCameraTween( currentlookat, afterInteractivePosition, afterInteractiveLookat, 50,500 )

        @currentCutout = name
        @

    onMouseDown:(event) =>
        super()
        return unless @enableMouse
        return if @controls? && @controls.enabled
        @mouseDownPoint.set(@mouseX,@mouseY)
        @mouseDownObjects = @checkPicking()
        @


        
    onMouseUp:(event)=>
        super()
        return unless @enableMouse
        return if @controls? && @controls.enabled

        @mouseUpPoint.set(@mouseX,@mouseY)

        @mouseUpObjects = @checkPicking()

        if !@isGoingToInteractive
            if @hotspotManager.handleMouseUp(@mouseUpObjects,@mouseDownObjects)
                if @currentView == @hotspotManager.clickedHotspot
                    @oz().router.navigateTo @currentView
                    if @hotspotManager.zoomInHotspot(@currentView,@onCameraReady,@mouseInteraction)
                        if @currentView == "cutout"
                            @currentCutout = "middle"                    
                        @isGoingToInteractive = true
                else
                    h = ""
                    switch(@hotspotManager.clickedHotspot.toLowerCase())
                        when "zoetrope"
                            h = "carnival2"
                            @oz().router.navigateTo h, false
                        else 
                            h = @hotspotManager.clickedHotspot
                            @oz().router.navigateTo h               


        if @settings?
            for ozificable of @settings.ozificables
                mouseUpOzific = if @mouseUpObjects[ozificable]? then @mouseUpObjects[ozificable] else false
                mousedownozific = if @mouseDownObjects[ozificable]? then @mouseDownObjects[ozificable] else false
                if mousedownozific != false && mouseUpOzific != false && @hotspotManager.is3DMouseClick(mousedownozific,mouseUpOzific)  
                    obj = @settings.ozificables[ozificable]
                    # desc = @scene.getDescendants()
                    for elem in @sceneDescendants when elem.name == obj.target

                        if elem.ozified != true
                            SoundController.send "ozzification_on"
                            new TWEEN.Tween(elem.material.uniforms["lightmapBlend"]).to({value:1}, 2000).start()
                            new IFLOzifyParticleSystem(mousedownozific.object,@scene,@APP_HEIGHT)
                            elem.ozified = true
                        else if elem.ozified == true
                            SoundController.send "ozzification_off"
                            new TWEEN.Tween(elem.material.uniforms["lightmapBlend"]).to({value:0}, 2000).start()
                            elem.ozified = false

                        break
                    break
        @ 

    changeView : (view) =>
        if view == @currentView
            return

        @currentView = view

        if view == null

            @resume()
            @onEnterFrame()

            # all hotspots alpha 1
            @hotspotManager.hotspotsAlpha(1)


            index                       = @settings.navigationPoints[@hotspotManager.clickedHotspot].index
            # index                       = @mouseInteraction.findNearestPathPoint()
            beforeInteractivePosition   = @mouseInteraction.cameraPositionPoints[index].clone()
            beforeInteractiveLookat     = @mouseInteraction.cameraLookatPoints[index].clone()
           
            @mouseInteraction.currentIndex = index
            @mouseInteraction.currentProgress = 0.5
            @mouseInteraction.lookDeviationX._value = 0
            @mouseInteraction.lookDeviationY._value = 0
            @mouseInteraction.bobSpeed._value = 0

            @hotspotManager.interactiveCameraTween( @mouseInteraction.currentLookAt, beforeInteractivePosition, beforeInteractiveLookat, 35, 1500 ).onComplete =>
                @isGoingToInteractive = false
                @nearPoint = null

            @hotspotManager.clickedHotspot = null

            return

        if @hotspotManager.clickedHotspot == @currentView
            # we bot clicked on a hotspot and received a changeview
            # zoom in hotspot            
            # @oz().router.navigateTo view
            if @hotspotManager.zoomInHotspot(view,@onCameraReady,@mouseInteraction)
                if view == "cutout"
                    @currentCutout = "middle"
                @isGoingToInteractive = true
        else
            # we only received a changeview, go in front of hotspot
            if !@gotoPositionOnPath(view)
                # we could not go in front of the hotspot, change the URL
                #console.log "[Carnival] changeView #{view}"
                @oz().router.navigateTo view

        @




    cutoutsUpdatedOnce : false

    updateCutoutsTexture:(texture)->
        
        newtex = null

        if !@cutoutsUpdatedOnce  
            newtex = new THREE.Texture( texture ) 
            newtex.needsUpdate = true
            newtex.flipY = false

        for mesh in @cutoutsDynamicTextures
            
            if !@cutoutsUpdatedOnce
                mesh.material.lightMap = mesh.material.uniforms[ "lightMap" ].value = newtex

            mesh.material.lightMap.image = texture
            mesh.material.lightMap.needsUpdate = true

            

        @cutoutsUpdatedOnce = true
        @

    onResize:=>
        super 

        @mouseInteraction.handleResize(@APP_WIDTH, @APP_HEIGHT)

        if @materialManager && @materialManager.matLib
            for mat in @materialManager.matLib
                if mat.uniforms?.scale? then mat.uniforms.scale.value = ( @APP_HEIGHT / 2 ) * @renderResolutionMultiplier
        @

    dispose:=>
        @materialManager?.dispose( @renderer )
        delete @materialManager
        
        @loader?.dispose()
        delete @loader
        
        @windGenerator?.dispose( @renderer );
        delete @windGenerator

        @hotspotManager?.dispose()
        delete @hotspotManager

        for obj in @scene.children
            @scene.remove obj

        @scene.__webglObjects = null
        @scene.__objects = null
        @scene.__objectsRemoved  = null
        @scene.children = []

        @dustSystems = null
        @animatedSprites = null 

        # @gui.__controllers = []
        # @gui.__folders = []

        super
        @