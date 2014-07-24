class IFLBasicShader

    uniforms : null

    constructor:->
        @uniforms = THREE.UniformsUtils.merge [
            THREE.UniformsLib[ "common" ]
            THREE.UniformsLib[ "fog" ]
            {
                "diffuseMultiplier"     : { type: "f",  value: 1 }
                "lightMapMultiplier"    : { type: "f",  value: 1 }
                "additiveLightMap"      : { type: "i",  value: 0 }
                "windMin"               : { type: "v2", value: new THREE.Vector2(-400,-800) }
                "windSize"              : { type: "v2", value: new THREE.Vector2(1000,1000) }
                "windDirection"         : { type: "v3", value: new THREE.Vector3(1,0,0) }
                "tWindForce"            : { type: "t",  value: null }
                "windScale"             : { type: "f",  value: 1.0 }                
            }]

    vertexShader: [

        THREE.ShaderChunk[ "map_pars_vertex" ]
        THREE.ShaderChunk[ "lightmap_pars_vertex" ]
        THREE.ShaderChunk[ "color_pars_vertex" ]
        
        "#ifdef USE_COLOR"
            "#ifdef VERTEX_TEXTURES"
                "uniform vec2 windMin;"
                "uniform vec2 windSize;"
                "uniform vec3 windDirection;"
                "uniform sampler2D tWindForce;"
                "uniform float windScale;"
            "#endif"
        "#endif"

        "void main() {"

            THREE.ShaderChunk[ "map_vertex" ]
            THREE.ShaderChunk[ "lightmap_vertex" ]
            THREE.ShaderChunk[ "color_vertex" ],

            "vec4 mvPosition;"


            "#ifdef USE_COLOR"
                "#ifdef VERTEX_TEXTURES"
                    "vec4 wpos = modelMatrix * vec4( position, 1.0 );"
                    "wpos.z = -wpos.z;"
                    "vec2 totPos = wpos.xz - windMin;"
                    "vec2 windUV = totPos / windSize;"
                    "float vWindForce = texture2D(tWindForce,windUV).x;"
                    "float windVertexScale = color.r;"

                    "float windMod = ((1.0 - vWindForce)*windVertexScale) * windScale;"
                    "vec4 pos = vec4(position , 1.0);"
                    "pos.x += windMod * windDirection.x;"
                    "pos.y += windMod * windDirection.y;"
                    "pos.z += windMod * windDirection.z;"
                    "mvPosition = modelViewMatrix *  pos;"
                "#else"
                    "mvPosition = modelViewMatrix * vec4( position, 1.0 );",
                "#endif"
            "#else"
                "mvPosition = modelViewMatrix * vec4( position, 1.0 );",
            "#endif"

            "gl_Position = projectionMatrix * mvPosition;"

            THREE.ShaderChunk[ "worldpos_vertex" ]
        "}"

    ].join("\n")

    fragmentShader: [

        "uniform vec3 diffuse;"
        "uniform float opacity;"
        "uniform float diffuseMultiplier;"
        "uniform float lightMapMultiplier;"
        "uniform bool additiveLightMap;"

        THREE.ShaderChunk[ "color_pars_fragment" ]
        THREE.ShaderChunk[ "map_pars_fragment" ]
        THREE.ShaderChunk[ "lightmap_pars_fragment" ]      
        THREE.ShaderChunk[ "fog_pars_fragment" ]

        "void main() {"

            "gl_FragColor = vec4( diffuse, opacity );"


            "#ifdef USE_MAP",
                "vec4 tex = texture2D( map, vUv );"
                "gl_FragColor = gl_FragColor * vec4( tex.xyz * diffuseMultiplier, tex.w );"
            "#endif"

            "#ifdef USE_LIGHTMAP",
                "vec4 map2col = texture2D( lightMap, vUv2 ) * lightMapMultiplier;"
                "if(additiveLightMap){"
                    "gl_FragColor += map2col;"
                "} else {"
                    "gl_FragColor *= map2col;"
                    "gl_FragColor.w = map2col.w;"
                "}"
            "#endif"


            THREE.ShaderChunk[ "alphatest_fragment" ]          
            THREE.ShaderChunk[ "fog_fragment" ]

        "}"

    ].join("\n")