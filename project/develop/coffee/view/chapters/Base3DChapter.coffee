class Base3DChapter extends AbstractChapter
    guicontainer    : null
    camera          : null
    scene           : null
    renderer        : null
    controls        : null
    clock           : null
    renderTarget    : null
    composer        : null

    APP_HEIGHT      : 800
    APP_WIDTH       : 600
    APP_HALF_X      : 800/2;
    APP_HALF_Y      : 600/2;    
    mouseX          : 0
    mouseY          : 0
    enableMouse     : true
    mouseDown       : false
    mouseLeft       : false

    lensFlare       : null
    skyCubeTexture  : null
    skyCube         : null

    pointer         : null
    pickMouse       : null
    projector       : null
    gui             : null
    hud             : null

    params :
        cameraFOV : 50
        colorCorrectionPow: "#2e3359"
        colorCorrectionPowM : 1.4
        colorCorrectionMul: "#e3d1d1"
        colorCorrectionMulM : 1.6
        colorCorrectionSaturation: -50
        colorCorrectionSaturationColors: "#b15858"
        bloomPower : 0.39
        fogcolor : "#caa46f"

    colorCorrection : null
    effectBloom     : null
    renderModel     : null
    # effectFilm      : null
    # vblur           : null
    # hblur           : null
    dofpost         : null

    autoPerformance : null

    renderResolutionMultiplier : 1
    keyMultiplier : 0
    keyDowns : []    
    elasticVirtMouseX : null
    elasticVirtMouseY : null
    lastKeyPress : 0
    pickableObjects : null
    emptyRenderPluginPost : null


    # optimized intersects object stuff with custom array
    # THREE.Ray.prototype.intersectObjects = ( objects, recursive, intersects ) ->

    #     for object in objects
    #         intersectObject( object, this, intersects )
    #     intersects.sort( descSort );

    #     return intersects;

    


    # THREEJS Frustum Test Hack for 0,0,0 objects with custom bounding sphere specified in settings
    THREE.Frustum.prototype.contains = (object)->

        distance = 0.0;
        planes = this.planes;
        matrix = if object.customFrustumMatrix? then object.customFrustumMatrix else object.matrixWorld
        me = matrix.elements;
        radius = - object.geometry.boundingSphere.radius * matrix.getMaxScaleOnAxis();

        # for ( var i = 0; i < 6; i ++ ) 
        for i in [0...6] by 1
            distance = planes[ i ].x * me[12] + planes[ i ].y * me[13] + planes[ i ].z * me[14] + planes[ i ].w
            if distance <= radius
                return false;


        return true


    onRenderingError:(errorString)=>
        if !@oz().appView.debugMode
            # A shader compilation error occurred
            # redirect the user to the error page 
            top.location.href = "/error_gc.html?error="+errorString+"_DISPLAY_QUALITY_"+@oz().appView.displayQuality+"_TEXTURE_QUALITY_"+@oz().appView.textureQuality
        return null

    init:=>

        @emptyRenderPluginPost = []
        
        @clock =  new THREE.Clock()
        @pickMouse = 
            x:0
            y:0

        @elasticVirtMouseX         = new ElasticNumber
        @elasticVirtMouseY         = new ElasticNumber
        @elasticVirtMouseX.spring = @elasticVirtMouseY.spring = 0.0015
        @elasticVirtMouseX.damping = @elasticVirtMouseY.damping = 0.07        

        @projector = new THREE.Projector();

        @APP_WIDTH = $(window).width();
        @APP_HEIGHT = $(window).height();

        @renderer = new THREE.WebGLRenderer
            canvas : @oz().appView.renderCanvas3D
            antialias : false

        @renderer.onError = @onRenderingError

        @oz().appView.ddsSupported = THREE.WebGLRenderer.DDSSupported && (QueryString.get("dds") != "off")


        @renderer.autoClear = false
        @renderer.setSize( @APP_WIDTH, @APP_HEIGHT )
        @renderer.setClearColorHex( 0x000000, 1 )
        # @renderer.domElement.dispose = ()-> return

        @camera = new THREE.PerspectiveCamera( 50, @APP_WIDTH / @APP_HEIGHT, 10, 100000 )
        @camera.name = "mainCamera"
        @scene = new THREE.Scene();
        @scene.fog = new THREE.Fog( parseInt("0x#{@params.fogcolor.substr(1)}") , 0, 689 );


        switch @oz().appView.displayQuality
            when "hi" then @renderResolutionMultiplier = 1
            when "med" then @renderResolutionMultiplier = 0.5
            when "low" then @renderResolutionMultiplier = 0.4


        # ambient = new THREE.AmbientLight 0xFFFFFF
        # @scene.add( ambient )

        # window.addEventListener( 'resize', @onWindowResize, false );
        # document.addEventListener( 'mousemove', @onMouseMove, false );
        document.addEventListener( 'keydown', @onKeyDown, false );
        document.addEventListener( 'keyup', @onKeyUp, false );
        # window.addEventListener( 'mouseup', @onMouseUp, false );
        # document.addEventListener( 'touchstart', @onTouchStart, false );
        # document.addEventListener( 'touchmove', @onTouchMove, false );


        @$el.bind 'click', @onMouseClick
        @$el.bind 'mousedown', @onMouseDown
        @$el.bind 'mouseup', @onMouseUp
        @$el.bind 'mousemove', @onMouseMove
        @$el.bind 'mouseleave', @onMouseLeave
        @$el.bind 'mouseenter', @onMouseEnter
        # @$el.bind 'keydown', @onKeyDown
        @$el.bind 'touchstart', @onTouchStart
        @$el.bind 'touchend', @onTouchEnd
        @$el.bind 'touchmove', @onTouchMove


        # JordiRos: Hud for 1:1 rendering with three.js
        @hud = new Hud( @renderer, @APP_WIDTH, @APP_HEIGHT, false, false )

        @initComposer()
        @initDOF()
        
        @autoPerformance = new IFLAutomaticPerformanceAdjust
        @autoPerformance.steps.push 
            name : "DOF"
            object : @dofpost
            property : "enabled"
            enabled : @dofpost.enabled
            priority: 100

        @autoPerformance.steps.push
            name : "FXAA"
            object : @fxaa
            property : "enabled"
            enabled : @fxaa.enabled
            priority : 100


        @autoPerformance.steps.push 
            name : "Resolution = 1"
            enabled : if @renderResolutionMultiplier > 0.7 then true else false
            priority : 1
            disableFunc : => @renderResolutionMultiplier = 0.7

        @autoPerformance.steps.push 
            name : "Resolution = 0.7"
            enabled : if @renderResolutionMultiplier > 0.5 then true else false
            priority : 0
            disableFunc : => @renderResolutionMultiplier = 0.5

        # @autoPerformance.steps.push 
        #     name : "PostProcessing Pipeline"
        #     object : @composer
        #     property : "enabled"
        #     enabled : @composer.enabled
        #     priority : 0
            


        # @addChild @renderer.domElement

    initComposer:()->

        @renderTarget = new THREE.WebGLRenderTarget( @APP_WIDTH, @APP_HEIGHT )
        @renderTarget.generateMipmaps = false


        @composer = new THREE.EffectComposer( @renderer, @renderTarget )
        # @composer.enabled = if @oz().appView.displayQuality != "low" then true else false
        @composer.enabled = true

        @renderModel = new THREE.RenderPass( @scene, @camera, null, false, false )
        @effectBloom = new THREE.BloomPass( .39 )
        # @effectBloom.enabled = if @oz().appView.displayQuality != "low" then true else false
        @effectBloom.enabled = true

        # @effectFilm = new THREE.FilmPass 0.10, 0.20, @APP_HEIGHT*2, false
        # @effectFilm.enabled = false


        colorCorrectionShader = new IFLColorCorrectionShader
        colorCorrectionShader.name = "postprocessing_colorcorrectionshader"
        # colorCorrectionShader.uniforms["tSdiffuse"].value = @smallRenderTarget
        @colorCorrection = new THREE.ShaderPass( colorCorrectionShader );
        @colorCorrection.uniforms["enableVolumetricLight"].value = 0


        fxaashader = THREE.ShaderExtras[ "fxaa" ]
        fxaashader.name = "postprocessing_fxaa"
        @fxaa = new THREE.ShaderPass( fxaashader );

        @fxaa.enabled = if @oz().appView.displayQuality == "hi" then true else false
        # @fxaa.enabled = true
        @fxaa.uniforms['resolution'].value = new THREE.Vector2( 1 / @APP_WIDTH, 1 / @APP_HEIGHT )
        

        # @hblur = new THREE.ShaderPass( THREE.ShaderExtras[ "horizontalTiltShift" ] );
        # @vblur = new THREE.ShaderPass( THREE.ShaderExtras[ "verticalTiltShift" ] );
        # @vblur.enabled = false
        # @hblur.enabled = false

        # @hblur.uniforms[ 'h' ].value = 2 / @APP_WIDTH;
        # @vblur.uniforms[ 'v' ].value = 2 / @APP_HEIGHT;

        # @hblur.uniforms[ 'r' ].value = @vblur.uniforms[ 'r' ].value = 0.5;

        @composer.addPass( @renderModel );

        # @composer.addPass( gammainput );

        @composer.addPass( @effectBloom );
        @composer.addPass( @fxaa );
        # @composer.addPass( @effectFilm );
        # @composer.addPass( @hblur );
        # @composer.addPass( @vblur );   


        @composer.addPass( @colorCorrection );
        @colorCorrection.renderToScreen = true   	


    initDOF:()-> 
        @dofpost = 
            enabled     : @oz().appView.dofEnabled
            focus       : 0.68
            aperture    : 0.019
            maxblur     : 0.007
            camerafar   : 500
            cameranear  : 0.1

        @dofpost.material_depth = new THREE.MeshDepthMaterial();
        @dofpost.material_depth.name = "postprocessing_depthshader"
        # @dofpost.material_depth.alphaTest = 0.5
        @dofpost.scene = new THREE.Scene();
        @dofpost.camera = new THREE.OrthographicCamera( @APP_WIDTH / - 2, @APP_WIDTH / 2,  @APP_HEIGHT / 2, @APP_HEIGHT / - 2, -10000, 10000 );
        @dofpost.camera.position.z = 100;
        @dofpost.camera.name = "dofCamera"
        @dofpost.scene.add( @dofpost.camera );
        # @dofpost.enabled = true

        pars =  
            minFilter: THREE.LinearFilter
            magFilter: THREE.LinearFilter
            format: THREE.RGBFormat 

        @dofpost.rtTextureDepth = new THREE.WebGLRenderTarget( @APP_WIDTH , @APP_HEIGHT , pars );
        @dofpost.rtTextureColor = new THREE.WebGLRenderTarget( @APP_WIDTH, @APP_HEIGHT, pars );

        bokeh_shader = THREE.BokehShader

        @dofpost.bokeh_uniforms = THREE.UniformsUtils.clone( bokeh_shader.uniforms );

        # @dofpost.bokeh_uniforms[ "tColor" ].value = @dofpost.rtTextureColor;
        @dofpost.bokeh_uniforms[ "tDepth" ].value = @dofpost.rtTextureDepth;
        @dofpost.bokeh_uniforms[ "focus" ].value = @dofpost.focus;
        @dofpost.bokeh_uniforms[ "aperture" ].value = @dofpost.aperture;
        @dofpost.bokeh_uniforms[ "maxblur" ].value = @dofpost.maxblur;
        @dofpost.bokeh_uniforms[ "aspect" ].value = @APP_WIDTH / @APP_HEIGHT;

        @dofpost.materialBokeh = new THREE.ShaderMaterial( {

            uniforms: @dofpost.bokeh_uniforms,
            vertexShader: bokeh_shader.vertexShader,
            fragmentShader: bokeh_shader.fragmentShader

        } );

        @dofpost.materialBokeh.name = "postprocessing_bokehshader"

        @dofpost.quad = new THREE.Mesh( new THREE.PlaneGeometry( @APP_WIDTH, @APP_HEIGHT ), @dofpost.materialBokeh );
        @dofpost.quad.name = "postprocessing_dof_quad"
        @dofpost.quad.position.z = - 1000;
        @dofpost.scene.add( @dofpost.quad );        



    initGUI:(settings)=>

        

        @gui = new dat.GUI {width:400,autoPlace:false,load:settings}
        @gui.remember @scene.fog
        @gui.remember @params
        @gui.remember @colorCorrection.uniforms.vignetteOffset
        @gui.remember @colorCorrection.uniforms.vignetteDarkness
        @gui.remember @dofpost
        @gui.remember @fxaa
        @gui.remember @effectBloom
        @gui.remember @effectBloom.screenUniforms.opacity
        # @gui.remember @effectFilm
        # @gui.remember @vblur
        # @gui.remember @hblur

        fogFolder = @gui.addFolder("Fog")
        fogFolder.add(@scene.fog, 'near',0,1000).name('Fog Near')
        fogFolder.add(@scene.fog, 'far',100,2000).name('Fog Far')
        fogFolder.addColor(@params, 'fogcolor').name('Fog Color').onChange @onFogColorChange 


        
        postProcessingFolder = @gui.addFolder("Post Processing")
        
        colorCorrFolder = postProcessingFolder.addFolder("Color Correction")
        colorCorrFolder.addColor(@params, 'colorCorrectionPow').name('Color Power').onChange                       @onColorCorrectionChange
        colorCorrFolder.add(@params, 'colorCorrectionPowM',0,2).name('Color Power Intensity').onChange             @onColorCorrectionChange             
        colorCorrFolder.addColor(@params, 'colorCorrectionMul').name('Color Multiplier').onChange                  @onColorCorrectionChange
        colorCorrFolder.add(@params, 'colorCorrectionMulM',0,2).name('Color Multiplier Intensity').onChange        @onColorCorrectionChange     
        colorCorrFolder.add(@params, 'colorCorrectionSaturation',-100,100).name('Saturation').onChange             @onColorCorrectionChange   
        colorCorrFolder.addColor(@params, 'colorCorrectionSaturationColors').name('Saturated Colors').onChange     @onColorCorrectionChange
        
        colorCorrFolder.add(@colorCorrection.uniforms.vignetteOffset, 'value',0,10).name('Vignette Offset')
        colorCorrFolder.add(@colorCorrection.uniforms.vignetteDarkness, 'value',0,10).name('Vignette Darkness')   
       

        DOFFolder = postProcessingFolder.addFolder("DOF")
        DOFFolder.add( @dofpost, 'enabled').name('Enable DOF')
        DOFFolder.add( @dofpost, "focus", 0.0, 3.0 ).name('DOF Focus').onChange              @onDOFChange
        DOFFolder.add( @dofpost, "aperture", 0.001, 0.04 ).name('DOF Aperture').onChange     @onDOFChange
        DOFFolder.add( @dofpost, "maxblur", 0.0, 0.03 ).name('DOF MaxBlur').onChange         @onDOFChange    
        DOFFolder.add( @dofpost, "cameranear", 0.0, 100 ).name('DOF Camera Near')
        DOFFolder.add( @dofpost, "camerafar", 100, 5000 ).name('DOF Camera Far')


        postProcessingFolder.add(@composer, 'enabled').name('Enable PostProcessing')
        postProcessingFolder.add(@, 'renderResolutionMultiplier', 0.1, 1).step(0.1).name('Resolution').onChange( (val)=> @onResize() )
        postProcessingFolder.add(@fxaa, 'enabled').name('Enable FXAA')
        # postProcessingFolder.add(@effectFilm, 'enabled').name('Enable Film Grain')
        # postProcessingFolder.add(@vblur, 'enabled').name('Enable Vertical Blur')
        # postProcessingFolder.add(@hblur, 'enabled').name('Enable Horizontal Blur')
        postProcessingFolder.add(@effectBloom, 'enabled').name('Enable Bloom')
        postProcessingFolder.add(@effectBloom.screenUniforms.opacity, 'value',0,10).name('Bloom Power')



        @guicontainer = $('<div/>')
        @guicontainer.dispose = ()-> return
        @guicontainer.css
            "position" : "absolute"
            "right" : "0px"
            "top" : "0px"

        @guicontainer.append @gui.domElement   





    onFogColorChange    : (value) => 
        @scene.fog.color.copy(@stringToColor(value))

    onColorCorrectionChange    : (value) => 

        return unless @colorCorrection?


        pow  = @params.colorCorrectionPowM
        powColor =  @stringToColor(@params.colorCorrectionPow)
        powR = 1- powColor.r
        powG = 1- powColor.g
        powB = 1- powColor.b

        # console.log "POW: #{pow}, R: #{powR}, G:#{powG}, B: #{powB}"

        @colorCorrection.uniforms['powRGB'].value.set( pow * powR, pow * powG, pow * powB);

        mul = @params.colorCorrectionMulM
        mulColor =  @stringToColor(@params.colorCorrectionMul)
        mulR = mulColor.r
        mulG = mulColor.g
        mulB = mulColor.b

        # console.log "MUL: #{mul}, R: #{mulR}, G:#{mulG}, B: #{mulB}"

        @colorCorrection.uniforms['mulRGB'].value.set(mul * mulR,mul * mulG,mul * mulB);

        sat = -@params.colorCorrectionSaturation/100
        satColor = @stringToColor(@params.colorCorrectionSaturationColors)
        satR = 1 - satColor.r
        satG = 1 - satColor.g
        satB = 1 - satColor.b

        # console.log "SAT: #{sat}, R: #{satR}, G:#{satG}, B: #{satB}"

        @colorCorrection.uniforms['saturation'].value.set(sat * satR,sat * satG,sat * satB, 1);

    stringToColor:(str)->

        # if str.substr
        str2 = str.substr(1)
        num = parseInt("0x#{str2}")
        # else

        col =  new THREE.Color()
        col.setHex(num)
        return col 

    onDOFChange    : (value) => 
        @dofpost.bokeh_uniforms[ "focus" ].value = @dofpost.focus;
        @dofpost.bokeh_uniforms[ "aperture" ].value = @dofpost.aperture;
        @dofpost.bokeh_uniforms[ "maxblur" ].value = @dofpost.maxblur;        


    onMouseClick:(event) =>
        return unless @enableMouse

    onMouseDown:(event) =>
        return unless @enableMouse
        @mouseDown = true
    
    onMouseUp:(event) =>
        return unless @enableMouse
        @mouseDown = false   

    onKeyDown:( event ) => 
        return unless @enableMouse

        if event.ctrlKey && event.keyCode == 73 && @guicontainer?
            @GUIADDED = true
            @oz().appView.addChild @guicontainer  
            # @addChild @guicontainer  
        
        if event.ctrlKey && event.keyCode == 66
            if !@capturer
                @capturer = new CCapture( { framerate: 30 } )
                @capturer.start()
            else
                console.log( "Video URL (paste in browser): " + @capturer.save() )
                @capturer = null

        @keyDowns[event.keyCode] = true
        @lastKeyPress = @clock.oldTime

    onKeyUp:( event ) => 
        return unless @enableMouse

        @keyDowns[event.keyCode] = false 
        @lastKeyPress = @clock.oldTime

    onMouseEnter:( event ) => 
        @mouseLeft = false
        
    onMouseLeave:( event ) => 
        @mouseLeft = true

    onMouseMove:( event ) => 
        return unless @enableMouse

        @mouseX = event.pageX - @APP_HALF_X
        @mouseY = event.pageY - @APP_HALF_Y

        @pickMouse.x = ( event.clientX / @APP_WIDTH ) * 2 - 1;
        @pickMouse.y = - ( event.clientY / @APP_HEIGHT ) * 2 + 1;

    onTouchEnd:( event ) => 
        return unless @enableMouse
        @mouseDown = false        

    onTouchStart:( event ) => 
        return unless @enableMouse
        @mouseDown = true

        if event.touches.length == 1
            event.preventDefault()
            @mouseX = event.touches[ 0 ].pageX - @APP_HALF_X
            @mouseY = event.touches[ 0 ].pageY - @APP_HALF_Y
    
    onTouchMove:( event ) =>
        return unless @enableMouse

        if event.touches.length == 1
            event.preventDefault()
            @mouseX = event.touches[ 0 ].pageX - @APP_HALF_X
            @mouseY = event.touches[ 0 ].pageY - @APP_HALF_Y

    handleVirtualMouse:->
        # 38 up
        # 40 down
        # 37 left
        # 39 right

        xAxisDown = false
        yAxisDown = false

        if @keyDowns[38] == true
            yAxisDown = true
            @elasticVirtMouseY.aimAt(-@APP_HEIGHT/2)

        if @keyDowns[40] == true
            yAxisDown = true
            @elasticVirtMouseY.aimAt(@APP_HEIGHT/2)


        if @keyDowns[37] == true
            xAxisDown = true
            @elasticVirtMouseX.aimAt(-@APP_WIDTH / 2)

        if @keyDowns[39] == true
            xAxisDown = true
            @elasticVirtMouseX.aimAt(@APP_WIDTH / 2)
             
        if !xAxisDown
            @elasticVirtMouseX.aimAt(0)
        if !yAxisDown
            @elasticVirtMouseY.aimAt(0)

        @elasticVirtMouseY.step(@delta)
        @elasticVirtMouseX.step(@delta)

        if @clock.oldTime - @lastKeyPress < 1000
            @mouseX = @elasticVirtMouseX._value
            @mouseY = @elasticVirtMouseY._value

        # console.log @elasticVirtMouseX._value + " : "+@elasticVirtMouseY._value        

    onEnterFrame: =>
        @delta = @clock.getDelta()
        @handleVirtualMouse()
        @autoPerformance.update(@delta)           
        TWEEN.update()
        THREE.AnimationHandler.update( @delta )
        @updateControls()
        # if !skipRender
        #     @renderer.clear()
        #     @doRender()
        
        return null

    updateControls:->
        if @controls? && @enableMouse
            if !@controls.hasOwnProperty("enabled") || (@controls.hasOwnProperty("enabled") && @controls.enabled)
                @controls.update( @delta )     
        return null   

    

    doRender:->

        if @dofpost.enabled


            # Render composer effects (disable render model as we already did it) 
            # @renderModel.enabled = true

            # @composer.renderTarget1.clear()
            # @composer.renderTarget2.clear()

            if @composer.enabled
                @colorCorrection.renderToScreen = false
                @renderer.clearTarget(@renderTarget,true,true,true)
                @composer.render(@delta)
            else
                # Render scene into texture
                @renderer.clearTarget(@renderTarget,true,true,true)
                @renderer.render( @scene, @camera, @dofpost.rtTextureColor );
            

            

            # disable plugins
            @pPost = @renderer.renderPluginsPost
            @renderer.renderPluginsPost = @emptyRenderPluginPost


            # override scene material
            @scene.overrideMaterial = @dofpost.material_depth;
            
            # Adjust camera far/near for depth rendering
            camerafar = @camera.far
            cameranear = @camera.near
            @camera.far = @dofpost.camerafar
            @camera.near = @dofpost.cameranear
            @camera.updateProjectionMatrix()

            # Render depth into texture
            @renderer.render( @scene, @camera, @dofpost.rtTextureDepth, true );

            #restore camera far/near
            @camera.far = camerafar
            @camera.near = cameranear
            @camera.updateProjectionMatrix()

            # undo override scene material
            @scene.overrideMaterial = null;



            # Render bokeh composite into first composer texture
            # @renderer.render( @dofpost.scene,  @dofpost.camera, @composer.renderTarget2, true );
           
            if @composer.enabled

                # @dofpost.bokeh_uniforms[ "tColor" ].value = @renderTarget
                numShaderPasses = 0;
                if @fxaa.enabled then numShaderPasses++
                # if @vblur.enabled then numShaderPasses++
                # if @hblur.enabled then numShaderPasses++
                # if @effectFilm.enabled then numShaderPasses++


                if numShaderPasses % 2 == 0
                    @dofpost.bokeh_uniforms.tColor.value = @composer.renderTarget1
                else
                    @dofpost.bokeh_uniforms.tColor.value = @composer.renderTarget2
            else
                 @dofpost.bokeh_uniforms.tColor.value = @dofpost.rtTextureColor

            # Render bokeh composite to screen
            @renderer.render( @dofpost.scene,  @dofpost.camera, null, true );


            @renderer.renderPluginsPost = @pPost


        else
            if @composer.enabled
                @colorCorrection.renderToScreen = true
                @renderer.clearTarget(@renderTarget,true,true,true)
                @composer.render( @delta )
            else
                @renderer.render( @scene, @camera, null, true )        

    onResize: =>

        # console.log "ONRESIZE"

        @APP_WIDTH = $(window).width();
        @APP_HEIGHT = $(window).height();
        @APP_HALF_X = @APP_WIDTH/2
        @APP_HALF_Y = @APP_HEIGHT/2

        @camera.aspect = @APP_WIDTH / @APP_HEIGHT
        @camera.updateProjectionMatrix()
        @renderer.setSize( @APP_WIDTH, @APP_HEIGHT )

        

        @fxaa.uniforms['resolution'].value = new THREE.Vector2( 1 / (@APP_WIDTH * @renderResolutionMultiplier) , 1 / (@APP_HEIGHT * @renderResolutionMultiplier) )
        pars =  
            minFilter: THREE.LinearFilter
            magFilter: THREE.LinearFilter
            format: THREE.RGBFormat 

        @dofpost.rtTextureDepth = new THREE.WebGLRenderTarget( (@APP_WIDTH * @renderResolutionMultiplier) / 2, (@APP_HEIGHT * @renderResolutionMultiplier) / 2, pars )
        @dofpost.bokeh_uniforms[ "tDepth" ].value = @dofpost.rtTextureDepth
        @dofpost.rtTextureColor = new THREE.WebGLRenderTarget( @APP_WIDTH * @renderResolutionMultiplier, @APP_HEIGHT * @renderResolutionMultiplier, pars );
        @dofpost.bokeh_uniforms[ "aspect" ].value = @APP_WIDTH / @APP_HEIGHT;

        # @hblur.uniforms[ 'h' ].value = 2 / @APP_WIDTH;
        # @vblur.uniforms[ 'v' ].value = 2 / @APP_HEIGHT;

        @hud.resize( @APP_WIDTH, @APP_HEIGHT )

        if @composer?
            @renderTarget  = new THREE.WebGLRenderTarget( @APP_WIDTH * @renderResolutionMultiplier, @APP_HEIGHT * @renderResolutionMultiplier )
            @renderTarget.generateMipmaps = false
            @composer.reset( @renderTarget )


        if @lensFlare?
            for flare in @lensFlare.lensFlares
                if flare.originalSize?
                    flare.size = flare.originalSize * @renderResolutionMultiplier
        # try controls?.handleResize()

        return

    ###
    FRAMEWORK
    ###

    pause:()->
        super()
        @enableMouse = false
        @autoPerformance.reset()
        $('body').css('cursor','auto')
        
    resume:()->
        super()
        @enableMouse = true
        @autoPerformance.reset()

    changeView : (view) =>
        # TODO change the camera and call 'onCameraReady' once the transition is finished
        # setTimeout @onCameraReady, 3000
        null

    onCameraReady : () =>
        @oz().appView.onCameraReady()

    onWorldProgress : (percentage) =>
        @trigger 'onWorldProgress', percentage

    onWorldLoaded : =>
        @trigger 'onWorldLoaded'


    handleAnimatedSprites:() ->
        if @animatedSprites
            
            for sprite in @animatedSprites

                sprite.material.time += @delta

                if sprite.material.time > sprite.material.frametime
                    sprite.material.time = 0
                    sprite.material.spritenum += 1

                    if  sprite.material.spritenum == sprite.material.totalframes
                        sprite.material.spritenum = 0


                    posx = sprite.material.spritenum % sprite.material.spritex
                    posy = Math.floor(sprite.material.spritenum / sprite.material.spritex)

                    offX = posx / sprite.material.spritex
                    offY = posy / sprite.material.spritey
                    rX = 1 / sprite.material.spritex
                    rY = 1 / sprite.material.spritey

                    if sprite.material.uniforms
                        if sprite.material.uniforms.offsetRepeat
                            sprite.material.uniforms.offsetRepeat.value.x = offX
                            sprite.material.uniforms.offsetRepeat.value.y = offY
                            sprite.material.uniforms.offsetRepeat.value.z = rX
                            sprite.material.uniforms.offsetRepeat.value.w = rY

                    sprite.material.map.offset.x = offX
                    sprite.material.map.offset.y = offY
                    sprite.material.map.repeat.x = rX
                    sprite.material.map.repeat.y = rY
        return null


    cursorPointer : false
    handlePointer:->
        if !@isGoingToInteractive
            hasPicked = false
            for obj of @mouseOverObjects
                hasPicked = true
                break
            if hasPicked
                if !@cursorPointer
                    $('body').css('cursor','pointer')
                    @cursorPointer = true
            else if @cursorPointer
                @cursorPointer = false
                $('body').css('cursor','auto')
        else if @cursorPointer
            @cursorPointer = false
            $('body').css('cursor','auto')


    # pickingIntersections : []

    checkPicking:->
        return unless @sceneDescendants?

        @pickVector.set( @pickMouse.x, @pickMouse.y, 1 )

        @projector.unprojectVector( @pickVector, @camera )

        @pickVector.subSelf( @camera.position )
        @pickVector.normalize()
        @pickRay.origin.copy(@camera.position)
        @pickRay.direction.copy(@pickVector)



        # testobjects = [] 
        # for object in @sceneDescendants when object.pickable == true
        #     testobjects.push object


        intersections = @pickRay.intersectObjects( @pickableObjects )

        ret  = []
        
        for intersection, index in intersections
            ret[intersection.object.name] = intersection

        return ret

    gotoPositionOnPath:(view)->
        if @settings.navigationPoints[view]
            obj = {pos:@mouseInteraction.currentIndex + @mouseInteraction.currentProgress}
            tween = new TWEEN.Tween(obj).to({pos:@settings.navigationPoints[view].index}, 2000).easing( TWEEN.Easing.Cubic.InOut )
            tween.onUpdate =>
                @mouseInteraction.goToIndexAndPosition(obj.pos)
            tween.start()
            return true

        return false
    
    randRange:(minNum, maxNum)-> 
        return Math.random() * (maxNum - minNum + 1) + minNum

    dispose :=>
        # @remove @renderer.domElement
        # @remove @guicontainer
        # document.removeEventListener( 'mousemove', @onMouseMove, false );
        # document.removeEventListener( 'mousedown', @onMouseClick, false );

        $('body').css('cursor','auto')

        @$el.unbind 'click', @onMouseClick
        @$el.unbind 'mousedown', @onMouseDown
        @$el.unbind 'mouseup', @onMouseUp
        @$el.unbind 'mousemove', @onMouseMove
        @$el.unbind 'mouseleave', @onMouseLeave
        @$el.unbind 'mouseenter', @onMouseEnter
        @$el.unbind 'touchstart', @onTouchStart
        @$el.unbind 'touchend', @onTouchEnd
        @$el.unbind 'touchmove', @onTouchMove        
        document.removeEventListener( 'keydown', @onKeyDown, false );
        document.removeEventListener( 'keyup', @onKeyUp, false );
        # window.removeEventListener( 'mouseup', @onMouseUp, false );

        
        @renderer.deallocateRenderTarget(@renderTarget)
        @renderer.deallocateRenderTarget(@dofpost.rtTextureDepth)
        @renderer.deallocateRenderTarget(@dofpost.rtTextureColor)
        @renderer.deallocateRenderTarget(@composer.renderTarget1)
        @renderer.deallocateRenderTarget(@composer.renderTarget2)

        @renderer.deallocateObject( @dofpost.quad )
        @renderer.deallocateMaterial( @dofpost.materialBokeh )
        @renderer.deallocateMaterial( @dofpost.material_depth )

        # if we do this, the next scene will not work... -_-
        # THREE.SceneUtils.traverseHierarchy( @scene, (child)=> try @renderer.deallocateObject( child ) )
        @renderer.onError = null
        
        memory = @renderer.info.memory
        descendants = @scene.getDescendants()
        
        for object in descendants
            break if memory.geometries == 0
            @renderer.deallocateObject( object )

        @emptyRenderPluginPost = null
        @autoPerformance = null
        @clock = null
        @camera  = null
        @scene  = null
        @renderer = null
        @hud  = null
        @composer = null
        @gui  = null
        @oz().appView.remove @guicontainer
        @guicontainer = null

        @releasePointLock()

        for obj of @
            try @[obj].dispose()
            delete @[obj]


        # console.info "[Base3DChapter] Textures left after Dispose: #{memory.textures}"
        # console.info "[Base3DChapter] Geometries left after Dispose: #{memory.geometries}"
        # console.info "[Base3DChapter] Programs left after Dispose: #{memory.programs}"
        return null


    # deepDelete:(obj)->
    #     for prop in obj
    #         @deepDelete(obj[prop])
    #         delete obj[prop]
    #     return
