class MaterialManager

	textureLoader : null
	skyCubeTexture : null

	constructor: (textureLoader,skyCubeTexture) ->
		@textureLoader = textureLoader
		@skyCubeTexture = skyCubeTexture

	getSkyMaterial:->


	getCloudMaterial:->
		cloudSprite = @textureLoader.getTexture "cloud.png" #THREE.ImageUtils.loadTexture( "models/cloud.png" );
		return new THREE.ParticleBasicMaterial( { size: 150, map: cloudSprite, depthWrite: false, transparent : true, lights:false } );	

	getTerrainPhongMaterial:->
		shader = THREE.ShaderPhongColor[ "shader" ]
		uniforms = THREE.UniformsUtils.clone( shader.uniforms )
		uniforms[ "ambient" ].value = 		new THREE.Color(0x222222)
		uniforms[ "diffuse" ].value = 		new THREE.Color(0xFFFFFF)
		uniforms[ "specular" ].value = 		new THREE.Color(0x555555)
		#uniforms[ "shininess" ].value = 	0


		# diffuse maps
		difftex = @textureLoader.getTexture "test_diffuse.jpg" #THREE.ImageUtils.loadTexture "models/test_diffuse.jpg" 
		difftexR = @textureLoader.getTexture "test_diffuseR.jpg" #THREE.ImageUtils.loadTexture "models/test_diffuseR.jpg" 
		difftexG = @textureLoader.getTexture "test_diffuseG.jpg" #THREE.ImageUtils.loadTexture "models/test_diffuseG.jpg" 
		difftexB = @textureLoader.getTexture "test_diffuseB.jpg" #THREE.ImageUtils.loadTexture "models/test_diffuseB.jpg" 
		difftex.wrapS = difftex.wrapT = THREE.RepeatWrapping
		difftexR.wrapS = difftexR.wrapT = THREE.RepeatWrapping
		difftexG.wrapS = difftexG.wrapT = THREE.RepeatWrapping			
		difftexB.wrapS = difftexB.wrapT = THREE.RepeatWrapping
		
		uniforms[ "map" ].value = 					difftex
		uniforms[ "enableDiffuseR" ].value = 		true
		uniforms[ "enableDiffuseG" ].value = 		true
		uniforms[ "enableDiffuseB" ].value = 		true
		uniforms[ "tDiffuseR" ].value = 			difftexR
		uniforms[ "tDiffuseG" ].value = 			difftexG
		uniforms[ "tDiffuseB" ].value = 			difftexB

		lightex = @textureLoader.getTexture "test_ao.jpg"#THREE.ImageUtils.loadTexture "models/test_ao.jpg" 
		uniforms[ "lightMap" ].value = lightex


		spectex = @textureLoader.getTexture "test_specular.jpg" #THREE.ImageUtils.loadTexture "models/test_specular.jpg" 
		spectexR = @textureLoader.getTexture "test_specularR.jpg" #THREE.ImageUtils.loadTexture "models/test_specularR.jpg" 
		spectexG = @textureLoader.getTexture "test_specularG.jpg" #THREE.ImageUtils.loadTexture "models/test_specularG.jpg" 
		spectexB = @textureLoader.getTexture "test_specularB.jpg" #THREE.ImageUtils.loadTexture "models/test_specularB.jpg" 
		spectex.wrapS = spectex.wrapT = THREE.RepeatWrapping
		spectexR.wrapS = spectexR.wrapT = THREE.RepeatWrapping
		spectexG.wrapS = spectexG.wrapT = THREE.RepeatWrapping
		spectexB.wrapS = spectexB.wrapT = THREE.RepeatWrapping	

		uniforms[ "specularMap" ].value = 			spectex
		uniforms[ "enableSpecularR" ].value = 		true
		uniforms[ "enableSpecularG" ].value = 		true
		uniforms[ "enableSpecularB" ].value = 		true
		uniforms[ "tSpecularR" ].value = 			spectexR
		uniforms[ "tSpecularG" ].value = 			spectexG
		uniforms[ "tSpecularB" ].value = 			spectexB

		# uniforms[ "envMap" ].value = 				@skyCubeTexture

		uniforms[ "offsetRepeat" ].value = 			new THREE.Vector4( 0, 0, 100, 100 )



		parameters = 
			fragmentShader: shader.fragmentShader
			vertexShader: shader.vertexShader
			uniforms: uniforms
			lights: true
			vertexColors: THREE.VertexColors

		material = new THREE.ShaderMaterial( parameters );
		material.map = difftex
		material.specular = new THREE.Color(0xFFFFFF)
		material.shininess = 40
		material.lightMap = lightex
		material.specularMap = spectex
		# material.envMap = @skyCubeTexture
		# material.wrapAround = true;

		return material				


	getTerrainLambertMaterial:->
		shader = THREE.ShaderLambertColor[ "shader" ]
		uniforms = THREE.UniformsUtils.clone( shader.uniforms )
		uniforms[ "ambient" ].value = 		new THREE.Color(0x222222)
		uniforms[ "diffuse" ].value = 		new THREE.Color(0xFFFFFF)


		# lambert has only diffuse basically

		# diffuse maps
		difftex = @textureLoader.getTexture "test_diffuse.jpg" #THREE.ImageUtils.loadTexture "models/test_diffuse.jpg" 
		difftexR = @textureLoader.getTexture "test_diffuseR.jpg" #THREE.ImageUtils.loadTexture "models/test_diffuseR.jpg" 
		difftexG = @textureLoader.getTexture "test_diffuseG.jpg" #THREE.ImageUtils.loadTexture "models/test_diffuseG.jpg" 
		difftexB = @textureLoader.getTexture "test_diffuseB.jpg" #THREE.ImageUtils.loadTexture "models/test_diffuseB.jpg" 
		difftex.wrapS = difftex.wrapT = THREE.RepeatWrapping
		difftexR.wrapS = difftexR.wrapT = THREE.RepeatWrapping
		difftexG.wrapS = difftexG.wrapT = THREE.RepeatWrapping			
		difftexB.wrapS = difftexB.wrapT = THREE.RepeatWrapping
		
		uniforms[ "map" ].value = 					difftex
		uniforms[ "enableDiffuseR" ].value = 		true
		uniforms[ "enableDiffuseG" ].value = 		true
		uniforms[ "enableDiffuseB" ].value = 		true
		uniforms[ "tDiffuseR" ].value = 			difftexR
		uniforms[ "tDiffuseG" ].value = 			difftexG
		uniforms[ "tDiffuseB" ].value = 			difftexB

		uniforms[ "offsetRepeat" ].value = 			new THREE.Vector4( 0, 0, 100, 100 )

		lightex = @textureLoader.getTexture "test2_lightMap.jpg"#THREE.ImageUtils.loadTexture "models/test_ao.jpg" 
		uniforms[ "lightMap" ].value = lightex

		parameters = 
			fragmentShader: shader.fragmentShader
			vertexShader: shader.vertexShader
			uniforms: uniforms
			lights: true
			vertexColors: THREE.VertexColors

		material = new THREE.ShaderMaterial( parameters );
		material.map = difftex
		material.lightMap = lightex

		return material		


	getTerrainNormalMaterial:->
		shader = THREE.ShaderNormalColor[ "shader" ]
		uniforms = THREE.UniformsUtils.clone( shader.uniforms )


		# diffuse maps
		difftex = @textureLoader.getTexture "test_diffuse.jpg" #THREE.ImageUtils.loadTexture "models/test_diffuse.jpg" 
		difftexR = @textureLoader.getTexture "test_diffuseR.jpg" #THREE.ImageUtils.loadTexture "models/test_diffuseR.jpg" 
		difftexG = @textureLoader.getTexture "test_diffuseG.jpg" #THREE.ImageUtils.loadTexture "models/test_diffuseG.jpg" 
		difftexB = @textureLoader.getTexture "test_diffuseB.jpg" #THREE.ImageUtils.loadTexture "models/test_diffuseB.jpg" 
		difftex.wrapS = difftex.wrapT = THREE.RepeatWrapping
		difftexR.wrapS = difftexR.wrapT = THREE.RepeatWrapping
		difftexG.wrapS = difftexG.wrapT = THREE.RepeatWrapping			
		difftexB.wrapS = difftexB.wrapT = THREE.RepeatWrapping

		uniforms[ "enableDiffuse" ].value = 		true
		uniforms[ "enableDiffuseR" ].value = 		true
		uniforms[ "enableDiffuseG" ].value = 		true
		uniforms[ "enableDiffuseB" ].value = 		true

		uniforms[ "tDiffuse" ].value = 		difftex
		uniforms[ "tDiffuseR" ].value = 	difftexR
		uniforms[ "tDiffuseG" ].value = 	difftexG
		uniforms[ "tDiffuseB" ].value = 	difftexB

		# normal maps
		normaltex = @textureLoader.getTexture "test_normal.jpg" #THREE.ImageUtils.loadTexture "models/test_normal.jpg" 
		normaltexR = @textureLoader.getTexture "test_normalR.jpg" #THREE.ImageUtils.loadTexture "models/test_normalR.jpg" 
		normaltexG = @textureLoader.getTexture "test_normalG.jpg" #THREE.ImageUtils.loadTexture "models/test_normalG.jpg" 
		normaltexB = @textureLoader.getTexture "test_normalB.jpg" #THREE.ImageUtils.loadTexture "models/test_normalB.jpg" 
		normaltex.wrapS = normaltex.wrapT = THREE.RepeatWrapping
		normaltexR.wrapS = normaltexR.wrapT = THREE.RepeatWrapping
		normaltexG.wrapS = normaltexG.wrapT = THREE.RepeatWrapping
		normaltexB.wrapS = normaltexB.wrapT = THREE.RepeatWrapping

		uniforms[ "enableNormalR" ].value = 		true
		uniforms[ "enableNormalG" ].value = 		true
		uniforms[ "enableNormalB" ].value = 		true

		uniforms[ "tNormal" ].value = 		normaltex
		uniforms[ "tNormalR" ].value = 		normaltexR
		uniforms[ "tNormalG" ].value = 		normaltexG
		uniforms[ "tNormalB" ].value = 		normaltexB

		uniforms[ "uNormalScale" ].value = 	new THREE.Vector2( 5, 5 )

		# specular
		spectex = @textureLoader.getTexture "test_specular.jpg" #THREE.ImageUtils.loadTexture "models/test_specular.jpg" 
		spectexR = @textureLoader.getTexture "test_specularR.jpg" #THREE.ImageUtils.loadTexture "models/test_specularR.jpg" 
		spectexG = @textureLoader.getTexture "test_specularG.jpg" #THREE.ImageUtils.loadTexture "models/test_specularG.jpg" 
		spectexB = @textureLoader.getTexture "test_specularB.jpg" #THREE.ImageUtils.loadTexture "models/test_specularB.jpg" 
		spectex.wrapS = spectex.wrapT = THREE.RepeatWrapping
		spectexR.wrapS = spectexR.wrapT = THREE.RepeatWrapping
		spectexG.wrapS = spectexG.wrapT = THREE.RepeatWrapping
		spectexB.wrapS = spectexB.wrapT = THREE.RepeatWrapping				

		uniforms[ "enableSpecular" ].value = 		true
		uniforms[ "enableSpecularR" ].value = 		true
		uniforms[ "enableSpecularG" ].value = 		true
		uniforms[ "enableSpecularB" ].value = 		true

		uniforms[ "tSpecular" ].value = 	spectex
		uniforms[ "tSpecularR" ].value = 	spectexR
		uniforms[ "tSpecularG" ].value = 	spectexG
		uniforms[ "tSpecularB" ].value = 	spectexB


		# displacement
		# displtex = THREE.ImageUtils.loadTexture "models/test_displacement.jpg" 
		# displtex.wrapS = displtex.wrapT = THREE.RepeatWrapping
		# uniforms[ "enableDisplacement" ].value = 	true
		# uniforms[ "uDisplacementScale" ].value = 	.2
		# uniforms[ "tDisplacement" ].value = displtex

		# ao 
		aotex = @textureLoader.getTexture "test_ao.jpg" #THREE.ImageUtils.loadTexture "models/test_ao.jpg" 
		uniforms[ "enableAO" ].value = true
		uniforms[ "tAO" ].value = aotex


		uniforms[ "uDiffuseColor" ].value.setHex( 0xFFFFFF )
		uniforms[ "uAmbientColor" ].value.setHex( 0x222222 )
		uniforms[ "uRepeat" ].value = new THREE.Vector2( 100 , 100 )
		uniforms[ "uShininess" ].value = 0
		uniforms[ "wrapRGB" ].value.set( 0.5, 0.5, 0.5 )


		parameters = 
			fragmentShader: shader.fragmentShader
			vertexShader: shader.vertexShader
			uniforms: uniforms
			lights: true
			vertexColors:THREE.VertexColors

		material = new THREE.ShaderMaterial( parameters );
		material.wrapAround = true;
		#material.depthWrite = false;
		#material.depthTest = false;

		return material

	getLakeMaterial:->
		shader = THREE.ShaderNormalColor[ "shader" ]
		uniforms = THREE.UniformsUtils.clone( shader.uniforms )
		normaltex = @textureLoader.getTexture "water_norm.jpg"  #THREE.ImageUtils.loadTexture "models/water_norm.jpg" 
		normaltex.wrapS = normaltex.wrapT = THREE.RepeatWrapping
		normaltexR = @textureLoader.getTexture "foam_norm.jpg" #THREE.ImageUtils.loadTexture "models/foam_norm.jpg" 
		normaltexR.wrapS = normaltexR.wrapT = THREE.RepeatWrapping		
		uniforms[ "tNormal" ].value = normaltex
		uniforms[ "tNormalR" ].value = normaltexR
		uniforms[ "enableNormalR" ].value = true
		uniforms[ "uNormalScale" ].value = 	new THREE.Vector2( 3, 3 )
		uniforms[ "tCube" ].value = @skyCubeTexture
		uniforms[ "uDiffuseColor" ].value.setHex(0xFFFFFF)#( 0x1c5a9a )
		uniforms[ "uAmbientColor" ].value.setHex( 0x000000 )
		uniforms[ "uRepeat" ].value = new THREE.Vector2( 40 , 40 )

		difftex = @textureLoader.getTexture "water.jpg" #THREE.ImageUtils.loadTexture "models/water.jpg" 
		difftexR = @textureLoader.getTexture "foam.jpg" #THREE.ImageUtils.loadTexture "models/foam.jpg" 
		difftex.wrapS = difftex.wrapT = THREE.RepeatWrapping
		difftexR.wrapS = difftexR.wrapT = THREE.RepeatWrapping
		uniforms[ "enableDiffuse" ].value = 		true
		uniforms[ "tDiffuse" ].value = 				difftex
		uniforms[ "enableDiffuseR" ].value = 		true
		uniforms[ "tDiffuseR" ].value = 			difftexR


		uniforms[ "uOpacity" ].value = .8;
		uniforms[ "enableReflection" ].value = true;
		uniforms[ "uReflectivity" ].value = .8
		#uniforms[ "useRefract" ].value = true
		#uniforms[ "uShininess" ].value = 0


		parameters = 
			fragmentShader: shader.fragmentShader
			vertexShader: shader.vertexShader
			uniforms: uniforms
			lights: true
			transparent: true
			vertexColors:THREE.VertexColors

		material = new THREE.ShaderMaterial( parameters );
		material.wrapAround = true;
		material.opacity = .7;
		return material