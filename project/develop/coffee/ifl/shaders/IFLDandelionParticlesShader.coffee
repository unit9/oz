class IFLDandelionParticlesShader

    uniforms : null

    constructor:->
        @uniforms =  THREE.UniformsUtils.merge( [

            THREE.UniformsLib[ "particle" ]
            THREE.UniformsLib[ "shadowmap" ]
            {
                # "windMin": { type: "v2", value: new THREE.Vector2(-400,-800) }
                # "windSize": { type: "v2", value: new THREE.Vector2(1000,1000) }
                # "windDirection": { type: "v3", value: new THREE.Vector3(1,0,0) }
                # "tWindForce": { type: "t", value: null }
                # "windScale": { type: "f", value: 10.0 }       

                # "time": { type: "f", value: 0.0 }
            }

        ] )



    vertexShader: [

        "attribute float rotation;"
        # "attribute float speed;"

        "uniform float size;"
        "uniform float scale;"
        # "varying float vSpeed;"
        "varying float vRotation;"

        # "uniform vec2 windMin;"
        # "uniform vec2 windSize;"
        # "uniform vec3 windDirection;"
        # "uniform sampler2D tWindForce;"
        # "uniform float windScale;"
        # "uniform float time;"


        # "varying float vWindForce;"        
        # "varying vec2 windUV;"   
        # "varying float fSize;"

        THREE.ShaderChunk[ "color_pars_vertex" ]
        THREE.ShaderChunk[ "shadowmap_pars_vertex" ]

        "void main() {"

            # THREE.ShaderChunk[ "color_vertex" ]


            "vRotation = rotation;"
            "vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );",

            "#ifdef USE_SIZEATTENUATION",
                "gl_PointSize = size * ( scale / length( mvPosition.xyz ) );",
            "#else",
                "gl_PointSize = size;",
            "#endif",

            "gl_Position = projectionMatrix * mvPosition;",

            THREE.ShaderChunk[ "worldpos_vertex" ]
            THREE.ShaderChunk[ "shadowmap_vertex" ]

        "}"

    ].join("\n")

    fragmentShader: [

        "uniform vec3 psColor;"
        "uniform float opacity;"
        "varying float vRotation;"
        "const float mid = 0.5;"

        # "varying float vSpeed;"
        # "varying float vWindForce;"
        # "uniform sampler2D tWindForce;"
        # "varying vec2 windUV;" 
        # "varying float fSize;"
        # "uniform float time;"


        THREE.ShaderChunk[ "color_pars_fragment" ]
        THREE.ShaderChunk[ "map_particle_pars_fragment" ]
        THREE.ShaderChunk[ "fog_pars_fragment" ]
        THREE.ShaderChunk[ "shadowmap_pars_fragment" ]

        "void main() {"

            "gl_FragColor = vec4( psColor, opacity );"

            # THREE.ShaderChunk[ "map_particle_fragment" ]

            "#ifdef USE_MAP",
              # "float mid = 0.5;"
              "vec2 rotated = vec2(cos(vRotation) * (gl_PointCoord.x - mid) + sin(vRotation) * (gl_PointCoord.y - mid) + mid, cos(vRotation) * (gl_PointCoord.y - mid) - sin(vRotation) * (gl_PointCoord.x - mid) + mid);"
              # "gl_FragColor = vec4( color * vColor, 1.0 ) * rotatedTexture;"
              "gl_FragColor = texture2D( map,  rotated);"

              # original
              # "gl_FragColor = gl_FragColor * texture2D( map, vec2( gl_PointCoord.x, 1.0 - gl_PointCoord.y ) );",
            "#endif"

            THREE.ShaderChunk[ "alphatest_fragment" ]
            THREE.ShaderChunk[ "color_fragment" ]
            THREE.ShaderChunk[ "shadowmap_fragment" ]
            THREE.ShaderChunk[ "fog_fragment" ]

        "}"

    ].join("\n")