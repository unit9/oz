class Carnival2 extends Base3DChapter

    settings: null
    loadedScene : null
    mouseInteraction : null
    hotspotManager : null
    materialManager : null
    
    enableRender : false
    debugPaths: null
    
    mouseOverObjects : null
    mouseDownObjects : null
    mouseUpObjects : null
    lastMouseX : 0
    lastMouseY : 0
    mouseDownPoint : null
    mouseUpPoint : null

    isGoingToInteractive : false   
    currentView : null
    currentCutout : null

    # dust system 
    dustSystems: null
    dustSystemMinX: -170
    dustSystemMinY: 0
    dustSystemMinZ: -200
    dustSystemMaxX: 80
    dustSystemMaxY: 100
    dustSystemMaxZ: 30

    windGenerator : null

    # audio
    audiolistener: null

    occlusionBuffer : null
    animatedSprites : null
    nearPoint : null
    pickVector : null
    pickRay : null
    sceneDescendants : null    
    dustSettings : null

    sceneLoadedPerc : 0
    sceneLoaded : false
    textureLoadedPerc : 0
    textureLoaded : false
    loadingDone : false

    init:->
        
        super

        IFLModelManager.getInstance().cacheTextures(@oz().appView.enablePrefetching)
        IFLModelManager.getInstance().prefetchEnabled = @oz().appView.enablePrefetching

        @dustSettings = []
        @mouseDownPoint = new THREE.Vector2
        @mouseUpPoint = new THREE.Vector2
        @pickVector = new THREE.Vector3
        @pickRay = new THREE.Ray

        @animatedSprites = []
        @dustSystems = []
        @mouseDownObjects = []
        @mouseUpObjects = []
        @mouseOverObjects = []

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
        @camera.far = 7000
        @camera.target =  new THREE.Vector3( 0, 0, 0 )

        @mouseInteraction = new IFLCameraPathInteraction @camera 
        @mouseInteraction.maxXLookDeviation = 40

        if SoundController.active
            @audiolistener = new THREE.AudioListenerObject @camera
            @audiolistener.position.set 0, 150, 400
            @scene.add @audiolistener

        # @controls = new THREE.OrbitControls(@camera,@oz().appView.wrapper.el)
        if @oz().appView.debugMode
            @controls = new THREE.FirstPersonControls(@camera,@oz().appView.wrapper.el)
            @controls.movementSpeed = 20
            @controls.lookSpeed = 0.005 * 5
            @controls.enabled = false

        @materialManager = new IFLMaterialManager
        
        @hotspotManager = new IFLHotspotManager

        @params.cameraFOV = @camera.fov
        
        @params.fogcolor = "#180f20"
        @scene.fog.far = 757
        @scene.fog.near = 0
        @scene.fog.color.copy @stringToColor(@params.fogcolor)

        @params.colorCorrectionPow = "#2f2869"
        @params.colorCorrectionPowM = 2
        @params.colorCorrectionMul = "#bea38b"
        @params.colorCorrectionMulM = 1.8
        @params.colorCorrectionSaturation = -52
        @params.colorCorrectionSaturationColors = "#11263e"

        @dofpost.focus = @dofpost.bokeh_uniforms[ "focus" ].value = 0.97
        @dofpost.aperture = @dofpost.bokeh_uniforms[ "aperture" ].value = 0.009
        @dofpost.maxblur = @dofpost.bokeh_uniforms[ "maxblur" ].value = 0.007
        @dofpost.cameranear = 0.001
        @dofpost.camerafar = 956 
        

        @params.bloomPower = @effectBloom.screenUniforms.opacity.value = 0.75
        @effectBloom.enabled = true


        
        @debugPaths = new THREE.Object3D
        if @renderer.supportsVertexTextures()
            @windGenerator = new IFLWindGenerator()
            @windGenerator.enabled = if @oz().appView.displayQuality != "low" then true else false


        @colorCorrection.uniforms.vignetteOffset.value = 0.2
        @colorCorrection.uniforms.vignetteDarkness.value = 1
        if @oz().appView.debugMode
            @initGUI()
        @onColorCorrectionChange()

 
       

        @autoPerformance.steps.push 
            name : "Wind"
            enabled : if @windGenerator? then @windGenerator.enabled else false
            priority : 50
            disableFunc : @onWindEnabledChange

     

        @onResize()



        @lastMouseY = @mouseY + @APP_HALF_Y
        @lastMouseX = @mouseX + @APP_HALF_X
        return null

    render:=>
        super
        $.ajax( {url : "/models/s002_settings.json", dataType: 'json', success : @onSettingsLoaded });     
        return null

    onSettingsLoaded:(settings)=>
        @settings = settings

        # @cameraPositionPoints = []
        for i in [0...settings.positions.length] by 3
            @mouseInteraction.cameraPositionPoints.push(new THREE.Vector3(settings.positions[i],settings.positions[i+1],settings.positions[i+2]))

        # @cameraLookatPoints = []
        for i in [0...settings.lookAt.length] by 3
            @mouseInteraction.cameraLookatPoints.push(new THREE.Vector3(settings.lookAt[i],settings.lookAt[i+1],settings.lookAt[i+2]))
        

        if @oz().appView.debugMode
            @createDebugPath(@mouseInteraction.cameraPositionPoints)
            @createDebugPath(@mouseInteraction.cameraLookatPoints)

        settings.renderer = @renderer
        settings.onProgress = @onTextureProgress
        settings.onComplete = @onTextureComplete
        settings.textureQuality = if @oz().appView.ddsSupported then @oz().appView.textureQuality else "low"


        @materialManager.enableTextureFiltering = THREE.WebGLRenderer.AnisotropySupported || (QueryString.get("anisotropy") == "off")
        @materialManager.forcePNGTextures = !@oz().appView.ddsSupported || !THREE.WebGLRenderer.AnisotropySupported

        @materialManager.init(settings)
        @materialManager.load()

        # @loader = new IFLLoader()
        # @loader.enableMaterialCache = false
        # @loader.enableTextureCache = false
        # @loader.pickableObjects = @settings.pickables
        # @loader.customMaterialInstancer = @materialManager.instanceMaterial
        # @loader.doCreateModel = false
        # @loader.load(@settings.modelURL,@onSceneLoaded,@onSceneProgress)

        IFLModelManager.getInstance().load(@settings.pickables, @materialManager.instanceMaterial, @settings.modelURL, @onSceneLoaded, @onSceneProgress)
        return null



    onTextureProgress:(percent) =>
        @textureLoadedPerc = percent
        @advanceLoading()
        return null

    onTextureComplete:() =>
        @textureLoaded = true
        @advanceLoading()
        return null

    onSceneProgress : (loaded,total) => 
        # l : total = x : 100
        @sceneLoadedPerc = loaded / total
        @advanceLoading()
        return null

    onSceneLoaded:(loader,loadedScene) =>
        # console.log "Carnival2 world loaded", @oz().appView.firstTime
        
        if @oz().appView.firstTime
            SoundController.send 'load_scene_1', ['load_scene_5', 'scene_carnival_start']
        else
            SoundController.send 'load_scene_2', 'scene_carnival2_start'

        @sceneLoaded = true
        @loader = loader
        @advanceLoading()
        return null

    show:()=>
        # console.log "Carnival2 Show"
        @instanceWorld()
        @oz().appView.showMenu()
        super
        return null
    
    advanceLoading : ()=>
        total = @sceneLoadedPerc * 0.5 + @textureLoadedPerc * 0.5
        @onWorldProgress(total)

        if @textureLoaded == true && @sceneLoaded == true && !@loadingDone
            @loadingDone = true
            # @instanceWorld()
            @onWorldProgress(1)
            @onWorldLoaded()
        return null

    instanceWorld:=>
        # console.log "Carnival2 instance world"
        @loadedScene = @loader.createModel(true)

        if @dofpost.enabled
            dofplanehack = new THREE.Mesh(new THREE.PlaneGeometry(27.958,20.505,1,1),new THREE.MeshBasicMaterial({transparent:true,opacity:0,color:0xFF0000}))
            dofplanehack.rotation.set(0,0.778347033,0)
            dofplanehack.position.set(13.615,13.477,-114.834)
            @scene.add dofplanehack

        vols = []
        count = 0
        desc = @loadedScene.getDescendants()
        blacklist = ["grass","branch"]
        dofblacklist = ["grass","branch"]
        

        for elem in desc
            # elem.position.set(0,0,0)
            # elem.rotation.set(0,0,0)
            # elem.scale.set(1,1,1)

            if elem.material?.uniforms?.tWindForce? && elem.material.vertexColors == THREE.VertexColors && @windGenerator?
                elem.material.uniforms.tWindForce.value = @windGenerator.noiseMap
                elem.material.uniforms.windDirection.value.copy @windGenerator.windDirection

            if elem.name.toLowerCase().indexOf("zoetrope") != -1
                @zoe = elem            

            if elem.name.toLowerCase().indexOf("zfg_spec") != -1
                @pole = elem


            if elem.name.toLowerCase().indexOf("vol_main") != -1
                if count % 2 == 0
                    @loadedScene.remove elem
                count++

                # vols.push {elem:elem,sortOrder:0}

            # Frustum hack
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
                isBlacklisted = false
                for blacklisted in blacklist
                    if elem.name.toLowerCase().indexOf(blacklisted.toLowerCase()) != -1
                        isBlacklisted = true
                        break

                if !isBlacklisted
                    @scene.add elem
            else
                @scene.add elem

            for dofblacklisted in dofblacklist
                if elem.name.toLowerCase().indexOf(dofblacklisted.toLowerCase()) != -1
                    @excludeFromDOF.push(elem)
                    break 




        @initOcclusionScene()
        @initProjection()

        @initSun()


        if @oz().appView.showInterface
            @hotspotManager.init(@settings,@scene,@materialManager,@oz().localeTexture,@camera)
        @initDustSystems()

        if @oz().appView.zoetropeTexture?
            @updateFilmTexture(@oz().appView.zoetropeTexture)

        
        @sceneDescendants = @scene.getDescendants()

        @pickableObjects = []
        for object in @sceneDescendants when object.pickable == true
            @pickableObjects.push object

        @enableRender = true
        @onResize()
        # @loader?.dispose()
        # @loader = null
        return null

       

    initProjection:->

        @projectionmat = new THREE.MeshBasicMaterial
            lights : false
            blending : THREE.AdditiveBlending
            transparent : true
            map : @materialManager.getPreloadedTexture("projection.dds")
            side : THREE.DoubleSide
            opacity : 0.5

        @projectionmat.map.generateMipmaps = false
        @projectionmat.map.magFilter = THREE.LinearFilter
        @projectionmat.map.minFilter = THREE.LinearFilter
        @projectionmat.map.wrapS = @projectionmat.map.wrapT = THREE.RepeatWrapping

        @projectionmat.time = 0
        @projectionmat.spritenum = 0
        @projectionmat.totalframes = 12
        @projectionmat.spritex = 3
        @projectionmat.spritey = 4
        @projectionmat.frametime = 0.1



        @materialManager.matLib.push @projectionmat
        @materialManager.texLib.push @projectionmat.map


        geom = new THREE.PlaneGeometry(20,20,1,1)

        #invert UV, don't know why
        # for uv in geom.faceVertexUvs[0][0]
        #     uv.v = 1-uv.v

        @projection = new THREE.Mesh(geom,@projectionmat)
        @projection.name = "zoetrope_projection"
        @projection.position.set(144.999,16.892,-126.195)
        @projection.rotation.set(-Math.PI,-0.171845118,0)

        @animatedSprites.push @projection

        @scene.add @projection
        return null

    initOcclusionScene:->



        @occlusionScene = new THREE.Scene
        gmat = new THREE.MeshBasicMaterial( { color: 0x000000, map: null } );
        gmat2 = new THREE.MeshBasicMaterial( { color: 0xf2f0ce, map: null } );
        zoeMesh = new THREE.Mesh(@zoe.geometry,gmat)
        zoeMesh.name = "occlusion_zoetrope"
        poleMesh = new THREE.Mesh(@pole.geometry,gmat)
        poleMesh.name = "occlusion_pole"
        @occlusionScene.add zoeMesh
        @occlusionScene.add poleMesh

        # @light1 = new THREE.Mesh(new THREE.SphereGeometry(.6),gmat2)
        # @light1.position.set(132.869,13.903,-81.192)
        # @occlusionScene.add @light1

        # @light2 = new THREE.Mesh(new THREE.SphereGeometry(.6),gmat2)
        # @light2.position.set(135.281,15.427,-81.938)
        # @occlusionScene.add @light2

        # @light3 = new THREE.Mesh(new THREE.SphereGeometry(.6),gmat2)
        # @light3.position.set(135.406,13.972,-81.483)
        # @occlusionScene.add @light3


        @light2 = new THREE.Mesh(new THREE.SphereGeometry(1.8),gmat2)
        @light2.name = "occlusion_light"
        @light2.position.set(134.18,14.428,-80.7)
        @light2.scale.y = 0.6
        @occlusionScene.add @light2

        @occlusionBuffer = new THREE.WebGLRenderTarget( @APP_WIDTH / 2, @APP_HEIGHT / 2,{
            minFilter: THREE.LinearFilter
            magFilter: THREE.LinearFilter
            format: THREE.RGBFormat } )
        @colorCorrection.uniforms["tVolumetricLight"].value = @occlusionBuffer

        @occlusionComposer = new THREE.EffectComposer( @renderer, @occlusionBuffer )

        renderModelOcl = new THREE.RenderPass( @occlusionScene, @camera );
        @occlusion_hblur = new THREE.ShaderPass( THREE.ShaderExtras[ "horizontalTiltShift" ] );
        @occlusion_vblur = new THREE.ShaderPass( THREE.ShaderExtras[ "verticalTiltShift" ] );

        bluriness = 2;

        @occlusion_hblur.uniforms[ 'h' ].value = bluriness / @APP_WIDTH * 2;
        @occlusion_vblur.uniforms[ 'v' ].value = bluriness / @APP_HEIGHT * 2;


        @occlusionComposer.addPass( renderModelOcl );
        @occlusionComposer.addPass( @occlusion_hblur );
        @occlusionComposer.addPass( @occlusion_vblur );
        @occlusionComposer.addPass( @occlusion_hblur );
        @occlusionComposer.addPass( @occlusion_vblur ); 
        return null   

    

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

            if @windGenerator?
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
            @excludeFromDOF.push(particlesystem)
            @dustSystems.push particlesystem
            @scene.add particlesystem
        return null

    initGUI:(settings)->
        super(settings)

        # fresnel = @gui.addFolder("Fresnel Material")
        @gui.add( {value:-2.5}, 'value',-5,20 ).name('Fresnel Power').onChange(@materialManager.changeFresnelPower)
        @gui.add( {value:1.0}, 'value',0,10 ).name('Normal Scale').onChange(@materialManager.changeNormalScale)
        if @windGenerator?
            @gui.add( {value:@windGenerator.enabled}, 'value').name('Enable Wind').onChange(@onWindEnabledChange)

        @gui.add(@mouseInteraction,"constantSpeed").name("Use Constant Speed")
        @gui.add(@mouseInteraction,"maxspeed",0,2).name("Maximum slide speed")
        @gui.add(@mouseInteraction,"maxYLookDeviation",0,100).name("Maximum Y Look")
        @gui.add(@mouseInteraction,"maxXLookDeviation",0,100).name("Maximum X Look")
        @gui.add({value:false},"value").name("Show Camera Paths").onChange @onShowDebugPathChange
        @gui.add(@controls,"enabled").name("Exit Camera Path")#.onChange (value)=>@camera.useQuaternion = value
        # @gui.add({value:2},"value",0,2).name("Texture Quality").step(1).onChange @onTextureQualityChange
        return null   

    onWindEnabledChange:(value)=>

        val = if !value? then false else ( if value? && value == true then true else false )

        @materialManager.vertexColorsEnabled(val)
        @windGenerator?.enabled = val
        @loader.geometryAttributeEnabled("color",val)
        return null

    onShowDebugPathChange:(value)=>
        if value
            @scene.add @debugPaths
        else
            @scene.remove @debugPaths
        return null

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
        return null


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

        return null

    onEnterFrame : =>
        # console.log "CARNIVAL 2 ENTERFRAME"
        return unless @enableRender

        super

        @updateInitialSettings()
        @mouseOverObjects = @checkPicking()
        @handlePointer()
        @handleAnimatedSprites()
        @hotspotManager.update(@delta)
        # dust movement
        @moveDust()
        #mouse interaction
        @handleMultiCamera()
        @renderer.clear()
        @windGenerator?.update(@renderer,@delta)
        @updateOcclusionScene()
        @doRender()

        # if @oz().appView.debugMode
        #     console.log @camera.position.z

        if @capturer
            @capturer.capture( @oz().appView.renderCanvas3D )
            
        return null

    handleMultiCamera:->
        if !@isGoingToInteractive
            if ( (!@controls? || (@controls? && !@controls.enabled)) && @enableMouse )
                @camera.matrixAutoUpdate = false
                @mouseInteraction.update(@delta,@mouseX,@mouseY)
            else
                @camera.matrixAutoUpdate = true
        else
            @camera.matrixAutoUpdate = false        

    updateInitialSettings:->

        if !@windinitialSettings? then @windinitialSettings = 0
        if @windinitialSettings == 2
            if @windGenerator?
                @onWindEnabledChange(@windGenerator.enabled)
            @windinitialSettings++
        else
            @windinitialSettings++

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

    updateOcclusionScene:->
        if @occlusionScene?
            if @mouseInteraction.currentIndex > 50 || @currentView != null
                @light2.updateMatrixWorld();
                # proj = @projectOnScreen(@camera,@light2)
                screenSpacePosition = @light2.position.clone();

                proj = @projector.projectVector( screenSpacePosition, @camera );
                proj.x = (1 + proj.x)/2
                proj.y = (1 + proj.y)/2


                @colorCorrection.uniforms.volumetricLightX.value = proj.x
                @colorCorrection.uniforms.volumetricLightY.value = proj.y


                @occlusion_hblur.uniforms.r.value = -1
                @occlusion_vblur.uniforms.r.value = -1

                fluct = (1 + Math.sin(@clock.oldTime/700) )/2
                @light2.scale.x = @light2.scale.z = 0.9 + ( fluct * 0.1 )

                @colorCorrection.uniforms.enableVolumetricLight.value = 1
                @renderer.clearTarget(@occlusionBuffer,true)
                @occlusionComposer.render()
            else
                @colorCorrection.uniforms.enableVolumetricLight.value = 0

        return null

    updateFilmTexture:(texture)->
        # console.log "update film texture"
        if texture?
            @oz().appView.zoetropeTexture = texture

        if @projectionmat

            # if !@user_projection_tex?
            @user_projection_tex = new THREE.Texture(texture)
            @user_projection_tex.flipY = false
            @user_projection_tex.needsUpdate = true
            if @projectionmat.uniforms?
                @projectionmat.uniforms["map"].value = @user_projection_tex      
            @projectionmat.map = @user_projection_tex
            # if @projectionmat.uniforms?
            #     @projectionmat.uniforms["map"].value.image = texture
            # @projectionmat.map.image = texture
            # @projectionmat.map.needsUpdate = true
        @


    changeView : (view) =>
        if view == @currentView
            return

        @currentView = view

        if view == null

            @resume()
            @onEnterFrame()

            @hotspotManager.hotspotsAlpha(1)


            index                       = @mouseInteraction.findNearestPathPoint()
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
                @isGoingToInteractive = true
        else
            # we only received a changeview, go in front of hotspot
            if !@gotoPositionOnPath(view)
                # we could not go in front of the hotspot, change the URL
                @oz().router.navigateTo view
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


        if @hotspotManager.handleMouseUp(@mouseUpObjects,@mouseDownObjects)
            if @currentView == @hotspotManager.clickedHotspot
                @oz().router.navigateTo @currentView
                if @hotspotManager.zoomInHotspot(@currentView,@onCameraReady,@mouseInteraction)
                    @isGoingToInteractive = true
            else
                h = ""
                switch(@hotspotManager.clickedHotspot.toLowerCase())
                    when "music"
                        h = "carnival"
                        @oz().router.navigateTo h, false
                    when "storm"
                        h = "carnival3"
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

    onResize:=>
        super 

        @mouseInteraction.handleResize(@APP_WIDTH, @APP_HEIGHT)

        if @materialManager && @materialManager.matLib
            for mat in @materialManager.matLib
                if mat.uniforms?.scale? then mat.uniforms.scale.value = ( @APP_HEIGHT / 2 ) * @renderResolutionMultiplier
        @

    dispose:=>
        @enableRender = false

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

        for obj in @occlusionScene.children
            @occlusionScene.remove obj

        @occlusionScene.__webglObjects = null
        @occlusionScene.__objects = null
        @occlusionScene.__objectsRemoved  = null
        @occlusionScene.children = []   

        @dustSystems = null
        @animatedSprites = null        

        super
        @