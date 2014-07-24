class IFLBasicShaderDoubleLightmap extends IFLBasicShader

    constructor:->
        @uniforms = THREE.UniformsUtils.merge [
            THREE.UniformsLib[ "common" ]
            THREE.UniformsLib[ "fog" ]
            {
                "diffuseMultiplier" : { type: "f",  value: 1 }
                "lightMapMultiplier": { type: "f",  value: 1 }
                "additiveLightMap"  : { type: "i",  value: 0 }
                "lightMap2"         : { type: "t",  value: null }
                "lightmapBlend"     : { type: "f",  value: 0.0 }
                "windMin"           : { type: "v2", value: new THREE.Vector2(-400,-800) }
                "windSize"          : { type: "v2", value: new THREE.Vector2(1000,1000) }
                "windDirection"     : { type: "v3", value: new THREE.Vector3(1,0,0) }
                "tWindForce"        : { type: "t",  value: null }
                "windScale"         : { type: "f",  value: 1.0 }                
            }]


        @fragmentShader = [

            "uniform vec3 diffuse;"
            "uniform float opacity;"
            "uniform float diffuseMultiplier;"
            "uniform bool additiveLightMap;"
            "uniform sampler2D lightMap2;"
            "uniform float lightmapBlend;"
            "uniform float lightMapMultiplier;"

            THREE.ShaderChunk[ "color_pars_fragment" ]
            THREE.ShaderChunk[ "map_pars_fragment" ]
            THREE.ShaderChunk[ "lightmap_pars_fragment" ]      
            THREE.ShaderChunk[ "fog_pars_fragment" ]

            "void main() {"

                "gl_FragColor = vec4( diffuse, opacity );"
                "#ifdef USE_MAP",
                    "gl_FragColor = gl_FragColor * ( texture2D( map, vUv ) * diffuseMultiplier );"
                "#endif"
                "#ifdef USE_LIGHTMAP",
                    "vec4 map2col = mix( texture2D( lightMap, vUv2 ), texture2D( lightMap2, vUv2 ), lightmapBlend) * lightMapMultiplier;"
                    "if( additiveLightMap ) {"
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



    

