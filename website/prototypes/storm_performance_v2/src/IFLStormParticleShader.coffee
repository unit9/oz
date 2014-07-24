class IFLStormParticleShader
	uniforms:  THREE.UniformsUtils.merge( [

		THREE.UniformsLib[ "particle" ]
		THREE.UniformsLib[ "shadowmap" ]
		THREE.UniformsLib[ "normalmap" ]
		"envMap" : { type: "t", value: null }
		"transparencyMap" : { type: "t", value: null }
		"alpha" : { type: "f", value: 0.1 }

	] ),

	vertexShader: [

		"uniform float size;"
		"uniform float scale;"
		"uniform float alpha;"

		"uniform sampler2D transparencyMap;"
		"varying vec3 vWorldPosition;",
		"varying vec3 vReflect;",
		"varying vec3 vNWorld;",
		"varying vec3 vNormal;",
		# "varying vec3 vViewPosition;",

		THREE.ShaderChunk[ "color_pars_vertex" ]
		THREE.ShaderChunk[ "shadowmap_pars_vertex" ]

		"void main() {"

			THREE.ShaderChunk[ "color_vertex" ]

			"vec4 mvPosition = modelViewMatrix * vec4( position, 1.0 );"
			"vWorldPosition = position.xyz;"

			"#ifdef USE_SIZEATTENUATION"
				"gl_PointSize = size * ( scale / length( mvPosition.xyz ) );"
			"#else"
				"gl_PointSize = size;"
			"#endif"

			"gl_Position = projectionMatrix * mvPosition;"
			
			"vNormal = mvPosition.xyz;"
			"vNWorld = mat3( modelMatrix[ 0 ].xyz, modelMatrix[ 1 ].xyz, modelMatrix[ 2 ].xyz ) * vNormal;",
			"vReflect = reflect( normalize( position.xyz - cameraPosition ), normalize( vNWorld.xyz ) );",
			

			THREE.ShaderChunk[ "worldpos_vertex" ]
			THREE.ShaderChunk[ "shadowmap_vertex" ]

		"}"

	].join("\n"),

	fragmentShader: [

		"uniform vec3 psColor;"
		"uniform float opacity;"
		"uniform float alpha;"
		"uniform sampler2D transparencyMap;"

		"varying vec3 vNWorld;",
		"varying vec3 vReflect;",
		"varying vec3 vNormal;",
		"varying vec3 vWorldPosition;",

		# "varying vec3 vViewPosition;",
		# "vec2 vUv;",

		THREE.ShaderChunk[ "color_pars_fragment" ]
		THREE.ShaderChunk[ "map_particle_pars_fragment" ]
		THREE.ShaderChunk[ "fog_pars_fragment" ]
		THREE.ShaderChunk[ "shadowmap_pars_fragment" ]


		"#ifdef USE_ENVMAP",

			# "uniform float reflectivity;",
			"uniform samplerCube envMap;",
			# "uniform float flipEnvMap;",
			# "uniform int combine;",

			# "#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP )",

				# "uniform bool useRefract;",
				# "uniform float refractionRatio;",

			# "#else",

			# 	"varying vec3 vReflect;",

			# "#endif",

		"#endif"

		"#ifdef USE_NORMALMAP",

			"uniform sampler2D normalMap;",
			"uniform vec2 normalScale;",


		"#endif"		

		"void main() {",

			"gl_FragColor = vec4( psColor, opacity );"


			# THREE.ShaderChunk[ "map_particle_fragment" ]


			# "#ifdef USE_MAP",
			# 	"gl_FragColor = gl_FragColor * texture2D( map,vec2( gl_PointCoord.x, 1.0 - gl_PointCoord.y ) );",
			# "#endif"

			"#ifdef USE_ENVMAP"

				"vec3 reflectVec;"

				"#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP )"
					"vec3 mapN = texture2D( normalMap, vec2( gl_PointCoord.x, 1.0 - gl_PointCoord.y ) ).xyz * 2.0 - 1.0;",
					"vec3 normal = normalize( mapN );",
					"vec3 cameraToVertex = normalize( vWorldPosition - cameraPosition );"
					"reflectVec = reflect( cameraToVertex, normal );"
					# "reflectVec.y = -reflectVec.y;"
					
				"#else"
					"reflectVec = vReflect;"
				"#endif"

				"vec4 cubeColor = textureCube( envMap, vec3( -reflectVec.x, reflectVec.yz ) );",
				"vec4 transColor = texture2D( transparencyMap, vec2( gl_PointCoord.x, 1.0 - gl_PointCoord.y ) );",

				# "gl_FragColor.xyz = mix( gl_FragColor.xyz, cubeColor.xyz * 2.0  , 1.0   );"
				"gl_FragColor = vec4( cubeColor.xyz * 2.0 , transColor.r * alpha);"

			"#endif"





			THREE.ShaderChunk[ "alphatest_fragment" ]
			# THREE.ShaderChunk[ "color_fragment" ]
			# THREE.ShaderChunk[ "shadowmap_fragment" ]
			# THREE.ShaderChunk[ "fog_fragment" ]

		"}"

	].join("\n")