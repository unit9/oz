class IFLPhongFresnelShader

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

                "tAux": { type: "t", value: null },
                "mFresnelPower": { type: "f", value: -2.5 }

                "windMin": { type: "v2", value: new THREE.Vector2(-400,-800) }
                "windSize": { type: "v2", value: new THREE.Vector2(1000,1000) }
                "windDirection": { type: "v3", value: new THREE.Vector3(1,0,0) }
                "tWindForce": { type: "t", value: null }
                "windScale": { type: "f", value: 2.0 }
            }
        ]

    vertexShader: [

        THREE.ShaderChunk[ "map_pars_vertex" ]
        THREE.ShaderChunk[ "lightmap_pars_vertex" ]
        THREE.ShaderChunk[ "color_pars_vertex" ]


        # "varying vec3 vViewPosition;"
        # "varying vec3 vNormal;"
        # "varying vec3 vObjectNormal;"
        "varying vec3 vReflect;"
        # "varying vec3 vWorldPosition;"


        "uniform sampler2D tAux;"
        "varying float vFresnel;"
        "uniform float mFresnelPower;"


        "#ifdef USE_COLOR"
            "#ifdef VERTEX_TEXTURES"
                "uniform float windScale;"
                "uniform vec2 windMin;"
                "uniform vec2 windSize;"
                "uniform vec3 windDirection;"
                "uniform sampler2D tWindForce;"
            "#endif"
        "#endif"



        "void main() {",

            THREE.ShaderChunk[ "map_vertex" ]
            THREE.ShaderChunk[ "lightmap_vertex" ]
            THREE.ShaderChunk[ "color_vertex" ]

            THREE.ShaderChunk[ "morphnormal_vertex" ]
            THREE.ShaderChunk[ "skinbase_vertex" ]
            THREE.ShaderChunk[ "skinnormal_vertex" ]
            THREE.ShaderChunk[ "defaultnormal_vertex" ]

            # "vNormal = transformedNormal;",
            # "vObjectNormal = objectNormal;",

            THREE.ShaderChunk[ "morphtarget_vertex" ]
            THREE.ShaderChunk[ "skinning_vertex" ]
            
            "vec4 mvPosition;"
            "#ifdef USE_COLOR"
                "#ifdef VERTEX_TEXTURES"
                    "vec4 wpos = modelMatrix * vec4( position.x ,position.y, -position.z, 1.0 );"
                    "vec2 totPos = wpos.xz - windMin;"
                    "vec2 windUV = totPos / windSize;"

                    "float vWindForce = texture2D( tWindForce , windUV ).x;"
                    "float windMod = ( (1.0 - vWindForce) * color.r) * windScale;"
                    "vec4 pos = vec4( position.x + windMod * windDirection.x, position.y + windMod * windDirection.y , position.z + windMod * windDirection.z,  1.0);"
                    "mvPosition = modelViewMatrix *  pos;"
                "#else"
                    "mvPosition = modelViewMatrix * vec4( position, 1.0 );",
                "#endif"
            "#else"
                "mvPosition = modelViewMatrix * vec4( position, 1.0 );",
            "#endif"

            "gl_Position = projectionMatrix * mvPosition;"


            # "vViewPosition = normalize( -mvPosition.xyz );"

            THREE.ShaderChunk[ "worldpos_vertex" ]

            "#if defined( USE_ENVMAP )",
                "vec3 nWorld = mat3( modelMatrix[ 0 ].xyz, modelMatrix[ 1 ].xyz, modelMatrix[ 2 ].xyz ) * objectNormal;",
                "vReflect = reflect( normalize( mPosition.xyz - cameraPosition ), normalize( nWorld.xyz ) );",
            "#endif"



            "float fresnelFactor;"
            "#ifdef USE_MAP"
                "fresnelFactor = 1.0 - texture2D( tAux, vUv ).r;"
            "#else"
                "fresnelFactor = 1.0;"
            "#endif"

            "float fresnelPow =  mFresnelPower + ( 5.0 * fresnelFactor );"

            "float fresnel = pow( 1.0 + dot( normalize( mvPosition.xyz ) , normalize( transformedNormal ) ), fresnelPow );" 
            "vFresnel = clamp( fresnel, 0.0, 1.0 );"

            # "vWorldPosition = mPosition.xyz;"
        "}"

    ].join("\n")

    fragmentShader: [


        THREE.ShaderChunk[ "color_pars_fragment" ]
        THREE.ShaderChunk[ "map_pars_fragment" ]
        THREE.ShaderChunk[ "lightmap_pars_fragment" ]
        THREE.ShaderChunk[ "fog_pars_fragment" ]
        THREE.ShaderChunk[ "specularmap_pars_fragment" ]

        "uniform vec3 diffuse;"
        "uniform float opacity;"

        "uniform vec3 ambient;"
        "uniform vec3 emissive;"
        "uniform vec3 specular;"
        "uniform float shininess;"
        "uniform float diffuseMultiplier;"
        "uniform float envmapMultiplier;"
        "uniform float lightMapMultiplier;"

        
        "varying float vFresnel;"

        "#ifdef USE_ENVMAP",
            "varying vec3 vReflect;",
            "uniform float reflectivity;"
            "uniform samplerCube envMap;"
            "uniform float flipEnvMap;"
            "uniform int combine;"
        "#endif"


        "void main() {",

            "gl_FragColor = vec4( diffuse, opacity );"


            "#ifdef USE_MAP",
                "gl_FragColor = texture2D( map, vUv ) * diffuseMultiplier;"
            "#endif"            
            "#ifdef USE_LIGHTMAP",
                "vec4 map2col = texture2D( lightMap, vUv2 );"
                "gl_FragColor *= map2col * lightMapMultiplier;"
                "gl_FragColor.w = map2col.w;"

            "#endif"

            THREE.ShaderChunk[ "alphatest_fragment" ]
            THREE.ShaderChunk[ "specularmap_fragment" ]

            "#ifdef USE_ENVMAP"

                "#ifdef DOUBLE_SIDED"
                    "float flipNormal = ( -1.0 + 2.0 * float( gl_FrontFacing ) );"
                    "vec4 cubeColor = textureCube( envMap, flipNormal * vec3( flipEnvMap * vReflect.x, vReflect.yz ) ) *  envmapMultiplier;"
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