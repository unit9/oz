THREE.ShaderConvolution3x3 = {	

	'kernels' : {
			sharpen : [
				-1, -1, -1,
				-1,  9, -1,
				-1, -1, -1
			],	

			blur : [
				 0, .3,  0,
				.3, .3, .3,
				 0, .3,  0
			],

			emboss : [
				-2,	-1,	 0,
				-1,	 1,	 1,
				 0,	 1,	 2
			],

			emboss_black : [
				2,  0, 0,
				0, -1, 0,
				0,  0, -1
			],

			emboss_black2 : [
				-1, -1,  0,
				-1,  0,  1,
				 0,  1,  1
			],

			edge_black : [
				-0.125, -0.125, -0.125,
				-0.125, 1,      -0.125,
				-0.125, -0.125, -0.125
			],

			edge_bright : [
			     1,  1,  1,
			     1, -7,  1,
			     1,  1,  1
			],

			motion_blur : [
				1,0,0,
				0,1,0,
				0,0,1
			],
	},

	'shader' : {
		uniforms: THREE.UniformsUtils.merge( [

			THREE.UniformsLib[ "common" ],
			{
				"cKernel" : 	{ type: "fv1", value: [] },
				"factor" : 		{ type: "f", value: 1 },
				"width" : 		{ type: "f", value: 1 },
				"height" : 		{ type: "f", value: 1 }
			}

		] ),

		vertexShader: [

			THREE.ShaderChunk[ "map_pars_vertex" ],
			
			"uniform float cKernel[9];",
			"uniform float width;",
			"uniform float height;",
			
			"varying vec2 uvs[9];",

			"void main() {",

				"vUv = uv * offsetRepeat.zw + offsetRepeat.xy;",
				
				"float dxtex = 1.0 / width;",
				"float dytex = 1.0 / height;",

				"uvs[0] = vUv.xy + vec2(-1.0*dxtex, -1.0*dytex);",
				"uvs[1] = vUv.xy + vec2(-1.0*dxtex, 0.0*dytex);",
				"uvs[2] = vUv.xy + vec2(-1.0*dxtex, 1.0*dytex);",

				"uvs[3] = vUv.xy + vec2(0.0*dxtex, -1.0*dytex);",
				"uvs[4] = vUv.xy + vec2(0.0*dxtex, 0.0*dytex);",
				"uvs[5] = vUv.xy + vec2(0.0*dxtex, 1.0*dytex);",

				"uvs[6] = vUv.xy + vec2(1.0*dxtex, -1.0*dytex);",
				"uvs[7] = vUv.xy + vec2(1.0*dxtex, 0.0*dytex);",
				"uvs[8] = vUv.xy + vec2(1.0*dxtex, 1.0*dytex);",

				//THREE.ShaderChunk[ "map_vertex" ],
				THREE.ShaderChunk[ "default_vertex" ],
			"}"

		].join("\n"),

		fragmentShader: [

			"uniform vec3 diffuse;",
			"uniform float opacity;",
			"uniform float cKernel[9];",
			"uniform float factor;",
			"varying vec2 uvs[9];",


			THREE.ShaderChunk[ "map_pars_fragment" ],


			"void main() {",
				"gl_FragColor = vec4(0.0,0.0,0.0, 1.0);",

				"vec4 colors[9];",
				"colors[0] = texture2D(map,uvs[0]);",
				"colors[1] = texture2D(map,uvs[1]);",
				"colors[2] = texture2D(map,uvs[2]);",

				"colors[3] = texture2D(map,uvs[3]);",
				"colors[4] = texture2D(map,uvs[4]);",
				"colors[5] = texture2D(map,uvs[5]);",

				"colors[6] = texture2D(map,uvs[6]);",
				"colors[7] = texture2D(map,uvs[7]);",
				"colors[8] = texture2D(map,uvs[8]);",


				"gl_FragColor += cKernel[0] * colors[0];",
				"gl_FragColor += cKernel[1] * colors[1];",
				"gl_FragColor += cKernel[2] * colors[2];",
				"gl_FragColor += cKernel[3] * colors[3];",
				"gl_FragColor += cKernel[4] * colors[4];",
				"gl_FragColor += cKernel[5] * colors[5];",
				"gl_FragColor += cKernel[6] * colors[6];",
				"gl_FragColor += cKernel[7] * colors[7];",
				"gl_FragColor += cKernel[8] * colors[8];",

				"gl_FragColor = clamp(gl_FragColor*factor, 0.0, 1.0);",

				THREE.ShaderChunk[ "map_fragment" ],
				THREE.ShaderChunk[ "linear_to_gamma_fragment" ],
			"}"

		].join("\n")
	}
}