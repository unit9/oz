class IFLMaterialManager
    
    params : null
    matLib : null
    texLib : null
    onProgress : null
    onComplete : null
    ddsBasePath : null
    jpgBasePath : null
    auxBasePath : null
    pickables : null
    loadTextureIndex : 0
    loadTextures: null
    loadedTextures :null
    renderer : null
    skyCubeTexture : null
    skyCubePath : null
    skyCubeFormat : null
    enableDiffuse : true
    materialInstancerNames : null
    textureQuality : null
    loadingPercentages : null
    forcePNGTextures : false

    constructor:(params)->
        @init(params) if params?
        @texLib = []
        @matLib = []

    init:(params)->
        @params = params
        @textureQuality = if params.textureQuality? then params.textureQuality else "med"
        @loadTextures = if params.loadTextures? then params.loadTextures else []
        @pickables = if params.pickables? then params.pickables else {}
        @onProgress = if params.onProgress? then params.onProgress else {}
        @onComplete = if params.onComplete? then params.onComplete else {}
        
        @ddsBasePath = if params.ddsBasePath? then params.ddsBasePath else ""
        @auxBasePath = if params.auxBasePath? then params.auxBasePath else ""
        @jpgBasePath = if params.jpgBasePath? then params.jpgBasePath else ""

        ddsQuality = @ddsBasePath.indexOf("#QUALITY#")
        if ddsQuality != -1
            @ddsBasePath = @ddsBasePath.substr(0,ddsQuality) + @textureQuality

        auxQuality = @auxBasePath.indexOf("#QUALITY#")
        if auxQuality != -1
            @auxBasePath = @auxBasePath.substr(0,auxQuality) + @textureQuality

        @renderer = if params.renderer? then params.render else null
        @skyCubePath = if params.skyCubePath? then params.skyCubePath else "/"
        @skyCubeFormat = if params.skyCubeFormat? then params.skyCubeFormat else ".png"
        @materialInstancerNames = if params.materialInstancerNames? then params.materialInstancerNames else {default:"instanceSimpleMaterial"}
        return null

    load:->
        urls = [
            @skyCubePath + 'posx' + @skyCubeFormat
            @skyCubePath + 'negx' + @skyCubeFormat
            @skyCubePath + 'posy' + @skyCubeFormat
            @skyCubePath + 'negy' + @skyCubeFormat
            @skyCubePath + 'negz' + @skyCubeFormat
            @skyCubePath + 'posz' + @skyCubeFormat
        ]

        @skyCubeTexture = THREE.ImageUtils.loadTextureCube( urls )
        @skyCubeTexture.format = THREE.RGBFormat


        @loadedTextures = []
        @loadingPercentages = []

        for url,index in @loadTextures
            
            # replace .dds with png when forcePNGTextures is true
            if @forcePNGTextures
                ddsPathIndex = url.indexOf(".dds")
                if ddsPathIndex != -1
                    @loadTextures[index] = url = url.substr(0,ddsPathIndex) + ".png";


            if url.indexOf("/") != -1
                # load full path texture
                if url.indexOf(".dds") != -1
                    CustomImageUtils.loadCompressedTexture( "#{url}", null, @onTextureComplete, @onTextureProgress, null, false, index );
                else
                    tex = CustomImageUtils.loadTexture( "#{url}", null, @onTextureComplete, @onTextureProgress, null, index  );
                    tex.flipY = false   
            else
                # load basepath texture
                if url.indexOf(".dds") != -1
                    CustomImageUtils.loadCompressedTexture( "#{@ddsBasePath}/#{url}", null, @onTextureComplete, @onTextureProgress, null, false, index );
                else
                    tex = CustomImageUtils.loadTexture( "#{@ddsBasePath}/#{url}", null, @onTextureComplete, @onTextureProgress, null, index  );
                    tex.flipY = false   


        return null




    onTextureProgress:(progress,index)=>
        singletexProg = progress / ( 1 / @loadTextures.length )

        @loadingPercentages[index] = progress

        totalpercentage = 0
        for i in [0...@loadTextures.length] by 1
            texPerc = @loadingPercentages[i]
            totalpercentage += if texPerc? then texPerc else 0

        totalpercentage /= @loadTextures.length

        # singleprog : 1 = progress : x

        @onProgress?(totalpercentage)

    numLoadedTextures : 0

    onTextureComplete:(texture,index)=>
        @loadedTextures[index] = texture
        @numLoadedTextures++

        if @numLoadedTextures == @loadTextures.length
            @onComplete?()
            return
        return



    # onSkyComplete:(sky)=>
    #     @loadTextureIndex = 0
    #     @loadedTextures = []
    #     # @loadNextTexture() 
    #     @currentBlockIndex = -3
    #     @currentBlockLoaded = 3

    #     @startBlockLoading()

    # startBlockLoading:()=>

    #     if @currentBlockIndex + @currentBlockLoaded == @loadTextures.length
    #          @onComplete?()
    #          return

    #     if @currentBlockLoaded == 3
    #         @currentBlockIndex += 3
    #         @currentBlockLoaded = 0

    #         @block1LoadedPercentage = 0
    #         @block2LoadedPercentage = 0
    #         @block3LoadedPercentage = 0            

    #         tex1 = @loadTextures[@currentBlockIndex]
    #         if tex1?
    #             if tex1.indexOf(".dds") != -1
    #                 CustomImageUtils.loadCompressedTexture( "#{@ddsBasePath}/#{tex1}", null, @onBlockTextureComplete1, @onBlockTextureProgress1 );
    #             else
    #                 CustomImageUtils.loadTexture( "#{@jpgBasePath}/#{tex1}", null, @onBlockTextureComplete1, @onBlockTextureProgress1 );

    #         tex2 = @loadTextures[@currentBlockIndex+1]
    #         if tex2?
    #             if tex2.indexOf(".dds") != -1
    #                 CustomImageUtils.loadCompressedTexture( "#{@ddsBasePath}/#{tex2}", null, @onBlockTextureComplete2, @onBlockTextureProgress2 );
    #             else
    #                 CustomImageUtils.loadTexture( "#{@jpgBasePath}/#{tex2}", null, @onBlockTextureComplete2, @onBlockTextureProgress2 );

    #         tex3 = @loadTextures[@currentBlockIndex+2]
    #         if tex3?
    #             if tex3.indexOf(".dds") != -1
    #                 CustomImageUtils.loadCompressedTexture( "#{@ddsBasePath}/#{tex3}", null, @onBlockTextureComplete3, @onBlockTextureProgress3 );
    #             else
    #                 CustomImageUtils.loadTexture( "#{@jpgBasePath}/#{tex3}", null, @onBlockTextureComplete3, @onBlockTextureProgress3 );

    #     return null      




    # onBlockTextureComplete1:(texture)=>
    #     @loadedTextures[@currentBlockIndex] = texture
    #     @currentBlockLoaded++
    #     @startBlockLoading()
    #     return null

    # onBlockTextureComplete2:(texture)=>
    #     @loadedTextures[@currentBlockIndex+1] = texture
    #     @currentBlockLoaded++
    #     @startBlockLoading()
    #     return null

    # onBlockTextureComplete3:(texture)=>
    #     @loadedTextures[@currentBlockIndex+2] = texture
    #     @currentBlockLoaded++
    #     @startBlockLoading()
    #     return null

    # onBlockTextureProgress1:(progress)=>
    #     @block1LoadedPercentage = progress
    #     @onBlockProgress()
    #     return null

    # onBlockTextureProgress2:(progress)=>
    #     @block2LoadedPercentage = progress
    #     @onBlockProgress()
    #     return null

    # onBlockTextureProgress3:(progress)=>
    #     @block3LoadedPercentage = progress
    #     @onBlockProgress()
    #     return null

    # onBlockProgress:=>
    #     totalBlockPercentage = ( @block1LoadedPercentage + @block2LoadedPercentage + @block3LoadedPercentage ) / 3

    #     @onProgress?((@currentBlockIndex+totalBlockPercentage)/@loadTextures.length)
    #     return null


    getPreloadedTexture:(texName)->
        

        # force filename substitution when forcePNGTextures is true
        if @forcePNGTextures
            ddsPathIndex = texName.indexOf(".dds")
            if ddsPathIndex != -1
                texName = texName.substr(0,ddsPathIndex) + ".png";


        # return cached texture if found
        index = @loadTextures.indexOf(texName)
        return @loadedTextures[index] if index != -1



        # load texture otherwise

        if texName.indexOf("/") != -1
            #custom path
            if texName.indexOf(".dds") != -1
                return CustomImageUtils.loadCompressedTexture( "#{texName}" )
            else
                tex = CustomImageUtils.loadTexture( "#{texName}" )
                tex.flipY = false
                return tex
        
        else
            #preloaded path
            if texName.indexOf(".dds") != -1
                return CustomImageUtils.loadCompressedTexture( "#{@ddsBasePath}/#{texName}" )
            else
                tex = CustomImageUtils.loadTexture( "#{@ddsBasePath}/#{texName}" )
                tex.flipY = false
                return tex

        return null
            

    # loadNextTexture:(texture)=>

    #     if texture?
    #         # @renderer.setTexture(texture,0)
    #         @loadedTextures.push(texture)

    #     tex = @loadTextures[@loadTextureIndex]
    #     @loadTextureIndex++
    #     if @loadTextureIndex <= @loadTextures.length
    #         # loaded : len = x : 100
    #         @onProgress?(@loadTextureIndex/@loadTextures.length)

    #         if tex.indexOf(".dds") != -1
    #             # console.log "#{@loadTextureIndex} compressa"
    #             CustomImageUtils.loadCompressedTexture( "#{@ddsBasePath}/#{tex}", null, @loadNextTexture, @loadingTextureProgress );
    #         else
    #             # console.log "#{@loadTextureIndex} non compressa"
    #             CustomImageUtils.loadTexture( "#{@jpgBasePath}/#{tex}", null, @loadNextTexture, @loadingTextureProgress );
    #     else
    #         @onComplete?()


    # loadingTextureProgress:(progress)=>
    #     @onProgress?((@loadTextureIndex+progress)/@loadTextures.length)


    instanceMaterial:(subMesh,meshname)=>

        while meshname.indexOf("1") == meshname.length-1
            meshname = meshname.substr(0,meshname.length-1)


        for match,func of @materialInstancerNames

            if meshname.toLowerCase().indexOf(match.toLowerCase()) != -1

                switch func
                    when "simple" then return @instanceSimpleMaterial(subMesh,meshname)
                    when "simple_doublelightmap" then return @instanceSimpleDobleLightmapMaterial(subMesh,meshname)
                    when "terrain" then return @instanceTerrainMaterial(subMesh,meshname)
                    when "meshbasic" then return @instanceMeshBasicMaterial(subMesh,meshname)
                    when "fresnel" then return @instanceFresnelMaterial(subMesh,meshname)
                    when "fresnel_doublelightmap" then return @instanceFresnelDoubleLightmapMaterial(subMesh,meshname)
                break

        return @instanceSimpleMaterial(subMesh,meshname)


    applyMaterialOverrides:(material,meshname)->

        overrides = @getMaterialOverrides(meshname)

        for settingName,settingValue of overrides
            if material[settingName]? then material[settingName] = settingValue
            material.uniforms?[settingName]?.value = settingValue
        return null
        #other settings?    


    getMaterialOverrides:(meshname)->
        ret = []
        for match,settings of @params.materialOverrides
            if meshname.toLowerCase().indexOf(match.toLowerCase()) != -1
                for settingName,settingValue of settings 
                    ret[settingName] = settingValue
            
        return ret
                         



    instanceTerrainMaterial:(subMesh,meshname)=>
        # console.log "instanced terrain mat for #{meshname}"

        overrides = @getMaterialOverrides(meshname)

        shader = new IFLTerrainLambertShader
        
        uniforms = THREE.UniformsUtils.clone( shader.uniforms )
        uniforms[ "ambient" ].value =       new THREE.Color( 0xFFFFFF )
        uniforms[ "diffuse" ].value =       new THREE.Color( 0xFFFFFF )


        blendMap =  @getPreloadedTexture("terrain_blend.dds") 
        lightex  =  @getPreloadedTexture("terrain_lightmap.dds") 

        difftex  =  @getPreloadedTexture("terrain_base.dds") 
        difftexR =  @getPreloadedTexture("terrain_diffuseR.dds") 
        difftexG =  @getPreloadedTexture("terrain_diffuseG.dds") 
        difftexB =  @getPreloadedTexture("terrain_diffuseB.dds")

        # difftex.magFilter = difftexR.magFilter = difftexG.magFilter = difftexB.magFilter = THREE.LinearFilter
        # difftex.minFilter = difftexR.minFilter = difftexG.minFilter = difftexB.minFilter = THREE.NearestMipMapNearestFilter
        difftex.anisotropy = difftexR.anisotropy = difftexG.anisotropy = difftexB.anisotropy = 16

        @texLib.push difftex
        @texLib.push difftexR
        @texLib.push difftexG
        @texLib.push difftexB
        @texLib.push blendMap

        difftex.flipY = blendMap.flipY = lightex.flipY = difftexR.flipY = difftexG.flipY = difftexB.flipY = false

        difftex.wrapS = difftex.wrapT = THREE.RepeatWrapping
        difftexR.wrapS = difftexR.wrapT = THREE.RepeatWrapping
        difftexG.wrapS = difftexG.wrapT = THREE.RepeatWrapping          
        difftexB.wrapS = difftexB.wrapT = THREE.RepeatWrapping
        
        uniforms[ "map" ].value =                   difftex
        uniforms[ "lightMap" ].value =              lightex
        uniforms[ "tBlendmap" ].value =             blendMap
        uniforms[ "tDiffuseR" ].value =             difftexR
        uniforms[ "tDiffuseG" ].value =             difftexG
        uniforms[ "tDiffuseB" ].value =             difftexB

        repeats = 20
        if overrides.offset_repeat?
            repeats = overrides.offset_repeat.z
        uniforms[ "offsetRepeat" ].value =          new THREE.Vector4( 0, 0, repeats, repeats )
        uniforms[ "offsetRepeatR" ].value =         new THREE.Vector4( 0, 0, repeats, repeats )
        uniforms[ "offsetRepeatG" ].value =         new THREE.Vector4( 0, 0, repeats, repeats )
        uniforms[ "offsetRepeatB" ].value =         new THREE.Vector4( 0, 0, repeats, repeats )
        uniforms[ "lightMapMultiplier" ].value = 2

        parameters = 
            fragmentShader: shader.fragmentShader
            vertexShader: shader.vertexShader
            uniforms: uniforms
            # lights: true

        material = new THREE.ShaderMaterial( parameters );
        material.map = difftex
        material.lightMap = lightex
        material.fog = true

        @applyMaterialOverrides(material,meshname)

        @matLib.push material

        return material

    instanceMeshBasicMaterial:(subMesh,meshname)=>
        mat = new THREE.MeshBasicMaterial({
            map: @getPreloadedTexture("#{meshname}_diff.dds") 
            })

        mat.map?.flipY = false
        mat.side = THREE.DoubleSide
        mat.fog = false
        mat.lights = false


        @texLib.push mat.map
        @matLib.push mat

        @applyMaterialOverrides(mat,meshname)
        return mat     


    instanceSimpleMaterial:(subMesh,meshname)=>
        shader = new IFLBasicShader
        uniforms = shader.uniforms

        params = {}
        params.fragmentShader   = shader.fragmentShader
        params.vertexShader     = shader.vertexShader
        params.uniforms         = uniforms   
        
        material = new THREE.ShaderMaterial( params );
        material.side = THREE.DoubleSide
        material.lights = false
        material.fog = true
        material.alphaTest = 0.5
        material.enableIllustration = false

        
        uniforms[ "diffuse" ].value             = new THREE.Color( 0xFFFFFF )

        overrides  = @getMaterialOverrides(meshname)
        if overrides["overrideMap"]?
            if overrides["overrideMap"] != "null"
                uniforms[ "map" ].value = material.map  = @getPreloadedTexture(overrides["overrideMap"])
        else
            uniforms[ "map" ].value = material.map  = @getPreloadedTexture("#{meshname}_diff.dds")
        uniforms[ "map" ].value?.flipY          = false
        uniforms[ "diffuseMultiplier"].value    = 1




        @texLib.push material.map
        @matLib.push material

        @applyMaterialOverrides(material,meshname)

        if material.enableIllustration != false
            uniforms[ "lightMap" ].value = material.lightMap = @getPreloadedTexture material.enableIllustration
            material.lightMap.flipY = false

        return material 


    instanceSimpleDobleLightmapMaterial:(subMesh,meshname)=>
        # console.log "doble lightmap instanced for #{meshname}"
        shader = new IFLBasicShaderDoubleLightmap
        uniforms = shader.uniforms

        params = {}
        params.fragmentShader   = shader.fragmentShader
        params.vertexShader     = shader.vertexShader
        params.uniforms         = uniforms   
        
        material = new THREE.ShaderMaterial( params );
        material.side = THREE.DoubleSide
        material.lights = false
        material.fog = true
        material.alphaTest = 0.5
        material.enableIllustration = false
        material.enableIllustration2 = false

        
        uniforms[ "diffuse" ].value             = new THREE.Color( 0xFFFFFF )

        overrides  = @getMaterialOverrides(meshname)
        if overrides["overrideMap"]?
            if overrides["overrideMap"] != "null"
                uniforms[ "map" ].value = material.map  = @getPreloadedTexture(overrides["overrideMap"])
        else
            uniforms[ "map" ].value = material.map  = @getPreloadedTexture("#{meshname}_diff.dds")
        uniforms[ "map" ].value?.flipY          = false
        uniforms[ "diffuseMultiplier"].value    = 1




        @texLib.push material.map
        @matLib.push material

        @applyMaterialOverrides(material,meshname)

        if material.enableIllustration != false
            uniforms[ "lightMap" ].value = material.lightMap = @getPreloadedTexture(material.enableIllustration)
            material.lightMap.flipY = false

        if material.enableIllustration2 != false
            uniforms[ "lightMap2" ].value = material.lightMap2 = @getPreloadedTexture(material.enableIllustration2)
            material.lightMap2.flipY = false

        return material         

    instanceFresnelDoubleLightmapMaterial:(subMesh,meshname)=>
        # console.log "instanced fresnel double lightmap for #{meshname}"
        shader = new IFLPhongFresnelShaderDoubleLightMap
        
        uniforms = shader.uniforms

        params = {}
        params.fragmentShader   = shader.fragmentShader
        params.vertexShader     = shader.vertexShader
        params.uniforms         = uniforms


        material = new THREE.ShaderMaterial( params );
        material.side = THREE.DoubleSide
        material.lights = false
        material.alphaTest = 0.5
        material.fog = true
        material.enableIllustration = false
        material.enableIllustration2 = false
        material.switchUVs = false

        uniforms[ "diffuse" ].value                             = new THREE.Color( 0xFFFFFF ) 
        uniforms[ "ambient" ].value                             = new THREE.Color( 0xFFFFFF )
        uniforms[ "specular" ].value                            = new THREE.Color( 0xFFFFFF )
        
        overrides  = @getMaterialOverrides(meshname)
        originalmeshname = meshname
        if overrides["overrideMap"]?
            meshname = overrides["overrideMap"]
            

        uniforms[ "map" ].value = material.map  = @getPreloadedTexture("#{meshname}_diff.dds")       
        
        uniforms[ "envMap" ].value = material.envMap            = @skyCubeTexture
        # uniforms[ "normalMap" ].value  = material.normalMap     = CustomImageUtils.loadCompressedTexture("#{@auxBasePath}/#{meshname}_nrml.dds") if meshname.indexOf("organ_spec") == -1
        uniforms[ "specularMap" ].value = material.specularMap  = @getPreloadedTexture("#{@auxBasePath}/#{meshname}_spec.dds")
        uniforms[ "tAux" ].value                                = @getPreloadedTexture("#{@auxBasePath}/#{meshname}_aux.dds")
        uniforms[ "envmapMultiplier" ].value = 5
        # uniforms[ "mFresnelPower" ].value = -2.5
        uniforms[ "diffuseMultiplier" ].value = 1

        meshname = originalmeshname

        material.map?.flipY = false
        # material.normalMap?.flipY = false
        material.specularMap?.flipY = false
        uniforms[ "tAux" ].value?.flipY = false



        @texLib.push uniforms[ "tAux" ].value
        @texLib.push uniforms[ "specularMap" ].value
        # @texLib.push uniforms[ "normalMap" ].value
        @texLib.push uniforms[ "envMap" ].value
        @texLib.push uniforms[ "map" ].value


        @matLib.push material

        @applyMaterialOverrides(material,meshname)


        if material.enableIllustration != false
            uniforms[ "lightMap" ].value = material.lightMap = @getPreloadedTexture material.enableIllustration
            material.lightMap.flipY = false

        if material.enableIllustration2 != false
            uniforms[ "lightMap2" ].value = material.lightMap2 = @getPreloadedTexture material.enableIllustration2
            material.lightMap2.flipY = false            

        return material


    instanceFresnelMaterial:(subMesh,meshname)=>
        shader = new IFLPhongFresnelShader
        
        uniforms = shader.uniforms

        params = {}
        params.fragmentShader   = shader.fragmentShader
        params.vertexShader     = shader.vertexShader
        params.uniforms         = uniforms


        material = new THREE.ShaderMaterial( params );
        material.side = THREE.DoubleSide
        material.lights = false
        material.alphaTest = 0.5
        material.fog = true
        material.enableIllustration = false
        material.switchUVs = false

        uniforms[ "diffuse" ].value                             = new THREE.Color( 0xFFFFFF ) 
        uniforms[ "ambient" ].value                             = new THREE.Color( 0xFFFFFF )
        uniforms[ "specular" ].value                            = new THREE.Color( 0xFFFFFF )
        
        overrides  = @getMaterialOverrides(meshname)
        originalmeshname = meshname
        if overrides["overrideMap"]?
            meshname = overrides["overrideMap"]
            

        uniforms[ "map" ].value = material.map  = @getPreloadedTexture("#{meshname}_diff.dds")       
        
        uniforms[ "envMap" ].value = material.envMap            = @skyCubeTexture
        # uniforms[ "normalMap" ].value  = material.normalMap     = CustomImageUtils.loadCompressedTexture("#{@auxBasePath}/#{meshname}_nrml.dds") if meshname.indexOf("organ_spec") == -1
        uniforms[ "specularMap" ].value = material.specularMap  = @getPreloadedTexture("#{@auxBasePath}/#{meshname}_spec.dds")
        uniforms[ "tAux" ].value                                = @getPreloadedTexture("#{@auxBasePath}/#{meshname}_aux.dds")
        uniforms[ "envmapMultiplier" ].value = 5
        # uniforms[ "mFresnelPower" ].value = -2.5
        uniforms[ "diffuseMultiplier" ].value = 1

        meshname = originalmeshname

        material.map?.flipY = false
        # material.normalMap?.flipY = false
        material.specularMap?.flipY = false
        uniforms[ "tAux" ].value?.flipY = false



        @texLib.push uniforms[ "tAux" ].value
        @texLib.push uniforms[ "specularMap" ].value
        # @texLib.push uniforms[ "normalMap" ].value
        @texLib.push uniforms[ "envMap" ].value
        @texLib.push uniforms[ "map" ].value


        @matLib.push material

        @applyMaterialOverrides(material,meshname)


        if material.enableIllustration != false
            uniforms[ "lightMap" ].value = material.lightMap = @getPreloadedTexture material.enableIllustration
            material.lightMap.flipY = false

        return material


     changeFresnelPower:(value)=>
        for mat in @matLib
            mat.uniforms?.mFresnelPower?.value = value
        return null

    changeNormalScale:(value)=>
        for mat in @matLib
            mat.uniforms?.normalScale?.value.set(value,value)
        return null
     


    disabledVertexColors : []

    vertexColorsEnabled:(value)=>
        if !value
            @disabledVertexColors = []
            for mat in @matLib
                if mat.vertexColors == THREE.VertexColors
                    mat.vertexColors = THREE.NoColors
                    mat.needsUpdate = true
                    @disabledVertexColors.push mat
        else
            for mat2 in @disabledVertexColors
                mat2.vertexColors = THREE.VertexColors
                mat2.needsUpdate = true
        return null

    dispose:(renderer)->
        if @matLib?
            for mat in @matLib
                renderer.deallocateMaterial(mat) if mat?

        if @texLib?
            for tex in @texLib
                 renderer.deallocateTexture(tex) if tex?

        renderer.deallocateTexture( @skyCubeTexture )

        @matLib = null
        @texLib = null
        @onProgress = null
        @onComplete = null
        return null