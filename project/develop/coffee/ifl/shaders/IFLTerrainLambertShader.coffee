class IFLTerrainLambertShader

    uniforms : null
    
    constructor:->
        @uniforms = THREE.UniformsUtils.merge [
            THREE.UniformsLib[ "common" ]
            THREE.UniformsLib[ "fog" ]
            {
                "tBlendmap"         : { type: "t", value: null }
                "tDiffuseR"         : { type: "t", value: null }
                "tDiffuseG"         : { type: "t", value: null }
                "tDiffuseB"         : { type: "t", value: null }

                "lightMapMultiplier": { type: "f", value: 3.0 }

                "offsetRepeatR"     : { type: "v4", value: new THREE.Vector4(1,1,1,1) }
                "offsetRepeatG"     : { type: "v4", value: new THREE.Vector4(1,1,1,1) }
                "offsetRepeatB"     : { type: "v4", value: new THREE.Vector4(1,1,1,1) }          

                "ambient"           : { type: "c", value: new THREE.Color( 0xffffff ) }
                "emissive"          : { type: "c", value: new THREE.Color( 0x000000 ) }
                "wrapRGB"           : { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) }
            }
        ]


    vertexShader: [
        THREE.ShaderChunk[ "map_pars_vertex" ]
        THREE.ShaderChunk[ "color_pars_vertex" ]

        "uniform vec4 offsetRepeatR;"
        "uniform vec4 offsetRepeatG;"
        "uniform vec4 offsetRepeatB;"

        "varying vec2 vUvUnscaled;"
        "varying vec2 vUvR;"
        "varying vec2 vUvG;"
        "varying vec2 vUvB;"

        "void main() {"

            "#if defined( USE_MAP ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( USE_SPECULARMAP )",

                "vUv  = uv * offsetRepeat.zw + offsetRepeat.xy;",
                "vUvR = uv * offsetRepeatR.zw + offsetRepeatR.xy;"
                "vUvG = uv * offsetRepeatG.zw + offsetRepeatG.xy;"
                "vUvB = uv * offsetRepeatB.zw + offsetRepeatB.xy;"
                "vUvUnscaled = uv;"
            "#endif"
            
            THREE.ShaderChunk[ "color_vertex" ]
            THREE.ShaderChunk[ "defaultnormal_vertex" ]
            THREE.ShaderChunk[ "default_vertex" ]
            THREE.ShaderChunk[ "worldpos_vertex" ]
        "}"

    ].join("\n")

    fragmentShader: [

        THREE.ShaderChunk[ "color_pars_fragment" ]
        THREE.ShaderChunk[ "map_pars_fragment" ]
        THREE.ShaderChunk[ "fog_pars_fragment" ]

        "uniform sampler2D tBlendmap;"        
        "uniform sampler2D tDiffuseR;"
        "uniform sampler2D tDiffuseG;"
        "uniform sampler2D tDiffuseB;"
        "uniform sampler2D lightMap;"

        "uniform float opacity;"
        "uniform float lightMapMultiplier;"

        "varying vec2 vUvUnscaled;"
        "varying vec2 vUvR;"
        "varying vec2 vUvG;"
        "varying vec2 vUvB;"



        "void main() {"

            "gl_FragColor = vec4( vec3 ( 1.0 ), opacity );"

            # mix all terrain maps
            "#ifdef USE_MAP"
                "gl_FragColor = gl_FragColor * texture2D( map, vUv );"

                "vec4 vColor = texture2D( tBlendmap, vUvUnscaled );"

                "vec4 fragColorR = texture2D( tDiffuseR, vUvR );"
                "gl_FragColor.xyz = mix( gl_FragColor.xyz, fragColorR.xyz, vColor.r );"

                "vec4 fragColorG = texture2D( tDiffuseG, vUvG );"
                "gl_FragColor.xyz = mix( gl_FragColor.xyz, fragColorG.xyz, vColor.g );"

                "vec4 fragColorB = texture2D( tDiffuseB, vUvB );"
                "gl_FragColor.xyz = mix( gl_FragColor.xyz, fragColorB.xyz, vColor.b );"
            "#endif"

            THREE.ShaderChunk[ "alphatest_fragment" ]

            "float specularStrength = 1.0;"

            # add lightmap contribution
            "#ifdef USE_LIGHTMAP"
                "gl_FragColor = gl_FragColor * ( texture2D( lightMap, vUvUnscaled ) * lightMapMultiplier );"
            "#endif"            

            THREE.ShaderChunk[ "envmap_fragment" ]
            THREE.ShaderChunk[ "fog_fragment" ]

        "}"         

    ].join("\n")