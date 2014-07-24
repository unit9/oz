class IFLOzifyParticleSystem

    centerMesh      : null
    scene           : null
    particleSystem  : null
    startTime       : null

    constructor:(centerMesh,scene,appHeight)->
        @centerMesh = centerMesh
        @scene = scene
        @initParticleSystem(appHeight)


    initParticleSystem:(appHeight)->

        shader = new IFLWindyParticlesShader()
        shader.uniforms["windScale"].value = 0
        shader.uniforms["diffuseMultiplier"].value = 2
        shader.uniforms["alphaMultiplier"].value = 0

        params = {}
        params.fragmentShader   = shader.fragmentShader
        params.vertexShader     = shader.vertexShader
        params.uniforms         = shader.uniforms
        params.attributes       = { speed: { type: 'f', value: [] } }

        material  = new THREE.ShaderMaterial(params)
        material.map = shader.uniforms["map"].value = THREE.ImageUtils.loadTexture("/models/textures/particles/ozify.png")
        material.size = shader.uniforms["size"].value = 0.5
        material.transparent = true
        material.blending = THREE.AdditiveBlending
        # material.depthTest = false
        material.depthWrite = false
        material.scale = shader.uniforms["scale"].value = appHeight / 2
        material.sizeAttenuation = true



        #
        # OK
        #

        # material = new THREE.ParticleBasicMaterial
        #     map : THREE.ImageUtils.loadTexture("/models/textures/particles/ozify.png")
        #     transparent : true
        #     size : 2
        #     sizeAttenuation : true
        #     depthTest : false
        #     depthWrite : false
        #     opacity : 0
        #     blending : THREE.NormalBlending

   

        @centerMesh.geometry.computeBoundingBox()
        boundingBox = @centerMesh.geometry.boundingBox
        
        center = new THREE.Vector3()
        center.x = boundingBox.min.x + ( (boundingBox.max.x - boundingBox.min.x) / 2 )
        center.y = boundingBox.min.y + ( (boundingBox.max.y - boundingBox.min.y) / 2 )
        center.z = boundingBox.min.z + ( (boundingBox.max.z - boundingBox.min.z) / 2 )

        volume = (boundingBox.max.x - boundingBox.min.x) * (boundingBox.max.z - boundingBox.min.z)
        # console.log "volume: #{volume}"
        # 500 : 43 = x : volume
        density = (500*volume)/43


        geometry = new THREE.Geometry()
        geometry.centroid = center
        geometry.vertices = []
        for k in [0...density]

            vertex = new THREE.Vector3
            vertex.x = vertex.startX = @randRange( boundingBox.min.x-2 ,boundingBox.max.x+2 )
            vertex.y = vertex.startY = @randRange( boundingBox.min.y-2 ,boundingBox.max.y+2 )
            vertex.z = vertex.startZ = @randRange( boundingBox.min.z-2 ,boundingBox.max.z+2 )

            vertex.speedX = 0.001 + Math.random() * 0.005
            vertex.speedY = 0.001 + Math.random() * 0.005
            vertex.speedZ = 0.001 + Math.random() * 0.005
            vertex.randSpreadX = 0.001 + Math.random() * 0.002
            vertex.randSpreadY = 0.001 + Math.random() * 0.002
            vertex.randSpreadZ = 0.001 + Math.random() * 0.002
            vertex.CCW = if Math.random() > 0.5 then 1 else -1
            params.attributes.speed.value[k] = 1 + Math.random() * 10

            # vertex.rotation = Math.random() * (Math.PI/4)
            # params.attributes.rotation.value[k] = vertex.rotation
            geometry.vertices.push(vertex)

        @particleSystem = new THREE.ParticleSystem( geometry , material )
        @particleSystem.position.copy(@centerMesh.position)
        @particleSystem.rotation.copy(@centerMesh.rotation)
        # @particleSystem.scale.copy(@centerMesh.scale)
        @scene.add @particleSystem


        new TWEEN.Tween(shader.uniforms["alphaMultiplier"]).to({value:0.2}, 1000).onUpdate(@updateParticles).onComplete(
            ()=>
                new TWEEN.Tween(shader.uniforms["alphaMultiplier"]).to({value:0}, 1000).onUpdate(@updateParticles).onComplete(@finalize).easing( TWEEN.Easing.Cubic.InOut ).start()
            ).easing( TWEEN.Easing.Cubic.InOut ).start()
        


        @startTime = Date.now()

    updateParticles:=>
        time = Date.now() - @startTime

        @particleSystem.material.uniforms["time"].value = time / 1000

        for vertex in @particleSystem.geometry.vertices

            timeNormX = time * vertex.speedX
            timeNormY = time * vertex.speedY
            timeNormZ = time * vertex.speedZ
            spreadX = time * vertex.randSpreadX
            spreadY = time * vertex.randSpreadY
            spreadZ = time * vertex.randSpreadZ

            dir = new THREE.Vector3(vertex.startX,vertex.startY,vertex.startZ)
            dir.sub(dir,@particleSystem.geometry.centroid)
            dir.normalize()
            dir.x *= spreadX
            dir.y *= spreadY
            dir.z *= spreadZ

            # vertex.x = vertex.startX  + ( Math.sin(timeNormX) * vertex.CCW )
            # vertex.y = vertex.startY  + ( Math.sin(timeNormY) * vertex.CCW )
            # vertex.z = vertex.startZ  + ( Math.sin(timeNormZ) * vertex.CCW )

            vertex.x = vertex.startX + dir.x + ( Math.sin(timeNormX) * vertex.CCW )
            vertex.y = vertex.startY + dir.y + ( Math.sin(timeNormY) * vertex.CCW )
            vertex.z = vertex.startZ + dir.z + ( Math.sin(timeNormZ) * vertex.CCW )

        @particleSystem.geometry.verticesNeedUpdate = true

    finalize:=>
        @scene.remove(@particleSystem)
        @scene = null
        @particleSystem = null
        @centerMesh = null


    randRange:(minNum, maxNum)-> 
        return Math.random() * (maxNum - minNum + 1) + minNum