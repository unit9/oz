# Simple and fast Sal2x shader, avoids blocky corners on tornado a bit

class IFLSal2x

    uniforms: null

    constructor:->
        @uniforms =
            "tDiffuse" :  { type: "t", value: null }
            "resolution": { type: "v2", value: new THREE.Vector2(0,0) }
            "opacity":    { type: "f", value: 1.0 }

    vertexShader: [

        "varying vec2 vUv;"
        "void main() {"
            "vUv = uv;"
            "gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);"
        "}"

    ].join("\n")

    fragmentShader: [

        "#ifdef GL_ES"
        "precision mediump float;"
        "#endif"

        "uniform sampler2D tDiffuse;"
        "uniform vec2 resolution;"
        "uniform float opacity;"

        "varying vec2 vUv;"

        "void main()"
        "{"
            "vec2 UL, UR, DL, DR;"

            "float dx = pow(resolution.x, -1.0) * 0.25;"
            "float dy = pow(resolution.y, -1.0) * 0.25;"
            "vec4 dt = vec4(1.0, 1.0, 1.0, 1.0);"

            "UL = vUv + vec2(-dx,-dy);"
            "UR = vUv + vec2( dx,-dy);"
            "DL = vUv + vec2(-dx, dy);"
            "DR = vUv + vec2( dx, dy);"

            "vec4 c00 = texture2D(tDiffuse, UL);"
            "vec4 c20 = texture2D(tDiffuse, UR);"
            "vec4 c02 = texture2D(tDiffuse, DL);"
            "vec4 c22 = texture2D(tDiffuse, DR);"

            "float m1 = dot(abs(c00-c22), dt) + 0.001;"
            "float m2 = dot(abs(c02-c20), dt) + 0.001;"

            "gl_FragColor = (m1*(c02+c20) + m2*(c22+c00)) / (2.0*(m1+m2));"
            "gl_FragColor.a *= opacity;"
        "}"

    ].join("\n")
