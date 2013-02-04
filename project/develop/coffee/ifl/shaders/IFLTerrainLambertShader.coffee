class IFLTerrainLambertShader

    uniforms : null
    
    constructor:->
        @uniforms = THREE.UniformsUtils.merge [
            THREE.UniformsLib[ "common" ]
            THREE.UniformsLib[ "fog" ]
            # THREE.UniformsLib[ "lights" ]
            THREE.UniformsLib[ "shadowmap" ]
            {
                "tBlendmap" : { type: "t", value: null }
                "lightMapMultiplier" : { type: "f", value: 3.0 }

                "offsetRepeatR" : { type: "v4", value: new THREE.Vector4(1,1,1,1) }
                "offsetRepeatG" : { type: "v4", value: new THREE.Vector4(1,1,1,1) }
                "offsetRepeatB" : { type: "v4", value: new THREE.Vector4(1,1,1,1) }
                
                "enableDiffuseR"    : { type: "i", value: 0 }
                "enableDiffuseG"    : { type: "i", value: 0 }
                "enableDiffuseB"    : { type: "i", value: 0 }
                "tDiffuseR"    : { type: "t", value: null }
                "tDiffuseG"    : { type: "t", value: null }
                "tDiffuseB"    : { type: "t", value: null }


                "enableSpecularR"  : { type: "i", value: 0 }
                "enableSpecularG"  : { type: "i", value: 0 }
                "enableSpecularB"  : { type: "i", value: 0 }
                "tSpecularR"   : { type: "t", value: null }
                "tSpecularG"   : { type: "t", value: null }
                "tSpecularB"   : { type: "t", value: null }                     

                "ambient"  : { type: "c", value: new THREE.Color( 0xffffff ) }
                "emissive" : { type: "c", value: new THREE.Color( 0x000000 ) }
                "wrapRGB"  : { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) }
            }
        ]


    vertexShader: [
        "#define LAMBERT"

        # "varying vec3 vLightFront;"

        # "#ifdef DOUBLE_SIDED"
        #     "varying vec3 vLightBack;"
        # "#endif"

        THREE.ShaderChunk[ "map_pars_vertex" ]
        "uniform vec4 offsetRepeatR;",
        "uniform vec4 offsetRepeatG;",
        "uniform vec4 offsetRepeatB;",
        # THREE.ShaderChunk[ "lightmap_pars_vertex" ]
        "varying vec2 vUvUnscaled;"
        "varying vec2 vUvR;"
        "varying vec2 vUvG;"
        "varying vec2 vUvB;"
        THREE.ShaderChunk[ "envmap_pars_vertex" ]
        # THREE.ShaderChunk[ "lights_lambert_pars_vertex" ]
        THREE.ShaderChunk[ "color_pars_vertex" ]
        THREE.ShaderChunk[ "morphtarget_pars_vertex" ]
        THREE.ShaderChunk[ "skinning_pars_vertex" ]
        # THREE.ShaderChunk[ "shadowmap_pars_vertex" ]

        "void main() {"

            # THREE.ShaderChunk[ "map_vertex" ]
            "#if defined( USE_MAP ) || defined( USE_BUMPMAP ) || defined( USE_NORMALMAP ) || defined( USE_SPECULARMAP )",

                "vUv  = uv * offsetRepeat.zw + offsetRepeat.xy;",
                "vUvR = uv * offsetRepeatR.zw + offsetRepeatR.xy;"
                "vUvG = uv * offsetRepeatG.zw + offsetRepeatG.xy;"
                "vUvB = uv * offsetRepeatB.zw + offsetRepeatB.xy;"
                "vUvUnscaled = uv;"
            "#endif"
            
            #THREE.ShaderChunk[ "lightmap_vertex" ]
            # changed 
            # "#ifdef USE_LIGHTMAP"
            # "#endif"
            THREE.ShaderChunk[ "color_vertex" ]

            THREE.ShaderChunk[ "morphnormal_vertex" ]
            THREE.ShaderChunk[ "skinbase_vertex" ]
            THREE.ShaderChunk[ "skinnormal_vertex" ]
            THREE.ShaderChunk[ "defaultnormal_vertex" ]

            THREE.ShaderChunk[ "morphtarget_vertex" ]
            THREE.ShaderChunk[ "skinning_vertex" ]
            THREE.ShaderChunk[ "default_vertex" ]

            THREE.ShaderChunk[ "worldpos_vertex" ]
            THREE.ShaderChunk[ "envmap_vertex" ]
            # THREE.ShaderChunk[ "lights_lambert_vertex" ]
            THREE.ShaderChunk[ "shadowmap_vertex" ]

        "}"

    ].join("\n")

    fragmentShader: [

        "uniform float opacity;"

        # "varying vec3 vLightFront;"

        # "#ifdef DOUBLE_SIDED"

        #     "varying vec3 vLightBack;"

        # "#endif"


        THREE.ShaderChunk[ "color_pars_fragment" ]
        
        THREE.ShaderChunk[ "map_pars_fragment" ]
        "uniform sampler2D tBlendmap;"
        "uniform bool enableDiffuseR;"
        "uniform bool enableDiffuseG;"
        "uniform bool enableDiffuseB;"
        
        "uniform sampler2D tDiffuseR;"
        "uniform sampler2D tDiffuseG;"
        "uniform sampler2D tDiffuseB;"
        "uniform float lightMapMultiplier;"




        # THREE.ShaderChunk[ "lightmap_pars_fragment" ]
        "varying vec2 vUvUnscaled;",
        "varying vec2 vUvR;",
        "varying vec2 vUvG;",
        "varying vec2 vUvB;",
        "uniform sampler2D lightMap;",

        THREE.ShaderChunk[ "envmap_pars_fragment" ]
        THREE.ShaderChunk[ "fog_pars_fragment" ]

        THREE.ShaderChunk[ "shadowmap_pars_fragment" ]

        THREE.ShaderChunk[ "specularmap_pars_fragment" ]
        "uniform bool enableSpecularR;"
        "uniform bool enableSpecularG;"
        "uniform bool enableSpecularB;"

        "uniform sampler2D tSpecularR;"
        "uniform sampler2D tSpecularG;"
        "uniform sampler2D tSpecularB;"

        "void main() {"

            "gl_FragColor = vec4( vec3 ( 1.0 ), opacity );"

            "#ifdef USE_MAP"

                # "#ifdef GAMMA_INPUT"

                #     "vec4 texelColor = texture2D( map, vUv );"
                #     "texelColor.xyz *= texelColor.xyz;"

                #     "gl_FragColor = gl_FragColor * texelColor;"

                # "#else"

                    "gl_FragColor = gl_FragColor * texture2D( map, vUv );"
                    # "gl_FragColor.xyz *= 1.5;"
                    # "gl_FragColor *= gl_FragColor;"

                # "#endif"

                "#ifdef USE_COLOR"
                "#else"
                    "vec4 vColor = texture2D( tBlendmap, vUvUnscaled );"
                "#endif"

                    
                # DIFFUSE R
                # "if( enableDiffuseR ) {"

                    "vec4 fragColorR;"
                    # "#ifdef GAMMA_INPUT"

                    #     "fragColorR = texture2D( tDiffuseR, vUvR );"
                    #     "fragColorR.xyz *= fragColorR.xyz;"

                    # "#else"

                        "fragColorR = texture2D( tDiffuseR, vUvR );"
                        # "fragColorR.xyz *= 1.5;"
                        # "fragColorR *= fragColorR;"
                    # "#endif"

                    "gl_FragColor.xyz = mix( gl_FragColor.xyz, fragColorR.xyz, vColor.r );"

                # "}"   


                # DIFFUSE G
                # "if( enableDiffuseG ) {"

                    "vec4 fragColorG;"
                    # "#ifdef GAMMA_INPUT"

                    #     "fragColorG = texture2D( tDiffuseG, vUvG );"
                    #     "fragColorG.xyz *= fragColorG.xyz;"

                    # "#else"

                        "fragColorG = texture2D( tDiffuseG, vUvG );"
                        # "fragColorG.xyz *= 1.5;"
                        # "fragColorG *= fragColorG;"
                        
                    # "#endif"

                    "gl_FragColor.xyz = mix( gl_FragColor.xyz, fragColorG.xyz, vColor.g );"

                # "}"


                # DIFFUSE B
                # "if( enableDiffuseB ) {"

                    "vec4 fragColorB;"
                    "#ifdef GAMMA_INPUT"

                        "fragColorB = texture2D( tDiffuseB, vUvB );"
                        "fragColorB.xyz *= fragColorB.xyz;"

                    "#else"

                        "fragColorB = texture2D( tDiffuseB, vUvB );"
                        # "fragColorB.xyz *= 1.5;"
                        # "fragColorB *= fragColorB;"
                    "#endif"

                    "gl_FragColor.xyz = mix( gl_FragColor.xyz, fragColorB.xyz, vColor.b );"

                # "}"



            "#endif"


                        



            THREE.ShaderChunk[ "alphatest_fragment" ],

            "float specularStrength;"

            "#ifdef USE_SPECULARMAP"
                "vec4 texelSpecular = texture2D( specularMap, vUv );"

                "#ifdef USE_COLOR"

                    "if( enableSpecularR )"
                        "texelSpecular = vec4( mix( texelSpecular.xyz, texture2D( tSpecularR, vUv ).xyz, vColor.r ), 1.0);"         
                    "if( enableSpecularG )"
                        "texelSpecular = vec4( mix( texelSpecular.xyz, texture2D( tSpecularG, vUv ).xyz, vColor.g ), 1.0);"
                    "if( enableSpecularR )"
                        "texelSpecular = vec4( mix( texelSpecular.xyz, texture2D( tSpecularB, vUv ).xyz, vColor.b ), 1.0);"

                "#endif"

            "#else"

                "specularStrength = 1.0;"

            "#endif"

            # original lambert part
            # "#ifdef DOUBLE_SIDED"

            #     "if ( gl_FrontFacing )"
            #         "gl_FragColor.xyz *= vLightFront;"
            #     "else"
            #         "gl_FragColor.xyz *= vLightBack;"

            # "#else"

            #     "gl_FragColor.xyz *= vLightFront;"

            # "#endif"

            # THREE.ShaderChunk[ "lightmap_fragment" ],
            "#ifdef USE_LIGHTMAP",

                "gl_FragColor = gl_FragColor * ( texture2D( lightMap, vUvUnscaled ) * lightMapMultiplier );",

            "#endif"            
            #THREE.ShaderChunk[ "color_fragment" ],
            THREE.ShaderChunk[ "envmap_fragment" ],
            THREE.ShaderChunk[ "shadowmap_fragment" ],

            # THREE.ShaderChunk[ "linear_to_gamma_fragment" ],
            # "#ifdef GAMMA_OUTPUT",

                # "float d = 1.0/1.8;"
                # "gl_FragColor.rgb = pow( gl_FragColor.rgb , vec3(d,d,d) );"
                # "gl_FragColor *= 16;  // Hardcoded Exposure Adjustment"
                # "float3 x = max(0,gl_FragColor-0.004);"
                # "gl_FragColor = (x*(6.2*x+.5))/(x*(6.2*x+1.7)+0.06);"
            # "#endif"

            THREE.ShaderChunk[ "fog_fragment" ],

        "}"         

    ].join("\n")