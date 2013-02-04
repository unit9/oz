class IFLSkyCubeShader

    uniforms : null
    
    constructor:->
        @uniforms =
            "tCube": { type: "t", value: null }
            "tFlip": { type: "f", value: -1 } 
    

    vertexShader: [

        "varying vec3 vViewPosition;"

        "void main() {"

            "vec4 mPosition = modelMatrix * vec4( position, 1.0 );"
            "vViewPosition = cameraPosition - mPosition.xyz;"

            "gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );"

        "}"

    ].join("\n")

    fragmentShader: [

        "uniform samplerCube tCube;"
        "uniform float tFlip;"

        "varying vec3 vViewPosition;"

        "void main() {"

            "vec3 wPos = cameraPosition - vViewPosition;"
            "gl_FragColor = textureCube( tCube, vec3( tFlip * wPos.x, wPos.yz ) );"
            # "gl_FragColor.xyz *= 1.5;"
        "}"

    ].join("\n")