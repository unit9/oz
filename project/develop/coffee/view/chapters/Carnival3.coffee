class Carnival3 extends Base3DChapter

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
    dustSystemMinX: -100
    dustSystemMaxX: 400
    
    dustSystemMinY: 0
    dustSystemMaxY: 100

    dustSystemMinZ: -200
    dustSystemMaxZ: 30

    windGenerator : null

    # audio
    audiolistener: null

    animatedSprites : null
    nearPoint : null

    pickVector : null
    pickRay : null
    sceneDescendants : null       

    sceneLoadedPerc : 0
    sceneLoaded : false
    textureLoadedPerc : 0
    textureLoaded : false
    loadingDone : false    

    init:->

        super
        
        IFLModelManager.getInstance().cacheTextures(@oz().appView.enablePrefetching)
        IFLModelManager.getInstance().prefetchEnabled = @oz().appView.enablePrefetching


        @mouseUpPoint = new THREE.Vector2()
        @mouseDownPoint = new THREE.Vector2()
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
        @camera.far = 5000
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

        @params.colorCorrectionPow = "#443f72"
        @params.colorCorrectionPowM = 2
        @params.colorCorrectionMul = "#989898"
        @params.colorCorrectionMulM = 1.7
        @params.colorCorrectionSaturation = -34
        @params.colorCorrectionSaturationColors = "#162c46"

        @dofpost.focus = @dofpost.bokeh_uniforms[ "focus" ].value = 0.97
        @dofpost.aperture = @dofpost.bokeh_uniforms[ "aperture" ].value = 0.009
        @dofpost.maxblur = @dofpost.bokeh_uniforms[ "maxblur" ].value = 0.007
        @dofpost.cameranear = 0.001
        @dofpost.camerafar = 956 
        

        @params.bloomPower = @effectBloom.screenUniforms.opacity.value = 0.19
        @effectBloom.enabled = true
        
        @debugPaths = new THREE.Object3D

        if @renderer.supportsVertexTextures()
            @windGenerator = new IFLWindGenerator()
            @windGenerator.noiseSpeed = 0.09
            @windGenerator.enabled = if @oz().appView.displayQuality != "low" then true else false

       
        @colorCorrection.uniforms.vignetteOffset.value = 0.2
        @colorCorrection.uniforms.vignetteDarkness.value = 1       
        if @oz().appView.debugMode
            @initGUI()
        @onColorCorrectionChange()

        # @colorCorrection.uniforms["tOverlay"].value = THREE.ImageUtils.loadCompressedTexture( "/models/textures/drops.dds" )
        # @windGenerator.noiseOffsetSpeed = 0.6

        @autoPerformance.steps.push 
            name : "Wind"
            enabled : if @windGenerator? then @windGenerator.enabled else false
            priority : 50
            disableFunc : @onWindEnabledChange

        @onResize()

        @lastMouseY = @mouseY + @APP_HALF_Y
        @lastMouseX = @mouseX + @APP_HALF_X
        @

    render:=>
        super
        $.ajax( {url : "/models/s003_settings.json", dataType: 'json', success : @onSettingsLoaded });   
        return null      



    onSettingsLoaded:(settings)=>
        @settings = settings

        for i in [0...settings.positions.length] by 3
            @mouseInteraction.cameraPositionPoints.push(new THREE.Vector3(settings.positions[i],settings.positions[i+1],settings.positions[i+2]))

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
        
        # console.log "Carnival3 world loaded"
        SoundController.send 'load_scene_3', 'scene_carnival3_start'

        @sceneLoaded = true
        @loader = loader
        @advanceLoading()
        @

    show:()=>
        # console.log "Carnival3 Show"
        @instanceWorld()
        @oz().appView.showMenu()
        super

    advanceLoading : ()=>
        total = @sceneLoadedPerc * 0.5 + @textureLoadedPerc * 0.5
        @onWorldProgress(total)

        if @textureLoaded == true && @sceneLoaded == true && !@loadingDone
            @loadingDone = true
            # @instanceWorld()
            @onWorldProgress(1)
            @onWorldLoaded()

    instanceWorld:=>
        # console.log "Carnival3 instance world"
        @loadedScene = @loader.createModel(true)
        desc = @loadedScene.getDescendants()


        blacklist = ["grass","branch"]
        dofblacklist = ["grass","branch"]


        for elem in desc
 
            if elem.material?.uniforms?.tWindForce? && elem.material.vertexColors == THREE.VertexColors && @windGenerator?
                elem.material.uniforms.tWindForce.value = @windGenerator.noiseMap
                elem.material.uniforms.windDirection.value.copy @windGenerator.windDirection


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

        # @scene.add @loadedScene
        @initTornado()
        @initSun()
        if @oz().appView.showInterface
            @hotspotManager.init(@settings,@scene,@materialManager,@oz().localeTexture,@camera)
        # @initHotspots()
        @initDustSystems()
        

        @enableRender = true
        @onResize()
        @sceneDescendants = @scene.getDescendants()
        # @loader?.dispose()
        # @loader = null
        # @onWindEnabledChange(@windGenerator.enabled)        
        @pickableObjects = []
        for object in @sceneDescendants when object.pickable == true
            @pickableObjects.push object        
       


    initTornado:->

        @tornadomaterial = new THREE.MeshBasicMaterial
            lights : false
            # blending : THREE.AdditiveBlending
            transparent : true
            map : @materialManager.getPreloadedTexture("storm_animation.dds")
            side : THREE.DoubleSide
            fog : false
            # opacity : 0.5

        @tornadomaterial.map.wrapS = @tornadomaterial.map.wrapT = THREE.RepeatWrapping
        @tornadomaterial.map.flipY = false

        @tornadomaterial.time = 0
        @tornadomaterial.spritenum = 0
        @tornadomaterial.totalframes = 16
        @tornadomaterial.spritex = 4
        @tornadomaterial.spritey = 4
        @tornadomaterial.frametime = 0.01



        @materialManager.matLib.push @tornadomaterial
        @materialManager.texLib.push @tornadomaterial.map

        tornadoSize = 940
        geom = new THREE.PlaneGeometry(tornadoSize,tornadoSize,10,10)

        @tornado = new THREE.Mesh(geom,@tornadomaterial)
        @excludeFromDOF.push(@tornado)
        @tornado.name = "tornado_animated"
        @tornado.tornadoSize = tornadoSize
        @tornado.position.set(835,470,-4100)
        # @tornado.rotation.set(0,-0.412770368,0)

        @animatedSprites.push @tornado

        @materialManager.texLib.push @tornadomaterial.map
        @materialManager.matLib.push @tornadomaterial


        for vertex in geom.vertices
            vertex.y = -vertex.y
            # vertex.y += 300
            vertex.origX = vertex.x
            vertex.origY = vertex.y
            vertex.origZ = vertex.z

        # @tornado.position.y -= 300

        @scene.add @tornado        


    initDustSystems:()->
        for i in [0...5]
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

            for k in [0...num]
                vert = new THREE.Vector3
                vert.x = vert.startX = @randRange(@dustSystemMinX,@dustSystemMaxX)
                vert.y = vert.startY = @randRange(@dustSystemMinY,@dustSystemMaxY)
                vert.z = vert.startZ = @randRange(@dustSystemMinZ,@dustSystemMaxZ)
                vert.speed = 1 + Math.random() * 10
                params.attributes.speed.value[k] = vert.speed
                
                vert.sinX = Math.random()
                vert.sinXR = if Math.random() < 0.5 then 1 else -1
                vert.sinY = Math.random()
                vert.sinYR = if Math.random() < 0.5 then 1 else -1
                vert.sinZ = Math.random()
                vert.sinZR = if Math.random() < 0.5 then 1 else -1

                vert.rangeX = Math.random() * 5
                vert.rangeY = Math.random() * 5
                vert.rangeZ = Math.random() * 5

                geom.vertices.push vert
            particlesystem = new THREE.ParticleSystem( geom , mat )
            @excludeFromDOF.push(particlesystem)
            @dustSystems.push particlesystem
            @scene.add particlesystem
        @

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
        @   

    onWindEnabledChange:(value)=>

        val = if !value? then false else ( if value? && value == true then true else false )

        @materialManager.vertexColorsEnabled(val)
        @windGenerator?.enabled = val
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
        
        return unless @enableRender
        return if @disposed == true
        super
        @updateInitialSettings()   
        @mouseOverObjects = @checkPicking()
        @handlePointer()
        @handleAnimatedSprites()
        @moveTornado()
        @hotspotManager?.update(@delta)
        # dust movement
        @moveDust()
        #mouse interaction
        @handleMultiCamera()
        @renderer?.clear()
        @windGenerator?.update(@renderer,@delta)
        if @renderer
            @doRender()

        if @capturer
            @capturer.capture( @oz().appView.renderCanvas3D )

    handleMultiCamera:->
        if !@isGoingToInteractive
            if ( (!@controls? || (@controls? && !@controls.enabled)) && @enableMouse )
                @camera?.matrixAutoUpdate = false
                @mouseInteraction?.update(@delta,@mouseX,@mouseY)
            else
                @camera?.matrixAutoUpdate = true
        else
            @camera?.matrixAutoUpdate = false
        return null

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
        if @dustSystems
            for obj in @dustSystems
                obj.material.uniforms.time.value += @delta

                for vert in obj.geometry.vertices
                    vert.sinX = vert.sinX + (( 0.002 * vert.speed) * vert.sinXR) * 10
                    vert.sinY = vert.sinY + (( 0.002 * vert.speed) * vert.sinYR) * 10
                    vert.sinZ = vert.sinZ + (( 0.002 * vert.speed) * vert.sinZR) * 10

                    vert.x += @delta * vert.speed * 5
                    if vert.x > @dustSystemMaxX
                        vert.x = @randRange(@dustSystemMinX-200,@dustSystemMinX)
                    # vert.x = vert.startX + ( Math.sin(vert.sinX) * vert.rangeX )
                    vert.y = vert.startY + ( Math.sin(vert.sinY) * vert.rangeY )
                    vert.z = vert.startZ + ( Math.sin(vert.sinZ) * vert.rangeZ )

                obj.geometry.verticesNeedUpdate = true
        return null


    moveTornado:->
        if @tornado
            for vertex in @tornado.geometry.vertices
                influence = (@tornado.tornadoSize/2) - Math.abs(vertex.origY)
                vertex.x = vertex.origX + Math.sin(@clock.oldTime / 1500) * ( influence / 9 )
                vertex.y = vertex.origY + Math.sin(@clock.oldTime / 2000) * ( influence / 7 )

            @tornado.geometry.verticesNeedUpdate = true    

        return null

    changeView : (view) =>
        # console.log "CHANGEVIEW #{view}"
        #in scene 3 we only change views by /url
        if !@gotoPositionOnPath(view)
            # we could not go in front of the hotspot, change the URL
            @oz().router.navigateTo view
        

        # if view == @currentView
        #     return

        # @currentView = view

        # if view == null

        #     @resume()
        #     @onEnterFrame()

        #     @hotspotManager.hotspotsAlpha(0)

        #     index                       = @mouseInteraction.findNearestPathPoint()
        #     beforeInteractivePosition   = @mouseInteraction.cameraPositionPoints[index].clone()
        #     beforeInteractiveLookat     = @mouseInteraction.cameraLookatPoints[index].clone()
           
        #     @mouseInteraction.currentIndex = index
        #     @mouseInteraction.currentProgress = 0.5
        #     @mouseInteraction.lookDeviationX._value = 0
        #     @mouseInteraction.lookDeviationY._value = 0
        #     @mouseInteraction.bobSpeed._value = 0

        #     @hotspotManager.interactiveCameraTween( @mouseInteraction.currentLookAt, beforeInteractivePosition, beforeInteractiveLookat, 35, 1500 ).onComplete =>
        #         @isGoingToInteractive = false

        #     return
        # else
        #     @oz().router.navigateTo view

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
        return unless @mouseUpObjects? && @mouseDownObjects?

        if @hotspotManager.handleMouseUp(@mouseUpObjects,@mouseDownObjects)
            if @hotspotManager.clickedHotspot == "storm"
                @hotspotManager.hotspotsAlpha(0)
                SoundController.send "storm_zoom_in"
                @isGoingToInteractive = true
                targetPosition = new THREE.Vector3(140,20,-300)
                targetLookAt = new THREE.Vector3(120,55,-400)

                @hotspotManager.interactiveCameraTween( @mouseInteraction.currentLookAt, targetPosition, targetLookAt, 35, 3500 ).onComplete =>
                    @oz().router.navigateTo @hotspotManager.clickedHotspot

                return      


        if @hotspotManager.handleMouseUp(@mouseUpObjects,@mouseDownObjects)
            if @currentView == @hotspotManager.clickedHotspot
                @oz().router.navigateTo @currentView
                if @hotspotManager.zoomInHotspot(@currentView,@onCameraReady,@mouseInteraction)
                    @isGoingToInteractive = true
            else
                h = ""

                ###
                TODO: add this case for production
                when "stormtest"
                    h = "stormtest"
                    @oz().router.navigateTo h, false
                ###


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

    onResize:=>
        super 

        @mouseInteraction.handleResize(@APP_WIDTH, @APP_HEIGHT)

        if @materialManager && @materialManager.matLib
            for mat in @materialManager.matLib
                if mat.uniforms?.scale? then mat.uniforms.scale.value = ( @APP_HEIGHT / 2 ) * @renderResolutionMultiplier
        @

    dispose:=>
        @enableRender = false
        @disposed = true

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
        super
        @