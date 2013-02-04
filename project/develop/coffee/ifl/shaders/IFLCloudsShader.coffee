# Shader for clouds particle system

class IFLCloudsShader

    uniforms: null

    constructor:->
        @uniforms =
            "tDiffuse":   { type: "t",  value: null }
            "scale":      { type: "f",  value: 100.0 }
            "alpha":      { type: "f",  value: 1.0 }
            "angle":      { type: "f",  value: 0.0 }
            "rotation":   { type: "f",  value: 0.0 }
            "dist":       { type: "f",  value: 200.0 }
            "resolution": { type: "v2", value: new THREE.Vector2(1.0, 1.0) }

    vertexShader: [

        "varying vec2  vUV;"
        "varying float vAlpha;"

        "uniform float scale;"
        "uniform float alpha;"
        "uniform float angle;"
        "uniform float rotation;"
        "uniform float dist;"
        "uniform vec2  resolution;"
        "const float MINZ = 40.0;"
        "const float MAXZ = 100.0;"

        "void main() {"

            "vUV = uv;"
            "mat4 matRot = mat4( cos( angle ), -sin( angle ), 0.0, 0.0, sin( angle ), cos( angle ), 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0 );"
            "gl_Position = projectionMatrix * modelViewMatrix * vec4(0.0, 0.0, 0.0, 1.0);"
            "//float fScale = scale * dist / gl_Position.z;"
            "float fScale = dist;"
            "gl_Position = gl_Position + matRot * vec4((uv.x - 0.5) * fScale , (uv.y - 0.5) * fScale, 0.0, 0.0);"
            "vAlpha = alpha;"
            "/*if (gl_Position.z < MINZ)"
                "vAlpha = 0.0;"
            "if (gl_Position.z >= MINZ && gl_Position.z <= MAXZ) {"
                "vAlpha = (gl_Position.z - MINZ) / (MAXZ - MINZ);"
            "}*/"
        "}"

    ].join("\n")

    fragmentShader: [

        "uniform sampler2D tDiffuse;"
            
        "varying vec2  vUV;"
        "varying float vAlpha;"

        "void main() {"
            "gl_FragColor = texture2D(tDiffuse, vUV);"
            "gl_FragColor.a *= vAlpha;"
        "}"

    ].join("\n")
