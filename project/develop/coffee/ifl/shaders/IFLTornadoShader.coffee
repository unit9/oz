class IFLTornadoShader

    uniforms: null

    constructor:->
        @uniforms =
            "tDiffuse":      { type: "t", value: null }
            "time":          { type: "f", value: 0 }
            "resolution":    { type: "v2", value: new THREE.Vector2(0,0) }
            "camera_matrix": { type: "m4", value: new THREE.Matrix4() }

            "tornado_bounding_radius": { type: "f", value: 80.0 }
            "light_harshness":         { type: "f", value: 0.3 }
            "light_darkness":          { type: "f", value: 1.0 }
            "cloud_edge_sharpness":    { type: "f", value: 1.0 }
            "storm_tint":              { type: "v3", value: new THREE.Vector3(1,1,1) }
            "final_colour_scale":      { type: "f", value: 10.0 }
            "gamma_correction":        { type: "f", value: 1.7 }
            "environment_rotation":    { type: "f", value: 0.2 }
            "storm_alpha_correction":  { type: "f", value: 1.7 }
            "tornado_density":         { type: "f", value: 0.2 }
            "tornado_height":          { type: "f", value: 120.0 }
            "spin_speed":              { type: "f", value: 0.2 }
            "base_step_scaling":       { type: "f", value: 0.7 }
            "min_step_size":           { type: "f", value: 1.0 }
            "cam_fov":                 { type: "f", value: 60.0 }
            "dist_approx":             { type: "f", value: 1.0 }

    vertexShader: [

        "varying vec2 vUv;"
        "void main() {"
            "vUv = uv;"
            "gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);"
        "}"

    ].join("\n")

    fragmentShader: [

        "// The 'Storm Shader' by Dmytry Lavrov, Copyright 2012 (http://dmytry.com/) with permission from Moritz Helmsteadter at The Max Plank Institute"
        "// is licensed under a Creative Commons attribution license http://creativecommons.org/licenses/by/3.0"
        "// free to share and remix for any purpose as long as it includes this note."

        "#ifdef GL_ES"
        "precision mediump float;"
        "#endif"

        "// change these to 0 to disable specific features"
        "#define BENT 0"
        "#define FAKE_DIRECTIONAL_LIGHT 0"
        "#define ENVIRONMENT_TEXTURE 1"
        "#define NEGATE_Z 1  /// set to 1 for production viewer to match opengl convention"
        "#define USE_BOUNDING_VOLUME 1"

        "uniform float cam_fov;"
        "const float pi=3.141592654;"

        "#if BENT"
        "const float bend_height=50.0;"
        "const float bend_displacement=20.0;/// Watch out for bounding volume. The tornado's radius is about 25 units."
        "#endif"

        "uniform float tornado_bounding_radius; /// = max(pow(tornado_height,1.5)*0.03, bend_displacement)+10;"
        "uniform float light_harshness;/// adjust these two parameters to chage the look of tornado."
        "uniform float light_darkness;"
        "uniform float cloud_edge_sharpness;/// decrease to make fuzzier edge."
        "uniform vec3 storm_tint;"
        "uniform float final_colour_scale;"
        "uniform float gamma_correction;"
        "uniform float environment_rotation;"
        "uniform float storm_alpha_correction;"
        "uniform float tornado_density;"
        "uniform float tornado_height;"
        "uniform float spin_speed;"

        "const int number_of_steps=180;/// number of isosurface raytracing steps"
        "uniform float base_step_scaling;/// Larger values allow for faster rendering but cause rendering artifacts. When stepping the isosurface, the value is multiplied by this number to obtain the distance of each step"
        "uniform float min_step_size;/// Minimal step size, this value is added to the step size, larger values allow to speed up the rendering at expense of artifacts."
        "uniform float dist_approx;"

        "// input values passed into this shader"
        "uniform float time;/// use for blinking effects"
        "uniform vec2 resolution;/// screen resolution"
        "uniform mat4 camera_matrix; /// transform from camera to the world (not from the world to the camera"

        "const vec3 towards_sun=vec3(1,5.0,1.0);"

        "#if ENVIRONMENT_TEXTURE"
        "uniform sampler2D tDiffuse;"
        "#endif"

        "float hash( float n )"
        "{"
            "return fract(sin(n)*43758.5453);"
        "}"

        "float snoise( in vec3 x )"
        "{"
            "vec3 p = floor(x);"
            "vec3 f = fract(x);"
            "f = f*f*(3.0-2.0*f);"
            "float n = p.x + p.y*57.0+p.z*137.0;"
            "float res = 1.0-2.0*mix("
                "mix(mix( hash(n+  0.0), hash(n+  1.0),f.x), mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),"
                "mix(mix( hash(n+  137.0), hash(n+  138.0),f.x), mix( hash(n+ 57.0+137.0), hash(n+ 58.0+137.0),f.x),f.y),"
                "f.z"
            ");"
            "return res;"
        "}"

        "mat2 Spin(float angle){"
            "return mat2(cos(angle),-sin(angle),sin(angle),cos(angle));"
        "}"
        "float ridged(float f){"
            "return 1.0-2.0*abs(f);"
        "}"

        "float sigmoid(float f){"
            "if(f<0.0)return 0.0;"
            "if(f>1.0)return 1.0;"
            "return f*f*(3.0-f*2.0);"
        "}"

        "float Shape(vec3 q)/// the isosurface shape function, the surface is at o(q)=0"
        "{ "
            "float t=time;"
            "if(q.z<0.0)return length(q);"

            "#if BENT"
            	"q.x+=sigmoid(1.0-q.z/bend_height)*bend_displacement;"
            "#endif"

            "vec3 spin_pos=vec3(Spin(t-sqrt(q.z))*q.xy,q.z-t*5.0);"
            "float zcurve=pow(q.z,1.5)*0.03;"
            "float v1=clamp(zcurve*0.2,0.1,1.0)*snoise(spin_pos*vec3(0.1,0.1,0.1))*5.0;"
            "float v=abs(length(q.xy)-zcurve)-5.5-v1;"
            "v=v-ridged(snoise(vec3(Spin(t*1.5+0.1*q.z)*q.xy,q.z-t*4.0)*0.3))*1.2;"
            "//v+=max(0.0,q.z-tornado_height);"
            "return v;"
        "}"

        "vec2 TextureCoord(vec3 q){"
        	"#if BENT"
    	        "q.x+=sigmoid(1.0-q.z/bend_height)*bend_displacement;"
	        "#endif"
            "//return vec2(atan(q.y,q.x)*(0.5/pi), 1.0-q.z/tornado_height);"
            "return vec2(mod(atan(q.y,q.x)*(0.5/pi)+environment_rotation,1.0), mod(1.0-q.z/tornado_height,1.0));"
        "}"

        "//Normalized gradient of the field at the point q , used as surface normal"
        "vec3 GetNormal(vec3 q)"
        "{"
         "vec3 f=vec3(0.5,0.0,0.0);"
         "float b=Shape(q);"
         "return normalize(vec3(Shape(q+f.xyy)-b, Shape(q+f.yxy)-b, Shape(q+f.yyx)-b));"
        "}"

        "void Fog_(float dist, out vec3 colour, out vec3 multiplier){/// calculates fog colour, and the multiplier for the colour of item behind the fog. If you do two intervals consecutively it will calculate the result correctly."
          "vec3 fog=exp(-dist*vec3(0.03,0.05,0.1)*0.2);"
          "colour=vec3(1.0)-fog;"
          "multiplier=fog;/// (1.0-a)+a*(1.0-b + b*x) = 1.0-a+a-ab+abx = 1.0-ab+abx"
        "}"
        "void FogStep(float dist, vec3 fog_absorb, vec3 fog_reemit, inout vec3 colour, inout vec3 multiplier){/// calculates fog colour, and the multiplier for the colour of item behind the fog. If you do two intervals consecutively it will calculate the result correctly."
            "vec3 fog=exp(-dist*fog_absorb);"
            "colour+=multiplier*(storm_tint-fog)*fog_reemit;"
            "multiplier*=fog;/// (1.0-a)+a*(1.0-b + b*x) = 1.0-a+a-ab+abx = 1.0-ab+abx"

        "}"

        "bool RayCylinderIntersect(vec3 org, vec3 dir, out float min_dist, out float max_dist){ "
            "vec2 p=org.xy;"
            "vec2 d=dir.xy;"
            "float r=tornado_bounding_radius;"
            "float a=dot(d,d)+1.0E-10;/// A in quadratic formula , with a small constant to avoid division by zero issue"
            "float det, b;"
            "b = -dot(p,d); /// -B/2 in quadratic formula"
            "/// AC = (p.x*p.x + p.y*p.y + p.z*p.z)*dd + r*r*dd "
            "det=(b*b) - dot(p,p)*a + r*r*a;/// B^2/4 - AC = determinant / 4"
            "if (det<0.0){"
                "return false;"
            "}"
            "det= sqrt(det); /// already divided by 2 here"
            "min_dist= (b - det)/a; /// still needs to be divided by A"
            "max_dist= (b + det)/a;  "

            "if(max_dist>0.0){"
                "return true;"
            "}else{"
                "return false;"
            "}"
        "}"

        "void RaytraceFoggy(vec3 org, vec3 dir, float min_dist, float max_dist, inout vec3 colour, inout vec3 multiplier){"
            "vec3 q=org+dir*min_dist;"
            "vec3 pp;"

            "float d=0.0;"
            "float old_d=d;"
            "float dist=min_dist;"

            "#if ENVIRONMENT_TEXTURE"
                "vec3 tx_colour = vec3(0.0, 0.0, 0.0);"
                "float rrr=180.0/5.0;"
                "for(int i=0;i<5;i++)"
                    "tx_colour += texture2D(tDiffuse, TextureCoord(org+dir*(min_dist+min_step_size*rrr*dist_approx))).xyz;"
                "tx_colour = (tx_colour / 5.0) * 0.35;"
            "#endif"
            "float step_scaling=base_step_scaling;"

            "float extra_step=min_step_size;"
            "for(int i=0;i<number_of_steps;i++)"
            "{"
                "old_d=d;"
                "float density=-Shape(q);"
                "d=max(density*step_scaling,0.0);"
                "float step_dist=d+extra_step;"
                "if(density>0.0){"
                    "float d2=-Shape(q+towards_sun);"
                    "//float brightness=exp(-0.7*clamp(d2,-10.0,20.0));"
                    "float v=-0.6*density;"
                    "#if FAKE_DIRECTIONAL_LIGHT"
                    "v-=clamp(d2*light_harshness,0.0,light_darkness);"
                    "#endif"
                    "float brightness=exp(v);"
                    "vec3 fog_colour=vec3(brightness);"
                    "#if ENVIRONMENT_TEXTURE"
                        "//vec3 tx_colour=texture2D(tDiffuse, TextureCoord(q)).xyz;"
                        "fog_colour *= tx_colour;"
                    "#endif"
                    "//FogStep(step_dist*0.2, clamp(density*cloud_edge_sharpness, 0.0, 1.0)*vec3(1,1,1), fog_colour, colour, multiplier);"
                    "FogStep(step_dist*tornado_density, clamp(density*cloud_edge_sharpness, 0.0, 1.0)*vec3(1,1,1), fog_colour, colour, multiplier);"
                "}"

                "if(dist>max_dist || multiplier.x<0.01){"
                    "return;"
                "}"
                "dist+=step_dist; "
                "q=org+dist*dir;"
            "}   "
            "return;"
        "}"

        "void main(void)"
        "{"

            "vec2 p = -1.0 + 2.0 * gl_FragCoord.xy / resolution.xy;"
            "p.y *= resolution.y/resolution.x;"

            "float dirz=1.0/tan(cam_fov*0.5*pi/180.0);"
            "#if NEGATE_Z"
            "dirz=-dirz;"
            "#endif"
            "//dirz=-2.5;"

            "vec3 dir=normalize(vec3(p.x,p.y,dirz));"
            "dir=(camera_matrix*vec4(dir,0.0)).xyz;"

            "//Raymarching the isosurface:"
            "float dist;"
            "vec3 multiplier=vec3(1.0);"
            "vec3 color=vec3(0.0);"
            "vec3 org=camera_matrix[3].xyz;/// origin of the ray"
            "float min_dist=0.0, max_dist=1.0E4;"
            "#if USE_BOUNDING_VOLUME"
                "if(!RayCylinderIntersect(org, dir, min_dist, max_dist)) {"
                    "discard;"
                    "return;"
                "}"
                "min_dist=max(min_dist,0.0);"
            "#endif"
            "RaytraceFoggy(org, dir, min_dist, max_dist, color, multiplier);"
            "vec3 col = pow(color, vec3(gamma_correction))*final_colour_scale;"
            "float a = 1.0 - (multiplier.r);"
            "gl_FragColor = vec4(col, pow(a, storm_alpha_correction));"
        "}"

    ].join("\n")