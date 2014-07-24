class IFLCloudsShader

    uniforms: { 
        "time": { type: "f", value: 1.0 }
        "resolution": { type: "v3", value: new THREE.Vector3( 200, 200, 1 ) }
        "mouse" :  { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) }
        "zoom" :  { type: "f", value: 1.0 }
    }

    vertexShader: [

        "varying vec3 vViewPosition;"

        "void main() {"

            "vec4 mPosition = modelMatrix * vec4( position, 1.0 );"
            "vViewPosition = cameraPosition - mPosition.xyz;"

            "gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );"

        "}"

    ].join("\n")
   
    fragmentShader: [

        "//some ugly clouds"
        "//noise function lifted from that eye"
        "//added modification so I have 3d noise"
        "//and now with some ugly god rays"

        "//CBS: Playing around with some sin / cos functions"

        "#ifdef GL_ES"
        "precision mediump float;"
        "#endif"

        "uniform float time;"
        "uniform vec2 mouse;"
        "uniform vec3 resolution;"

        "mat2 m = mat2( 0.90,  0.110, -0.70,  1.00 );"
        "float numfreq = 2.0;"

        "float hash( float n )"
        "{"
            "return fract(sin(n)*758.5453);"
        "}"

        "float noise( in vec3 x )"
        "{"
            "vec3 p = floor(x);"
            "vec3 f = fract(x);"
            "//f = f*f*(3.0-2.0*f);"
            "float n = p.x + p.y*57.0 + p.z*800.0;"
            "float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x), mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),"
            "mix(mix( hash(n+800.0), hash(n+801.0),f.x), mix( hash(n+857.0), hash(n+858.0),f.x),f.y),f.z);"
            "return res;"
        "}"

        "float fbm( vec3 p )"
        "{"
            "float f = 0.0;"
            "f += 0.50000*noise( p ); p = p*numfreq+0.02;"
            "f += 0.25000*noise( p ); p = p*numfreq+0.03;"
            "f += 0.12500*noise( p ); p = p*numfreq+0.01;"
            "f += 0.06250*noise( p ); p = p*numfreq+0.04;"
            "f += 0.03125*noise( p );"
            "return f/0.984375;"
        "}"

        "float cloud(vec3 p)"
        "{"
            "p+=fbm(vec3(p.x,p.y,0.0)*0.5)*2.9;"

            "float a =0.0;"
            "a+=fbm(p*3.0)*2.2-0.9;"
            "if (a<0.0) a=0.0;"
            "//a=a*a;"
            "return a;"
        "}"

        "vec3 f2(vec3 c)"
        "{"
            "c+=hash(time+gl_FragCoord.x+gl_FragCoord.y*9.9)*0.01;"

            "c*=0.7-length( gl_FragCoord.xy / resolution.xy - 0.5) * 0.6;"
            "float w=length(c);"
            "c=mix(c*vec3(0.0,0.0,0.0),vec3(w,w,w)*vec3(1.1,1.1,1.1),w*1.1-0.2);"
            "return c;"
        "}"

        "float rand(vec2 co){"
            "return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43768.5453);"
        "}"

        "void main( void ) {"

            "vec2 position = ( gl_FragCoord.xy / resolution.xy ) ;"
            "position.y+=0.2;"
    
            "vec2 coord= vec2((position.x-0.5)/position.y,1.0/(position.y+0.2))*vec2(-0.5,0.5);"
            "coord+=time*0.01;"
            
            
            "float q = cloud(vec3(coord*1.0,time*0.0222));"
            "float qx= cloud(vec3(coord+vec2(0.156,0.0),time*0.0222));"
            "float qy= 0.1; //cloud(vec3(coord+vec2(0.0,0.156),time*0.0222));"
            "q+=qx+qy; q*=0.33333;"
            "qx=q-qx;"
            "qy=q-qy;"
            
            "float s =(-qx*2.0-qy*0.3); if (s<-0.05) s=-0.05;"
            
            "vec3 d=s*vec3(0.9,0.6,0.3);"
            
            "//d=max(vec3(0.0),d);"
            "//d+=0.1;"
            
            "d*=0.2;"
            "d=mix(vec3(1.0,1.0,1.0)*0.1+d*1.0,vec3(1.0,1.0,1.0)*0.9,1.0-pow(q,0.03)*1.1);"
            
            "d*=8.0;"
            
            "//d+=cos(time*0.01-0.5);"
            
            "vec3 color;"
            "vec3 col = vec3(0.0);"
            
            "color = vec3(d.x, d.y, d.z);"
            "col += (color*1.0);"
            
            "gl_FragColor = vec4( f2(col), 1.0 );"
        "}"

    ].join("\n")