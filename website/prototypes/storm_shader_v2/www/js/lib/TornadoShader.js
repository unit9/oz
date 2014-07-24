/**
 * Based on:
 *
 * @author alteredq / http://alteredqualia.com/
 *
 * Depth-of-field shader with bokeh
 * ported from GLSL shader by Martins Upitis
 * http://artmartinsh.blogspot.com/2010/02/glsl-lens-blur-filter-with-bokeh.html
 */

THREE.TornadoShader = {

	uniforms: {

		"tColor":   { type: "t", value: null },
		"tDepth":   { type: "t", value: null },
		"focus":    { type: "f", value: 1.0 },
		"aspect":   { type: "f", value: 1.0 },
		"aperture": { type: "f", value: 0.025 },
		"maxblur":  { type: "f", value: 1.0 },
		"time": 	{ type: "f", value: 0.0 },
		
		"camView"  : { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) },
		"camUp"  : { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) },
		"camPos"  : { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) },
		"resolution"  : { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) },

	},

	vertexShader: [

		"varying vec2 vUv;",

		"void main() {",

			"vUv = uv;",
			"gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );",

		"}"

	].join("\n"),

	fragmentShader: [

		"varying vec2 vUv;",

		"uniform sampler2D tColor;",
		"uniform sampler2D tDepth;",

		"uniform float maxblur;",  // max blur amount
		"uniform float aperture;", // aperture - bigger values for shallower depth of field

		"uniform float focus;",
		"uniform float aspect;",

		"uniform float time;",

		"uniform vec3 camView;",
		"uniform vec3 camUp;",
		"uniform vec3 camPos;",

		"//Util Start",
		"vec2 ObjUnion(in vec2 obj0,in vec2 obj1){",
		  "if (obj0.x<obj1.x)",
		  	"return obj0;",
		  "else",
		  	"return obj1;",
		"}",

		"//Util End",

		"//Scene Start",

		"//Floor",
		"vec2 obj0(in vec3 p){",
		  "return vec2(p.y+3.0,0);",
		"}",
		"//Floor Color (checkerboard)",
		"vec3 obj0_c(in vec3 p){",
		 "if (fract(p.x*.5)>.5)",
		   "if (fract(p.z*.5)>.5)",
		     "return vec3(0,0,0);",
		   "else",
		     "return vec3(1,1,1);",
		 "else",
		   "if (fract(p.z*.5)>.5)",
		     "return vec3(1,1,1);",
		   "else",
		     	"return vec3(0,0,0);",
		"}",

		"//IQs RoundBox (try other objects http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm)",
		"vec2 obj1(in vec3 p){",
		  "return vec2(length(max(abs(p)-vec3(1,1,1) * 0.1,0.0))-0.25,1);",
		"}",

		"//RoundBox with simple solid color",
		"vec3 obj1_c(in vec3 p){",
			"return vec3(1.0,0.5,0.2);",
		"}",

		"//Objects union",
		"vec2 inObj(in vec3 p){",
		  "//return ObjUnion(obj0(p),obj1(p));",
		  "return obj1(p);",
		"}",

		"//Scene End",

		"void main() {",

			"vec2 vPos = vUv.xy;",
			
			"//Camera animation",
			// "vec3 vuv = vec3(0.0, 1.0, 0.0 );//Change camere up vector here",
			// "vec3 vrp = vec3(0.0, 10.0, 0.0); //Change camere view here",
			// "vec3 prp = vec3(-sin(time)*8.0,4,cos(time)*8.0); //Change camera path position here",
			// "vec3 prp = normalize(vec3(camX, camY, camZ));",

			"vec3 vuv = camUp;",
			"vec3 vrp = camView;",
			"vec3 prp = normalize(camPos);",

			"//Camera setup",
			"vec3 vpn=normalize(vrp-prp);",
			"vec3 u=normalize(cross(vuv,vpn));",
			"vec3 v=cross(vpn,u);",
			"vec3 vcv=(prp+vpn);",
			"vec3 scrCoord=vcv+vPos.x*u*vUv.x/vUv.y+vPos.y*v;",
			"vec3 scp=normalize(scrCoord-prp);",

			"//Raymarching",
			"const vec3 e=vec3(0.1,0,0);",
			"const float maxd=60.0; //Max depth",

			"vec2 s=vec2(0.1,0.0);",
			"vec3 c,p,n;",

			"float f=1.0;",
			"for(int i=0;i<256;i++){",
			"if (abs(s.x)<.01||f>maxd) break;",
			"f+=s.x;",
			"p=prp+scp*f;",
			"s=inObj(p);",
			"}",

			"if (f<maxd){",
			"if (s.y==0.0)",
			  "c=obj0_c(p);",
			"else",
			  "c=obj1_c(p);",
			"n=normalize(",
			  "vec3(s.x-inObj(p-e.xyy).x,",
			       "s.x-inObj(p-e.yxy).x,",
			       "s.x-inObj(p-e.yyx).x));",
			"float b=dot(n,normalize(prp-p));",
			"gl_FragColor=vec4((b*c+pow(b,8.0))*(1.0-f*.01),1.0);//simple phong LightPosition=CameraPosition",
			"}",
			// "else gl_FragColor=vec4(0,0,0,0); //background color",
			"else gl_FragColor = texture2D( tColor, vUv );",
			


			/* 	----------------------------------------
			 * 	DEBUG TEXTURE EXAMPLE
			 * 	---------------------------------------- */
			
			/*			

			"vec4 color = texture2D( tDepth, vUv );",
    		"gl_FragColor = vec4( color.rgb, 1.0 );",

    		*/



    		/* 	----------------------------------------
			 * 	DUMMY LINE SHADER EXAMPLE
			 * 	---------------------------------------- */

			 /*
    		
			"vec2 uPos = vUv.xy;",

			"uPos.x -= 0.5;",

			"float vertColor = 0.0;",

			"for( float i = 0.0; i < 1.0; ++i )",

			"{",

				"float t = time * (i + 0.9);",

				"uPos.x += sin( uPos.y + t ) * 0.3;",

				"float fTemp = abs(1.0 / uPos.x / 1000.0);",

				"vertColor += fTemp;",

			"}",

			"vec4 text = texture2D( tDepth, vUv );",

			"vec4 color = vec4( vertColor * 2., vertColor, vertColor , 1.0 );",

			"gl_FragColor = color;",

			*/
			

			/* 	----------------------------------------
			 * 	DEPTH OF FIELD SHADER EXAMPLE
			 * 	---------------------------------------- */

			/*

			"vec2 aspectcorrect = vec2( 1.0, aspect );",

			"vec4 depth1 = texture2D( tDepth, vUv );",

			"float factor = depth1.x - focus;",

			"vec2 dofblur = vec2 ( clamp( factor * aperture, -maxblur, maxblur ) );",

			"vec2 dofblur9 = dofblur * 0.9;",
			"vec2 dofblur7 = dofblur * 0.7;",
			"vec2 dofblur4 = dofblur * 0.4;",

			"vec4 col = vec4( 0.0 );",

			"col += texture2D( tColor, vUv.xy );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.0,   0.4  ) * aspectcorrect ) * dofblur );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.15,  0.37 ) * aspectcorrect ) * dofblur );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.29,  0.29 ) * aspectcorrect ) * dofblur );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.37,  0.15 ) * aspectcorrect ) * dofblur );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.40,  0.0  ) * aspectcorrect ) * dofblur );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.37, -0.15 ) * aspectcorrect ) * dofblur );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.29, -0.29 ) * aspectcorrect ) * dofblur );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.15, -0.37 ) * aspectcorrect ) * dofblur );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.0,  -0.4  ) * aspectcorrect ) * dofblur );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.15,  0.37 ) * aspectcorrect ) * dofblur );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.29,  0.29 ) * aspectcorrect ) * dofblur );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.37,  0.15 ) * aspectcorrect ) * dofblur );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.4,   0.0  ) * aspectcorrect ) * dofblur );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.37, -0.15 ) * aspectcorrect ) * dofblur );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.29, -0.29 ) * aspectcorrect ) * dofblur );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.15, -0.37 ) * aspectcorrect ) * dofblur );",

			"col += texture2D( tColor, vUv.xy + ( vec2(  0.15,  0.37 ) * aspectcorrect ) * dofblur9 );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.37,  0.15 ) * aspectcorrect ) * dofblur9 );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.37, -0.15 ) * aspectcorrect ) * dofblur9 );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.15, -0.37 ) * aspectcorrect ) * dofblur9 );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.15,  0.37 ) * aspectcorrect ) * dofblur9 );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.37,  0.15 ) * aspectcorrect ) * dofblur9 );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.37, -0.15 ) * aspectcorrect ) * dofblur9 );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.15, -0.37 ) * aspectcorrect ) * dofblur9 );",

			"col += texture2D( tColor, vUv.xy + ( vec2(  0.29,  0.29 ) * aspectcorrect ) * dofblur7 );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.40,  0.0  ) * aspectcorrect ) * dofblur7 );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.29, -0.29 ) * aspectcorrect ) * dofblur7 );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.0,  -0.4  ) * aspectcorrect ) * dofblur7 );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.29,  0.29 ) * aspectcorrect ) * dofblur7 );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.4,   0.0  ) * aspectcorrect ) * dofblur7 );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.29, -0.29 ) * aspectcorrect ) * dofblur7 );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.0,   0.4  ) * aspectcorrect ) * dofblur7 );",

			"col += texture2D( tColor, vUv.xy + ( vec2(  0.29,  0.29 ) * aspectcorrect ) * dofblur4 );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.4,   0.0  ) * aspectcorrect ) * dofblur4 );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.29, -0.29 ) * aspectcorrect ) * dofblur4 );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.0,  -0.4  ) * aspectcorrect ) * dofblur4 );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.29,  0.29 ) * aspectcorrect ) * dofblur4 );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.4,   0.0  ) * aspectcorrect ) * dofblur4 );",
			"col += texture2D( tColor, vUv.xy + ( vec2( -0.29, -0.29 ) * aspectcorrect ) * dofblur4 );",
			"col += texture2D( tColor, vUv.xy + ( vec2(  0.0,   0.4  ) * aspectcorrect ) * dofblur4 );",

			"gl_FragColor = col / 41.0;",
			"gl_FragColor.a = 1.0;",

			*/
			

		"}"

	].join("\n")

};
