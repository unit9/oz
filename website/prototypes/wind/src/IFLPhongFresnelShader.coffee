class IFLPhongFresnelShader
	uniforms: THREE.UniformsUtils.merge( [
		THREE.UniformsLib[ "common" ]
		THREE.UniformsLib[ "bump" ]
		THREE.UniformsLib[ "normalmap" ]
		THREE.UniformsLib[ "fog" ]
		#THREE.UniformsLib[ "lights" ]
		THREE.UniformsLib[ "shadowmap" ]

		{
			"ambient"  : { type: "c", value: new THREE.Color( 0xffffff ) }
			"emissive" : { type: "c", value: new THREE.Color( 0x000000 ) }
			"specular" : { type: "c", value: new THREE.Color( 0x111111 ) }
			"shininess": { type: "f", value: 30 }
			"wrapRGB"  : { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) },

			"tAux": { type: "t", value: null },
			"mFresnelBias": { type: "f", value: 0 },
			"mFresnelGain": { type: "f", value: 1 },
			"mFresnelPower": { type: "f", value: 0.0 }


			"windMin": { type: "v2", value: new THREE.Vector2() }
			"windSize": { type: "v2", value: new THREE.Vector2() }
			"windDirection": { type: "v3", value: new THREE.Vector3(1,0,0) }
			"tWindForce": { type: "t", value: null }
			"windScale": { type: "f", value: 1.0 }


		}

	] ),

	vertexShader: [

		"#define PHONG"

		"varying vec3 vViewPosition;"
		"varying vec3 vNormal;"
		"varying vec3 vNWorld;",
		"varying vec3 vI;",


		THREE.ShaderChunk[ "map_pars_vertex" ]
		THREE.ShaderChunk[ "lightmap_pars_vertex" ]
		#THREE.ShaderChunk[ "envmap_pars_vertex" ]
		"varying vec3 vReflect;"

		"uniform vec2 windMin;"
		"uniform vec2 windSize;"
		"uniform vec3 windDirection;"
		"uniform sampler2D tWindForce;"
		"uniform float windScale;"


		"uniform float refractionRatio;"
		"uniform bool useRefract;"
	
		#THREE.ShaderChunk[ "lights_phong_pars_vertex" ]
		"varying vec3 vWorldPosition;"
		"varying float vWindForce;"
		THREE.ShaderChunk[ "color_pars_vertex" ]
		THREE.ShaderChunk[ "morphtarget_pars_vertex" ]
		THREE.ShaderChunk[ "skinning_pars_vertex" ]
		#THREE.ShaderChunk[ "shadowmap_pars_vertex" ]

		"void main() {",

			THREE.ShaderChunk[ "map_vertex" ]
			THREE.ShaderChunk[ "lightmap_vertex" ]
			THREE.ShaderChunk[ "color_vertex" ]

			THREE.ShaderChunk[ "morphnormal_vertex" ]
			THREE.ShaderChunk[ "skinbase_vertex" ]
			THREE.ShaderChunk[ "skinnormal_vertex" ]
			THREE.ShaderChunk[ "defaultnormal_vertex" ]

			"vNormal = objectNormal;",

			THREE.ShaderChunk[ "morphtarget_vertex" ]
			THREE.ShaderChunk[ "skinning_vertex" ]
			# THREE.ShaderChunk[ "default_vertex" ]
			
			"vec4 mvPosition;"
			"#ifdef USE_SKINNING"
				"mvPosition = modelViewMatrix * skinned;"
			"#endif"

			"#if !defined( USE_SKINNING ) && defined( USE_MORPHTARGETS )"
				"mvPosition = modelViewMatrix * vec4( morphed, 1.0 );"
			"#endif"

			"#if !defined( USE_SKINNING ) && ! defined( USE_MORPHTARGETS )"
				

				"vec4 wpos = modelMatrix * vec4( position, 1.0 );"
				"wpos.z = -wpos.z;"
				# wpos - windmin : windmax - windmin = x : 1
				"vec2 totPos = wpos.xz - windMin;"
				"vec2 windUV = totPos / windSize;"
				"vWindForce = texture2D(tWindForce,windUV).x;"
				"float windVertexScale = color.x;"

				"float windMod = ((1.0 - vWindForce)*windVertexScale) * windScale;"
				"vec4 pos = vec4(position , 1.0);"
				"pos.x += windMod * windDirection.x;"
				"pos.y += windMod * windDirection.y;"
				"pos.z += windMod * windDirection.z;"

				"mvPosition = modelViewMatrix *  pos;"


			"#endif"

			"gl_Position = projectionMatrix * mvPosition;"


			"vViewPosition = -mvPosition.xyz;"

			THREE.ShaderChunk[ "worldpos_vertex" ]
			# "#if defined( USE_ENVMAP ) || defined( PHONG ) || defined( LAMBERT ) || defined ( USE_SHADOWMAP )"

			# 	"#ifdef USE_SKINNING"
			# 		"vec4 mPosition = modelMatrix * skinned;"
			# 	"#endif"

			# 	"#if defined( USE_MORPHTARGETS ) && ! defined( USE_SKINNING )"
			# 		"vec4 mPosition = modelMatrix * vec4( morphed, 1.0 );"
			# 	"#endif"

			# 	"#if ! defined( USE_MORPHTARGETS ) && ! defined( USE_SKINNING )"
			# 		"vec4 mPosition = modelMatrix * vec4( position, 1.0 );"
			# 	"#endif"

			# "#endif"


			#THREE.ShaderChunk[ "envmap_vertex" ]
			"#if defined( USE_ENVMAP )",

				"vNWorld = mat3( modelMatrix[ 0 ].xyz, modelMatrix[ 1 ].xyz, modelMatrix[ 2 ].xyz ) * objectNormal;",

				"vI = normalize( mPosition.xyz - cameraPosition );"

				"if ( useRefract ) {",
					"vReflect = refract( vI, normalize( vNWorld.xyz ), refractionRatio );",
				"} else {",
					"vReflect = reflect( vI, normalize( vNWorld.xyz ) );",
				"}",	

			"#endif"
					
			#THREE.ShaderChunk[ "lights_phong_vertex" ]
			"vWorldPosition = mPosition.xyz;"



			#THREE.ShaderChunk[ "shadowmap_vertex" ]


		"}"

	].join("\n")

	fragmentShader: [

		"uniform vec3 diffuse;",
		"uniform float opacity;",

		"uniform vec3 ambient;",
		"uniform vec3 emissive;",
		"uniform vec3 specular;",
		"uniform float shininess;",

		"uniform sampler2D tAux;",
		"uniform float mFresnelBias;",
		"uniform float mFresnelGain;",
		"uniform float mFresnelPower;",
		"varying vec3 vNWorld;",
		"varying vec3 vI;",		
		"varying float vWindForce;"

		THREE.ShaderChunk[ "color_pars_fragment" ]
		THREE.ShaderChunk[ "map_pars_fragment" ]
		THREE.ShaderChunk[ "lightmap_pars_fragment" ]
		# THREE.ShaderChunk[ "envmap_pars_fragment" ]
		"#ifdef USE_ENVMAP",

			"varying vec3 vReflect;",
			"uniform float reflectivity;"
			"uniform samplerCube envMap;"
			"uniform float flipEnvMap;"
			"uniform int combine;"

			"#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP )",

				"uniform bool useRefract;",
				"uniform float refractionRatio;",
			"#endif",

		"#endif"		
		THREE.ShaderChunk[ "fog_pars_fragment" ]
		#THREE.ShaderChunk[ "lights_phong_pars_fragment" ]
		"varying vec3 vWorldPosition;"
		"varying vec3 vViewPosition;"
		"varying vec3 vNormal;"
		THREE.ShaderChunk[ "shadowmap_pars_fragment" ]
		#THREE.ShaderChunk[ "bumpmap_pars_fragment" ]
		# THREE.ShaderChunk[ "normalmap_pars_fragment" ]
		"#ifdef USE_NORMALMAP"

			"uniform sampler2D normalMap;"
			"uniform vec2 normalScale;"

			# Per-Pixel Tangent Space Normal Mapping
			# http://hacksoflife.blogspot.ch/2009/11/per-pixel-tangent-space-normal-mapping.html

			"vec3 perturbNormal2Arb( vec3 eye_pos, vec3 surf_norm ) {"

				"vec3 q0 = dFdx( eye_pos.xyz );"
				"vec3 q1 = dFdy( eye_pos.xyz );"
				"vec2 st0 = dFdx( vUv.st );"
				"vec2 st1 = dFdy( vUv.st );"

				"vec3 S = normalize(  q0 * st1.t - q1 * st0.t );"
				"vec3 T = normalize( -q0 * st1.s + q1 * st0.s );"
				"vec3 N = normalize( surf_norm );"

				"vec3 nmap = texture2D( normalMap, vUv ).xyz;"
				"nmap.y = 1.0 - nmap.y;"
				"vec3 mapN = nmap * 2.0 - 1.0;"
				"mapN.xy = normalScale * mapN.xy;"
				"mat3 tsn = mat3( S, T, N );"
				"return normalize( tsn * mapN );"

			"}"

		"#endif"		
		THREE.ShaderChunk[ "specularmap_pars_fragment" ]

		"void main() {",

			"gl_FragColor = vec4( vec3 ( 1.0 ), opacity );"

			# THREE.ShaderChunk[ "map_fragment" ]
			"#ifdef USE_MAP",

				"#ifdef GAMMA_INPUT",

					"vec4 texelColor = texture2D( map, vUv );",
					"texelColor.xyz *= texelColor.xyz;",

					"gl_FragColor = gl_FragColor * texelColor;",

				"#else",

					"gl_FragColor = gl_FragColor * texture2D( map, vUv );",
					"gl_FragColor.xyz *= 1.5;",

				"#endif",

			"#endif"			
			THREE.ShaderChunk[ "alphatest_fragment" ]
			THREE.ShaderChunk[ "specularmap_fragment" ]
			#THREE.ShaderChunk[ "lights_phong_fragment" ]
			"vec3 viewPosition = normalize( vViewPosition );"
			"vec3 normal = normalize( vNormal );",

			"#ifdef USE_ENVMAP"
				"vec3 reflectVec;"

				"#if defined( USE_BUMPMAP ) || defined( USE_NORMALMAP )",

					"normal = perturbNormal2Arb( -viewPosition, normal );"
					"vec3 cameraToVertex = normalize( vWorldPosition - cameraPosition );",

					"if ( useRefract ) {",
						"reflectVec = refract( cameraToVertex, normal, refractionRatio );",
					"} else { ",
						"reflectVec = reflect( cameraToVertex, normal );",
					"}",
				"#else",
					"reflectVec = vReflect;"
				"#endif",

				"#ifdef DOUBLE_SIDED"
					"float flipNormal = ( -1.0 + 2.0 * float( gl_FrontFacing ) );"
					"vec4 cubeColor = textureCube( envMap, flipNormal * vec3( flipEnvMap * reflectVec.x, reflectVec.yz ) );"
				"#else"
					"vec4 cubeColor = textureCube( envMap, vec3( flipEnvMap * reflectVec.x, reflectVec.yz ) );"
				"#endif"
				"#ifdef GAMMA_INPUT"
					"cubeColor.xyz *= cubeColor.xyz;"
				"#else"
					"cubeColor.xyz *= 2.0;"
				"#endif"


				# FRESNEL
				"vec4 texelAux = texture2D( tAux, vUv );"
				"float fresnelChan = clamp(texelAux.r, 0.0, 1.0);"
				# "float reflecPowerChan = clamp(texelAux.g, 0.0, 1.0);"

				# "vFresnel = mFresnelBias + mFresnelGain * pow( 1.0 + dot( vI , vNWorld ), mFresnelPower );"	
				# "vFresnel = fresnelChan * pow( 1.0 + dot( vI , vNWorld ), reflecPowerChan );"	
				# "vFresnel *= reflecPowerChan;"	

				"float fresnelFact = clamp( mFresnelPower + (5.0 * (1.0 - texelAux.r)), 0.0, 5.0);"
				"#ifdef DOUBLE_SIDED"
					"float vFresnel = pow( 1.0 + dot( vI , flipNormal * normal ), fresnelFact );"	
				"#else"
					"float vFresnel = pow( 1.0 + dot( vI , normal ), fresnelFact );"	
				"#endif"

				"vFresnel = clamp( vFresnel, 0.0, 1.0 );"


				# combine using fresnel term and specularStrength instaead of simple "specular"
				# also multiply specular color to final result
				"#ifdef USE_SPECULARMAP"
					"gl_FragColor.xyz = mix( gl_FragColor.xyz, cubeColor.xyz * texelSpecular.xyz ,  vFresnel * specularStrength   );"
				"#else"
					"gl_FragColor.xyz = mix( gl_FragColor.xyz, cubeColor.xyz,  vFresnel * specularStrength  );"
				"#endif"

			"#endif"
			
			# "gl_FragColor.x = vWindForce;"
			# "gl_FragColor.y = vWindForce;"
			# "gl_FragColor.z = vWindForce;"

			#THREE.ShaderChunk[ "shadowmap_fragment" ]

			# THREE.ShaderChunk[ "linear_to_gamma_fragment" ]
			"#ifdef GAMMA_OUTPUT",

				"float d = 1.0/1.8;"
				"gl_FragColor.rgb = pow( gl_FragColor.rgb , vec3(d,d,d) );"
				# "gl_FragColor *= 16;  // Hardcoded Exposure Adjustment"
				# "float3 x = max(0,gl_FragColor-0.004);"
				# "gl_FragColor = (x*(6.2*x+.5))/(x*(6.2*x+1.7)+0.06);"
			"#endif"			

			# THREE.ShaderChunk[ "color_fragment" ]
			THREE.ShaderChunk[ "fog_fragment" ]

		"}"

	].join("\n")