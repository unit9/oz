class IFLColorCorrectionShader

	uniforms: {

		"tDiffuse" : 	{ type: "t", value: null }
		"saturation" : 	{ type: "v4", value: new THREE.Vector4( 0, 0, 0 , 1 ) }
		"powRGB" :		{ type: "v3", value: new THREE.Vector3( 1, 1, 1 ) }
		"mulRGB" :		{ type: "v3", value: new THREE.Vector3( 1, 1, 1 ) }
		"vignetteOffset":   { type: "f", value: 1.2 }
		"vignetteDarkness": { type: "f", value: 1.3 }		
	}

	vertexShader: [

		"varying vec2 vUv;"

		"void main() {"

			"vUv = uv;"

			"gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );"

		"}"

	].join("\n")

	fragmentShader: [

		"uniform sampler2D tDiffuse;"
		"uniform vec3 powRGB;"
		"uniform vec3 mulRGB;"
		"uniform vec4 saturation;"

		"uniform float vignetteOffset;",
		"uniform float vignetteDarkness;",

		"varying vec2 vUv;"

		"void main() {"

			"gl_FragColor = texture2D( tDiffuse, vUv );"


			#pow / mul
			"gl_FragColor.xyz = mulRGB * pow( gl_FragColor.xyz, powRGB );"

			"gl_FragColor.r = clamp(gl_FragColor.r, 0.0, 1.0);"
			"gl_FragColor.g = clamp(gl_FragColor.g, 0.0, 1.0);"
			"gl_FragColor.b = clamp(gl_FragColor.b, 0.0, 1.0);"

			# saturation
			# 0.2126f,0.7152f,0.0722f

			"vec3 luminanceWeights = vec3(0.2126,0.7152,0.0722);"
			"float luminance = dot(gl_FragColor.xyz,luminanceWeights);"
			"vec3 greyscale = vec3(luminance,luminance,luminance);"
			"gl_FragColor.xyz = mix(gl_FragColor.xyz,greyscale.xyz,saturation.xyz);"

			"gl_FragColor.r = clamp(gl_FragColor.r, 0.0, 1.0);"
			"gl_FragColor.g = clamp(gl_FragColor.g, 0.0, 1.0);"
			"gl_FragColor.b = clamp(gl_FragColor.b, 0.0, 1.0);"

			#vignette
			"vec2 uv = ( vUv - vec2( 0.5 ) ) * vec2( vignetteOffset );"
			"gl_FragColor = vec4( mix( gl_FragColor.rgb, vec3( 1.0 - vignetteDarkness ), dot( uv, uv ) ), gl_FragColor.a );"		

		"}"

	].join("\n")