class IFLPhongFresnelShaderDoubleLightMap extends IFLPhongFresnelShader

    uniforms : null
        
    constructor:->
        @uniforms = THREE.UniformsUtils.merge [
            THREE.UniformsLib[ "common" ]
            THREE.UniformsLib[ "fog" ]
            {
                "ambient"  : { type: "c", value: new THREE.Color( 0xffffff ) }
                "emissive" : { type: "c", value: new THREE.Color( 0x000000 ) }
                "specular" : { type: "c", value: new THREE.Color( 0x111111 ) }
                "shininess": { type: "f", value: 30 }
                "diffuseMultiplier": { type: "f", value: 1 }
                "envmapMultiplier": { type: "f", value: 2 }
                "lightMapMultiplier": { type: "f", value: 1 }
                "wrapRGB"  : { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) }

                "lightmapBlend": { type: "f", value: 0.0 }
                "lightMap2": { type: "t", value: null },
                "tAux": { type: "t", value: null },
                "mFresnelPower": { type: "f", value: -2.5 }

                "windMin": { type: "v2", value: new THREE.Vector2(-400,-800) }
                "windSize": { type: "v2", value: new THREE.Vector2(1000,1000) }
                "windDirection": { type: "v3", value: new THREE.Vector3(1,0,0) }
                "tWindForce": { type: "t", value: null }
                "windScale": { type: "f", value: 2.0 }
            }
        ]

    

        @fragmentShader = [


            THREE.ShaderChunk[ "color_pars_fragment" ]
            THREE.ShaderChunk[ "map_pars_fragment" ]
            THREE.ShaderChunk[ "lightmap_pars_fragment" ]
            THREE.ShaderChunk[ "fog_pars_fragment" ]
            THREE.ShaderChunk[ "specularmap_pars_fragment" ]

            "uniform vec3 diffuse;"
            "uniform float opacity;"
            "uniform float lightmapBlend;"
            "uniform sampler2D lightMap2;"

            "uniform vec3 ambient;"
            "uniform vec3 emissive;"
            "uniform vec3 specular;"
            "uniform float shininess;"
            "uniform float diffuseMultiplier;"
            "uniform float envmapMultiplier;"
            "uniform float lightMapMultiplier;"

            "uniform float vFresnel;"

            "#ifdef USE_ENVMAP",
                "varying vec3 vReflect;",
                "uniform float reflectivity;"
                "uniform samplerCube envMap;"
                "uniform float flipEnvMap;"
                "uniform int combine;"
            "#endif"        

            "void main() {"

                "gl_FragColor = vec4( diffuse, opacity );"


                "#ifdef USE_MAP"
                    "gl_FragColor = texture2D( map, vUv ) * diffuseMultiplier;"
                "#endif"   

                "#ifdef USE_LIGHTMAP"
                    "vec4 map2col = mix( texture2D( lightMap, vUv2 ), texture2D( lightMap2, vUv2 ), lightmapBlend);"
                    "gl_FragColor *= map2col * lightMapMultiplier;"
                    "gl_FragColor.w = map2col.w;"
                "#endif"

                THREE.ShaderChunk[ "alphatest_fragment" ]
                THREE.ShaderChunk[ "specularmap_fragment" ]

                "#ifdef USE_ENVMAP"
                    "#ifdef DOUBLE_SIDED"
                        "float flipNormal = ( -1.0 + 2.0 * float( gl_FrontFacing ) );"
                        "vec4 cubeColor = textureCube( envMap, flipNormal * vec3( flipEnvMap * vReflect.x, vReflect.yz ) ) * envmapMultiplier;"
                    "#else"
                        "vec4 cubeColor = textureCube( envMap, vec3( flipEnvMap * vReflect.x, vReflect.yz ) ) * envmapMultiplier;"
                    "#endif"


                    # FRESNEL
                    "float fresnel;"
                    "#ifdef DOUBLE_SIDED"
                        "fresnel = flipNormal * vFresnel;" 
                    "#else"
                        "fresnel = vFresnel;" 
                    "#endif"

                    # combine using fresnel term and specularStrength instaead of simple "specular"
                    # also multiply specular color to final result
                    "#ifdef USE_SPECULARMAP"
                        "gl_FragColor.xyz = mix( gl_FragColor.xyz, cubeColor.xyz * texelSpecular.xyz ,  fresnel * specularStrength   );"
                    "#else"
                        "gl_FragColor.xyz = mix( gl_FragColor.xyz, cubeColor.xyz,  fresnel * specularStrength  );"
                    "#endif"

                "#endif"
                
                THREE.ShaderChunk[ "fog_fragment" ]

            "}"

        ].join("\n")