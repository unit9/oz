class IFLColorCorrectionShader

    uniforms : null
    
    constructor:->
        @uniforms =
            "tDiffuse" :    { type: "t", value: null }

            # color correction
            "saturation" :  { type: "v4", value: new THREE.Vector4( 0, 0, 0 , 1 ) }
            "powRGB" :      { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) }
            "mulRGB" :      { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) }

            # vignette 
            "vignetteOffset":   { type: "f", value: 1.2 }
            "vignetteDarkness": { type: "f", value: 1.3 }

            # volumetric light
            "volumetricLightX": {type: "f", value: 0.5}
            "volumetricLightY": {type: "f", value: 0.5}
            "enableVolumetricLight": {type: "i", value: 0}
            "tVolumetricLight": { type: "t", value: null }

            # overlay
            "tOverlay": { type: "t", value: null }

    vertexShader: [
        "varying vec2 vUv;"
        "void main() {"
            "vUv = uv;"
            "gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );"
        "}"

    ].join("\n")

    fragmentShader: [

        "uniform sampler2D tDiffuse;"
        "varying vec2 vUv;"

        # color correction
        "uniform vec3 powRGB;"
        "uniform vec3 mulRGB;"
        "uniform vec4 saturation;"

        # vignette
        "uniform float vignetteOffset;",
        "uniform float vignetteDarkness;"

        # volumetric light
        "uniform bool enableVolumetricLight;"        
        "uniform float volumetricLightX;"
        "uniform float volumetricLightY;"   
        "uniform sampler2D tVolumetricLight;"
        "const int iSamples = 10;",

        # overlay        
        "uniform sampler2D tOverlay;"


        "void main() {"

            "gl_FragColor = texture2D( tDiffuse, vUv );"


            #pow / mul
            "gl_FragColor.xyz = mulRGB * pow( gl_FragColor.xyz, powRGB );"

            "gl_FragColor.r = clamp(gl_FragColor.r, 0.0, 1.0);"
            "gl_FragColor.g = clamp(gl_FragColor.g, 0.0, 1.0);"
            "gl_FragColor.b = clamp(gl_FragColor.b, 0.0, 1.0);"

            # saturation
            # 0.2126f,0.7152f,0.0722f

            "vec3 luminanceWeights = vec3(0.2126,0.7152,0.0722);"
            "float luminance = dot(gl_FragColor.xyz,luminanceWeights);"
            "vec3 greyscale = vec3(luminance,luminance,luminance);"
            "gl_FragColor.xyz = mix(gl_FragColor.xyz,greyscale.xyz,saturation.xyz);"

            "gl_FragColor.r = clamp(gl_FragColor.r, 0.0, 1.0);"
            "gl_FragColor.g = clamp(gl_FragColor.g, 0.0, 1.0);"
            "gl_FragColor.b = clamp(gl_FragColor.b, 0.0, 1.0);"

 
            # volumetric light
            "if (enableVolumetricLight){"
                "vec2 deltaTextCoord = vec2(vUv - vec2(volumetricLightX,volumetricLightY));"
                "deltaTextCoord *= 1.0 /  float(iSamples) * 0.99;"
                "vec2 coord = vUv;"
                "float illuminationDecay = 1.0;"
                "vec4 FragColor = vec4(0.0);"

                "for(int i=0; i < iSamples ; i++)"
                "{",
                    "coord -= deltaTextCoord;"
                    "vec4 texel = texture2D(tVolumetricLight, coord);"
                    "texel *= illuminationDecay * 0.7;"

                    "FragColor += texel;"

                    "illuminationDecay *= 0.91;"
                "}",
                "FragColor *= 0.2;"
                "FragColor = clamp(FragColor, 0.0, 1.0);"
                "gl_FragColor += FragColor;"
            "}"


            # overlay
            # "vec4 smallSample = gl_FragColor.xyzw;"
            # "float overlayIntensity =  (smallSample.x + smallSample.y + smallSample.z) / 3.0;"
            # "gl_FragColor += texture2D( tOverlay, vUv ) * ( overlayIntensity );"

            #vignette
            "vec2 uv = ( vUv - vec2( 0.5 ) ) * vec2( vignetteOffset );"
            "gl_FragColor = vec4( mix( gl_FragColor.rgb, vec3( 1.0 - vignetteDarkness ), dot( uv, uv ) ), gl_FragColor.a );"
        "}"

    ].join("\n")