class IFLTornadoShader

    uniforms: { 
        "time": { type: "f", value: 1.0 }
        "resolution": { type: "v3", value: new THREE.Vector3( 200, 200, 1 ) }
        "mouse" :  { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) }
        "zoom" :  { type: "f", value: 1.0 }
    }

    vertexShader: [

        "varying vec2 vUv;"
        "void main() {"
            "vUv  = uv;"
            "gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );"
        "}"

    ].join("\n")
    
    fragmentShader: [

        "uniform float time;"
        "uniform vec3 resolution;"

        "varying vec2  vUv;"

        "vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }"

        "float snoise(vec2 v) {"
            
            "const vec4 C = vec4(0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439);"
            
            "vec2 i  = floor(v + dot(v, C.yy) );"
            "vec2 x0 = v -   i + dot(i, C.xx);"
            "vec2 i1;"
            "i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);"
            "vec4 x12 = x0.xyxy + C.xxzz;"
            "x12.xy -= i1;"
            "i = mod(i, 289.0);"
            "vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 )) + i.x + vec3(0.0, i1.x, 1.0 ));"
            "vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),"
                "dot(x12.zw,x12.zw)), 0.0);"

            "m = m*m ;"
            "m = m*m ;"
            "vec3 x = 2.0 * fract(p * C.www) - 1.0;"
            "vec3 h = abs(x) - 0.5;"
            "vec3 ox = floor(x + 0.5);"
            "vec3 a0 = x - ox;"
            "m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );"
            "vec3 g;"
            "g.x  = a0.x  * x0.x  + h.x  * x0.y;"
            "g.yz = a0.yz * x12.xz + h.yz * x12.yw;"
            "return 130.0 * dot(m, g);"
        "}"

        "float fbm( vec2 p) {"
            "float f = -1.0;"
            "f += 0.5000*snoise(p); p *= 2.22;"
            "f += 0.2500*snoise(p); p *= 2.03;"
            "f += 0.1250*snoise(p); p *= 2.01;"
            "f += 0.0625*snoise(p); p *= 2.04;"
            "return f / 0.8375;"
        "}"

        "void main(void) {"
            
            "vec2 p = (vUv.xy * 2.0);"
    
            "float c2 = fbm(p - time/10.) + fbm(p - time/10.) + fbm(p - time/10.) + 9.0;"
            "float v = (((c2 * 0.1) - 0.75) * 1.45) + 0.3;"

            "gl_FragColor = vec4( vec3(v), 1.0 );"

        "}"

    ].join("\n")

    ###
        "// Based off of post by las"
        "// http://www.pouet.net/topic.php?which=7920&page=29&x=14&y=9"

        "// Storm Clouds - tz"

        "#ifdef GL_ES"
        "precision mediump float;"
        "#endif"

        "uniform float time;"

        "varying vec2  vUv;"

        "#define pi 3.14159265"
        "#define R(p, a) p=cos(a)*p+sin(a)*vec2(p.y, -p.x)"
        "#define hsv(h,s,v) mix(vec3(1.), clamp((abs(fract(h+vec3(3., 2., 1.)/3.)*6.-3.)-1.), 0., 1.), s)*v"

        "float pn(vec3 p) {"
           "vec3 i = floor(p);"
           "vec4 a = dot(i, vec3(1., 57., 21.)) + vec4(0., 57., 21., 78.);"
           "vec3 f = cos((p-i)*pi)*(-.5) + .5;"
           "a = mix(sin(cos(a)*a), sin(cos(1.+a)*(1.+a)), f.x);"
           "a.xy = mix(a.xz, a.yw, f.y);"
           "return mix(a.x, a.y, f.z);"
        "}"

        "float fpn(vec3 p) {"
           "return pn(p*.06125)*.5 + pn(p*.125)*.25 + pn(p*.25)*.125;"
        "}"

        "float sphere( vec3 p ) {"
          "return length(p) - 0.55;"
        "}"

        "float spheres( vec3 p ) {"
            "float scale = 0.6;"
            "return sphere(scale*vec3(sin(p.x + sin(p.x)*sin(p.z) + 0.125*time),p.y + 3.0, -cos(p.z + 0.25*time))* 0.8) /scale;  "
        "}"

        "float f(vec3 p) {"
           "R(p.xy, pi);"
           "R(p.xz, 0.0);"
           "return spheres(p) +  fpn(p*30.) * 0.525;"
        "}"

        "void main(void) {"
           "// p: position on the ray"
           "// d: direction of the ray"
           "vec3 p = vec3(0.,0.,1.2);"
           "vec3 d = vec3( ( ( vUv) -1.0 ) * vec2( vUv.x / vUv.y, 1.0), 0.0) - p + vec3(1.0, 0.5, 0.0);"
           "d = normalize(d);"
           
           "// ld, td: local, total density "
           "// w: weighting factor"
           "float ld = 0., td = 0.;"
           "float w = 0.;"
           
           "// sky coloring"
           "float height_factor = pow( 1.0 - d.y, 6.75 );"
           "vec3 zenith_color = vec3(0.192, 0.272, 0.41156);"
           "// vec3 horizon_color = vec3(0.3098, 0.4745, 0.8039);"
           "vec3 horizon_color = vec3(0.0, 0.0, 0.0);"
           "vec3 tc = mix( zenith_color, horizon_color, clamp( height_factor, 0.0, 1.0 ) );"
           
           "// i: 0 <= i <= 1."
           "// r: length of the ray"
           "// l: distance function"
           "float i = 0., r = 0., l = 0., b = 0.;"

           "// rm loop"
           "if (d.y>0.) for (float i=0.; (i<1.); i+=1./56.) {"
               "if(!((i<1.) && (l>=0.001*r) && (r < 25.)&& (td <= 1.0))) break;"
               
              "// evaluate distance function"
              "l = f(p) * 0.85;"
              
              "// check whether we are close enough"
              "if (l < .07) {"
                "// compute local density and weighting factor "
                "ld = 0.07 - l;"
                "w = (0.5 - td) * ld;"
                
                "// accumulate color and density"
                "tc += w; //* hsv(w, 1., 1.); "
                "td += w;"
              "}"
              "td += 1./90.;"
              
              "// enforce minimum stepsize"
              "l = max(l, 0.1);"
              
              "// step forward"
              "p += l*d;"
              "r += l;"
           "}"
              
           "gl_FragColor = vec4(tc, 1.0);"
        "}"
        ### 

        