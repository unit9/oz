class IFLWindGenerator

    enabled             : true
    noiseMap            : null
    noiseShader         : null
    noiseScene          : null
    noiseMaterial       : null
    noiseCameraOrtho    : null
    noiseQuadTarget     : null
    noiseRenderTarget   : null
    noiseSpeed          : 0.005
    noiseOffsetSpeed    : 0.1
    windDirection       : null

    constructor:->
        @windDirection = new THREE.Vector3(1,0,0)    


        @noiseMap  = new THREE.WebGLRenderTarget( 64, 64, { minFilter: THREE.LinearMipmapLinearFilter, magFilter: THREE.LinearFilter, format: THREE.RGBFormat } );
        # @noiseMap.generateMin

        @noiseShader = new IFLNoiseShader()
        # @noiseShader.uniforms.vScale.value.set(0.3,0.3)
        @noiseShader.uniforms.vScale.value.set(2,2)
        @noiseScene = new THREE.Scene()
        @noiseCameraOrtho = new THREE.OrthographicCamera( window.innerWidth / - 2, window.innerWidth / 2,  window.innerHeight / 2, window.innerHeight / - 2, -10000, 10000 );
        @noiseCameraOrtho.position.z = 100
        @noiseScene.add( @noiseCameraOrtho )

        @noiseMaterial = new THREE.ShaderMaterial
            fragmentShader: @noiseShader.fragmentShader
            vertexShader: @noiseShader.vertexShader
            uniforms: @noiseShader.uniforms
            lights:false

        @noiseQuadTarget = new THREE.Mesh( new THREE.PlaneGeometry(window.innerWidth,window.innerHeight,1,1), @noiseMaterial )
        @noiseQuadTarget.name = "noise_quad_target"
        @noiseQuadTarget.position.z = -9000
        @noiseScene.add( @noiseQuadTarget )



    update:(renderer,delta)->
        return unless @enabled

        @noiseShader.uniforms.fTime.value += delta * @noiseSpeed
        @noiseShader.uniforms.vOffset.value.x -= (delta * @noiseOffsetSpeed) * @windDirection.x
        @noiseShader.uniforms.vOffset.value.y += (delta * @noiseOffsetSpeed) * @windDirection.z


        # @noiseShader.uniforms[ "uOffset" ].value.x = 4 * @noiseShader.uniforms[ "offset" ].value.x;
        # @renderer.render( @noiseScene, @noiseCameraOrtho, @noiseMap, true );
        renderer.render( @noiseScene, @noiseCameraOrtho ,@noiseMap, false);
        return null

    dispose:(renderer)->
        renderer.deallocateRenderTarget(@noiseMap)
        renderer.deallocateMaterial(@noiseMaterial)
        renderer.deallocateObject(@noiseQuadTarget)

        for obj in @noiseScene.children
            @noiseScene.remove obj        
        @noiseScene.__webglObjects = null
        @noiseScene.__objects = null
        @noiseScene.__objectsRemoved  = null
        @noiseScene.children = []
        return null
