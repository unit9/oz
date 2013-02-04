class IFLLoader

	IFLVertexAttribute :
		POSITION 		: 0
		UV 				: 1
		NORMALS 		: 2
		TANGENTS 		: 3
		BINORMALS 		: 4	
		TEX_TANGENTS 	: 5
		TEX_BINORMALS 	: 6
		COLOR 			: 7	
		JOINT_0 		: 8	
		JOINT_1 		: 9
		JOINT_2 		: 10
		JOINT_3 		: 11
		JOINT_4 		: 12
		JOINT_INDICES 	: 13
		JOINT_WEIGHTS 	: 14
		SECONDARY_UV 	: 15

	library 			: null
	callback 			: null
	callbackProgress	: null
	worker 				: null
	convertTextureIndex : 0
	#fileSize 			: 0
	texCache			: null
	matCache			: null
	t 					: 0
	url					: null
	loadingPhase		: 0
	totalLoadingPhases	: 4
	sky					: null

	constructor: ->
		@worker = new Worker 'js/workers/iflworker.js'
		@worker.onmessage = @onWorkerMessage
		@texCache = {}
		@matCache = {}

	onWorkerMessage:(event) =>
		switch event.data.type
			when "console" then console[event.data.action]( event.data.msg );
			when "progress"
				loaded = event.data.data.progress
				total = event.data.data.total
				subtype = event.data.subtype
				@handleProgress loaded, total

			else @[event.data.callback]( event.data.data )

	handleProgress:(loaded,total)->
		if @callbackProgress?
			unit = 100/@totalLoadingPhases
			currentUnitBase = unit*@loadingPhase
			currentUnitProgress = (loaded*unit)/total
			totalLoaded = currentUnitBase + currentUnitProgress
			@callbackProgress(totalLoaded,100)
			#console.log "TotalLoaded:#{totalLoaded}, Phase: #{@loadingPhase}, loaded:#{loaded}, total:#{total}"

	load: (url,callback,callbackProgress) ->
		@loadingPhase = 0
		@url = url
		@callback = callback
		@callbackProgress = callbackProgress

		#@fileSize = 0;

		@xhr = new XMLHttpRequest();
		@xhr.onreadystatechange = @onXHRReadyStatusChange
		@xhr.onprogress = @onXHRProgress
		@xhr.open( "GET", url, true )
		@xhr.responseType = "arraybuffer"
		@xhr.send( null )

	onXHRProgress:(event)=>
		@handleProgress event.loaded, event.total

	onXHRReadyStatusChange:()=>
		if @xhr.readyState == @xhr.DONE 
			if @xhr.status == 200 || @xhr.status == 0 
				response = @xhr.response ? @xhr.mozResponseArrayBuffer
				@decompressLibrary( response )
			else 
				console.error  "[ IFLLoader ]: Couldn't load [ #{url} ] [ #{@xhr.status} ]" 
		# else if @xhr.readyState == @xhr.LOADING 
		# 	if @fileSize == 0 then @fileSize = @xhr.getResponseHeader( "Content-Length" );
			
		# 	if @xhr.response
		# 		@handleProgress @xhr.response.byteLength, @fileSize
			
		# else if @xhr.readyState == @xhr.HEADERS_RECEIVED 
		# 	@fileSize = @xhr.getResponseHeader( "Content-Length" )
		return

	decompressLibrary:(data) ->
		@t = new Date().getTime()
		@loadingPhase++
		@worker.postMessage( {type:"inflate",data: data,callback:"parseLibrary"} )

	parseLibrary:(data) ->
		if data.length == 0 then throw "Error Decompressing Library, lenght is 0"
		console.log("[#{@url}] decompression time: "+ (new Date().getTime() - @t)/1000  ) 
		@loadingPhase++
		@t = new Date().getTime();
		@worker.postMessage {type:"convert_library",data:data,callback:"onLibraryParsed"}


	onLibraryParsed:(data) ->
		@library = data;
		#inject functions
		for func of @IFLLibraryFuncs
			@library[func] = @IFLLibraryFuncs[func]


		#build ref table
		@library._contentByID = {}
		for content in @library._content
			 @library._contentByID[content._reference.id] = content;

		console.log("[#{@url}] library parse time: "+ (new Date().getTime() - @t)/1000  ) 

		@t = new Date().getTime();
		@loadingPhase++
		@convertTextures()

	convertTextures: () ->
		for i in [@convertTextureIndex...@library._content.length] by 1
			if(@library._content[i].iflType == "IFLBitmap")
				
				bmp = @library._content[i]
				@convertTextureIndex = i+1;
				if(bmp._hasOriginalByteArray)
					@worker.postMessage({type:"parse_jpg",image:bmp._savedBytes,w:bmp._width,h:bmp._height,callback:"onTextureConverted"})
				else
					@worker.postMessage({type:"convert_argb",image:bmp._savedBytes,w:bmp._width,h:bmp._height,callback:"onTextureConverted"})
				return;
			@handleProgress(i,@library._content.length)
		@createModel();
			
	onTextureConverted: (data) ->
		@library._content[@convertTextureIndex-1].converted = data;
		@convertTextures();

	createModel:() ->
		console.log("[#{@url}] convert textures time: "+ (new Date().getTime() - @t)/1000  ) 

		@t = new Date().getTime();
		root = new THREE.Object3D();
		rootObjects = @library.getRootNodes();

		for rootObject in rootObjects
			root.add( @convertNode(rootObject) )
		
		console.log("[#{@url}] convert node time: "+ (new Date().getTime() - @t)/1000  ) 

		@callback( root )
		@worker.postMessage {type:"kill"}
		return

	convertNode: (iflnode) ->

		switch iflnode.iflType
			when "IFLMesh" then retEntity = @convertMesh(iflnode)
			#when "IFLMeshContainer" then console.warn "TODO: Implement MeshContainer Conversion" #retEntity = convertMeshContainer(iflnode as IFLMeshContainer,options);	
			#when "IFLCamera" then console.warn "TODO: Implement Camera Conversion" #retEntity = convertCamera(iflnode as IFLCamera);
			#when "IFLLight" then console.warn "TODO: Implement Light Conversion" #retEntity = convertLight(iflnode as IFLLight);
			else retEntity = new THREE.Object3D()


		retEntity.name = iflnode._reference.id;


		retEntity.matrix = @convertMatrix4(iflnode._transformMatrix)
		retEntity.scale.getScaleFromMatrix(retEntity.matrix);
		
		mat = new THREE.Matrix4().extractRotation( retEntity.matrix );
		retEntity.rotation.setEulerFromRotationMatrix( retEntity.matrix, retEntity.eulerOrder );
		retEntity.position.getPositionFromMatrix( retEntity.matrix );


		for childID in iflnode.childIDs
			child = @library.getContent( childID.id );
			if child then retEntity.add( @convertNode(child) )

		return retEntity;

	convertMatrix4: (m) ->
		new THREE.Matrix4(	m[0],	m[4],	m[8],	m[12],
							m[1],	m[5],	m[9],	m[13],
							m[2],	m[6],	m[10],	m[14],
							m[3],	m[7],	m[11],	m[15]
							);


	convertMesh: (iflmesh) ->

		# positions
		positions = iflmesh.verticesDecomposed._data[@IFLVertexAttribute.POSITION];
		# UV
		uvs = iflmesh.verticesDecomposed._data[@IFLVertexAttribute.UV]
		# NORMALS
		normals = iflmesh.verticesDecomposed._data[@IFLVertexAttribute.NORMALS]
		# TANGENTS
		tangents = iflmesh.verticesDecomposed._data[@IFLVertexAttribute.TEX_TANGENTS]
		# COLORS
		colors = iflmesh.verticesDecomposed._data[@IFLVertexAttribute.COLOR]
		color_length = 0
		if colors? then color_length = iflmesh.verticesDecomposed._vertexAttributeLengths[@IFLVertexAttribute.COLOR]
		# SKIN
		skinWeights = iflmesh.verticesDecomposed._data[@IFLVertexAttribute.JOINT_WEIGHTS]
		skinIndices = iflmesh.verticesDecomposed._data[@IFLVertexAttribute.JOINT_INDICES]
		isSkinnedMesh = skinWeights and skinIndices;

		# when conditions are good, use buffergeometry
		if positions.length < 65535 and !isSkinnedMesh and iflmesh.subMeshes.length == 1
			geometry = @convertBufferGeometry iflmesh, positions, uvs, normals, tangents, colors, color_length, isSkinnedMesh, skinWeights, skinIndices
		else
			geometry = @convertGeometry iflmesh, positions, uvs, normals, tangents, colors, color_length, isSkinnedMesh, skinWeights, skinIndices

		geometry.hasTangents = tangents?

		material = if iflmesh.subMeshes.length == 1 then geometry.materials[0] else new THREE.MeshFaceMaterial
		material.skinning = isSkinnedMesh;

		if isSkinnedMesh
			ret = new THREE.SkinnedMesh geometry, material
		else
			ret = new THREE.Mesh geometry, material

		if isSkinnedMesh
			#bindpose = @convertMatrix4(iflmesh.bindPoseMatrix)
			# rewrite inverse bind matrices
			for bone,index in ret.geometry.bones
				#inv = ret.geometry.bones[i].invBindMatrix
				#fin = bindpose.multiply(bindpose,inv)
				ret.boneInverses[index] = bone.invBindMatrix
		
		ret.castShadow = ret.receiveShadow = true;
		return ret

	convertBufferGeometry:(iflmesh, positions, uvs, normals, tangents, colors, color_length, isSkinnedMesh, skinWeights, skinIndices)->
		
		geometry = new THREE.BufferGeometry

		indexBuffer = iflmesh.subMeshes[0].indexBuffer._rawData


		geometry.attributes = {}
			
		geometry.attributes.index = 
			itemSize: 1
			array: new Int16Array( indexBuffer.length )
			numItems: indexBuffer.length
		
		geometry.attributes.index.array.set( indexBuffer )


		geometry.attributes.position =
			itemSize: 3
			array: positions
			numItems: positions.length
		
		#geometry.attributes.position.array.set( positions )

		if uvs
			geometry.attributes.uv =
				itemSize: 2
				array: uvs
				numItems: uvs.length

			#geometry.attributes.uv.array.set( uvs )

			# we need to loop UVs to invert V if texture flipY = true
			# for i in [0...geometry.attributes.uv.array.length] by 2
			# 	geometry.attributes.uv.array[i+1] = 1 - geometry.attributes.uv.array[i+1]


		if normals
			geometry.attributes.normal =
				itemSize: 3
				array: normals
				numItems: normals.length

			#geometry.attributes.normal.array.set( normals )
		
		# apparently colors can't go in buffergeometry :(
		if colors
			geometry.attributes.color =
				itemSize: color_length
				array: colors
				numItems: colors.length

			#geometry.attributes.color.array.set( colors )


		if tangents
			geometry.attributes.tangent =
				itemSize: 3
				array: tangents
				numItems: tangents.length

			#geometry.attributes.tangent.array.set( tangents )

		geometry.offsets = [
			{ start: 0, count: indexBuffer.length, index: 0 }
		]


		geometry.materials = [ @convertMaterial( iflmesh.subMeshes[0],iflmesh._reference.id ) ]
		return geometry
		

	convertGeometry:(iflmesh, positions, uvs, normals, tangents, colors, color_length, isSkinnedMesh, skinWeights, skinIndices)->
		
		reasons = ""
		if positions.length >= 65535 
			reasons += "[Vertices > 65535]"
		if isSkinnedMesh
			reasons += "[Is Skinned Mesh]"
		if iflmesh.subMeshes.length > 1
			reasons += "[Has Submeshes]"
		if colors?
			reasons += "[Has Vertex Colors]"

		console.info "Mesh #{iflmesh._reference.id} converted as standard THREE.Geometry because #{reasons}"

		geometry = new THREE.Geometry

		cachedUVs = []
		cachedNormals = []
		cachedTangents = []
		cachedColors = []

		cachedPositions = {}
		positionRearrangment = {}

		if positions
			for i in [0...positions.length] by 3
				p1 = positions[i]
				p2 = positions[i+1]
				p3 = positions[i+2]

				if !cachedPositions[p1+"_"+p2+"_"+p3]
					cachedPositions[p1+"_"+p2+"_"+p3] = {index: geometry.vertices.length,vertex:new THREE.Vector3( p1,p2,p3 ) }
					geometry.vertices.push( cachedPositions[p1+"_"+p2+"_"+p3].vertex )

				positionRearrangment[i/3] = cachedPositions[p1+"_"+p2+"_"+p3].index

				# geometry.vertices.push( new THREE.Vector3( positions[i],positions[i+1],positions[i+2] ) );
		else
			return new THREE.Object3D(); # no positions no party



		if isSkinnedMesh
			stepSize = iflmesh.verticesDecomposed._vertexAttributeLengths[@IFLVertexAttribute.JOINT_INDICES];
			if(stepSize <= 2)			
				for i in [0...skinIndices.length] by stepSize
					second = Math.floor(i+stepSize/2)
					geometry.skinWeights.push( new THREE.Vector4(skinWeights[i],skinWeights[second],0,0) )
					geometry.skinIndices.push( new THREE.Vector4(skinIndices[i],skinIndices[second],0,0) )
			geometry.bones = @convertBones(iflmesh);
			geometry.animation = @convertAnimations(geometry.bones,iflmesh);
		

		fakeUV = new THREE.UV( 0, 0 )
		# SUBMESHES
		for subMesh,subMeshIndex in iflmesh.subMeshes
			# material
			material = @convertMaterial(subMesh,iflmesh._reference.id)
			material.skinning = isSkinnedMesh
			geometry.materials.push(material)
			# faces
			ib = subMesh.indexBuffer._rawData
			
			for i1,ibi in ib by 3
				# i1 = ib[k]
				i2 = ib[ibi+1]
				i3 = ib[ibi+2]

				i12 = i1*2
				i22 = i2*2
				i32 = i3*2

				i13 = i1*3
				i23 = i2*3
				i33 = i3*3

				i14 = i1*4
				i24 = i2*4
				i34 = i3*4						

				# console.log i1+" rearr:"+ positionRearrangment[i1]

				face = new THREE.Face3 positionRearrangment[i1], positionRearrangment[i2], positionRearrangment[i3], null, null, subMeshIndex
				# face = new THREE.Face3 i1, i2, i3, null, null, subMeshIndex

				faceIndex =  geometry.faces.length;
				fvUVs = geometry.faceVertexUvs[0][faceIndex] = [];

				if uvs?
					fvUVs.push if cachedUVs[i12] then cachedUVs[i12] else cachedUVs[i12] = new THREE.UV uvs[i12], uvs[i12+1]
					fvUVs.push if cachedUVs[i22] then cachedUVs[i22] else cachedUVs[i22] = new THREE.UV uvs[i22], uvs[i22+1]
					fvUVs.push if cachedUVs[i32] then cachedUVs[i32] else cachedUVs[i32] = new THREE.UV uvs[i32], uvs[i32+1]
				#else
					#no UVs (?) put fake one (?)
				#	fvUVs.push( fakeUV )
				#	fvUVs.push( fakeUV )
				#	fvUVs.push( fakeUV )
				
				if normals?
					face.vertexNormals.push if cachedNormals[i13] then cachedNormals[i13] else cachedNormals[i13] = new THREE.Vector3 normals[i13], normals[i13+1],normals[i13+2]
					face.vertexNormals.push if cachedNormals[i23] then cachedNormals[i23] else cachedNormals[i23] = new THREE.Vector3 normals[i23], normals[i23+1],normals[i23+2]
					face.vertexNormals.push if cachedNormals[i33] then cachedNormals[i33] else cachedNormals[i33] = new THREE.Vector3 normals[i33], normals[i33+1],normals[i33+2]

				if tangents?
					face.vertexTangents.push if cachedTangents[i13] then cachedTangents[i13] else cachedTangents[i13] = new THREE.Vector4 tangents[i13], tangents[i13+1],tangents[i13+2], 1
					face.vertexTangents.push if cachedTangents[i23] then cachedTangents[i23] else cachedTangents[i23] = new THREE.Vector4 tangents[i23], tangents[i23+1],tangents[i23+2], 1
					face.vertexTangents.push if cachedTangents[i33] then cachedTangents[i33] else cachedTangents[i33] = new THREE.Vector4 tangents[i33], tangents[i33+1],tangents[i33+2], 1								
				
				if colors?
					if color_length == 3
						face.vertexColors.push if cachedColors[i13] then cachedColors[i13] else cachedColors[i13] = new THREE.Color().setRGB colors[i13], colors[i13+1],colors[i13+2]
						face.vertexColors.push if cachedColors[i23] then cachedColors[i23] else cachedColors[i23] = new THREE.Color().setRGB colors[i23], colors[i23+1],colors[i23+2]
						face.vertexColors.push if cachedColors[i33] then cachedColors[i33] else cachedColors[i33] = new THREE.Color().setRGB colors[i33], colors[i33+1],colors[i33+2]
					
					if color_length == 4
						face.vertexColors.push if cachedColors[i14] then cachedColors[i14] else cachedColors[i14] = new THREE.Color().setRGB colors[i14], colors[i14+1],colors[i14+2]
						face.vertexColors.push if cachedColors[i24] then cachedColors[i24] else cachedColors[i24] = new THREE.Color().setRGB colors[i24], colors[i24+1],colors[i24+2]
						face.vertexColors.push if cachedColors[i34] then cachedColors[i34] else cachedColors[i34] = new THREE.Color().setRGB colors[i34], colors[i34+1],colors[i34+2]								
				
				geometry.faces.push face

		# FINALIZE
		if isSkinnedMesh
			geometry.computeCentroids()
			geometry.computeFaceNormals()

			try
				geometry.computeTangents()
			catch e
				console.warn "error computing tangents"	

		return geometry	


	convertBones: (iflmesh) ->
		
		joints = []
		
		jointToBinding = [];
		bindingToJoint = [];

		bindings = iflmesh.jointBindings;

		# take all bindings
		for i in [0...bindings.length] by 1

			jo = @library.getContent(bindings[i].jointID.id)
			if not jo? then return null;

			jointToBinding[jo._reference.id] = i
			bindingToJoint[i] = jo._reference.id

			joints.push( jo )
		
		
		# select root
		for joint in joints
			if( !@library.findJointParent(joint) )
				root = joint
				break
			
		
		
		
		bindpose = @convertMatrix4(iflmesh.bindPoseMatrix);

		sk = [];
		sk.name = root.id;
		
		jointToIndex = [];
		skeletonJoint;
		
		for i in [0...bindings.length] by 1

			skeletonJoint = {}
			skeletonJoint.name = joints[i]._reference.id;

			jointMatrix = @convertMatrix4(joints[i]._transformMatrix);
			invBindMatrix = @convertMatrix4(bindings[i].inverseBindMatrix);
			
			#setScale1(jointMatrix);
			
			decomp = jointMatrix.decompose();
			skeletonJoint.pos = [decomp[0].x,decomp[0].y,decomp[0].z];
			skeletonJoint.rotq = [decomp[1].x,decomp[1].y,decomp[1].z,decomp[1].w];

			jointToIndex[ skeletonJoint.name ] = sk.length;
			skeletonJoint.invBindMatrix = invBindMatrix;
			skeletonJoint.jointMatrix = jointMatrix;

			sk.push(skeletonJoint)
		
		
		# build parentIndex structure
		for i in [0...bindings.length] by 1
		
			#parent = findJointParent(joints[i],root);
			#sk[i].parent = parent ? jointToIndex[parent._reference.id] : -1;
			skeletonJoint =  sk[i];
			parent = @library.findJointParent(joints[i]);
			
			if (not parent?)
				skeletonJoint.parent = -1;
			else
			
				if(parent.iflType == "IFLJoint")
					if(jointToIndex[parent._reference.id] != undefined)
						skeletonJoint.parent = jointToIndex[parent._reference.id]
					else
						# we have a parent joint, but not in the same jointbindings group
						skeletonJoint.parent = -1;
				else
					skeletonJoint.parent = -1;



		for i in [0...bindings.length] by 1
		
			skeletonJoint =  sk[i];

			bind = skeletonJoint.invBindMatrix.clone();
			scale = @setScale1(bind);
			bind.getInverse(bind);

			if i != 0
				p = sk[skeletonJoint.parent]
				bind.multiply(p.invBindMatrix,bind)

				iflparent = @library.findParent( @library.getContent(skeletonJoint.name) )
				if iflparent.iflType != "IFLJoint"
					@prependNonJointParents(bind,iflparent) # parent is not Joint, prepend its (hierarchical) transform

			else
				bind.multiply(bindpose,bind) # multiply bind pose to root joint
			


			decomp = bind.decompose();
			

			pos = [decomp[0].x,decomp[0].y,decomp[0].z]
			rotq = [decomp[1].x,decomp[1].y,decomp[1].z,decomp[1].w]

			skeletonJoint.pos = pos;
			skeletonJoint.rotq = rotq;
		

		return sk;
	
	prependNonJointParents: (bind,iflparent) ->
		parentmat = @convertMatrix4(iflparent._transformMatrix)
		prepended = new THREE.Matrix4().multiply(parentmat,bind)
		bind.copy(prepended)
		otherparent = @library.findParent(iflparent)
		if(otherparent.iflType != "IFLJoint")
			@prependNonJointParents(bind,otherparent)

	setScale1: (m) ->
	
		x = new THREE.Vector3( m.elements[0], m.elements[1], m.elements[2] ).length();
		y = new THREE.Vector3( m.elements[4], m.elements[5], m.elements[6] ).length();
		z = new THREE.Vector3( m.elements[8], m.elements[9], m.elements[10] ).length();

		m.elements[0]  /= x;
		m.elements[1]  /= x;
		m.elements[2]  /= x;

		m.elements[4]  /= y;
		m.elements[5]  /= y;
		m.elements[6]  /= y;

		m.elements[8] /= z;
		m.elements[9] /= z;
		m.elements[10] /= z;

		m.elements[12] /= x;
		m.elements[13] /= y;
		m.elements[14] /= z;
		m.elements[15] = 1;

		new THREE.Vector3(x,y,z);
	
	findJointParent: (joint,root) ->
	
		# function probably useless
		if not root? then return null;

		for childID in root.childIDs				
			if(childID.id == joint._reference.id)
				return root;
			else
				p = findJointParent(joint, @library.getContent(childID.id) )
				if p then return p
		return null;
		
	
	convertAnimations: (skeleton,iflMesh) ->
	
		anims = @library.getAnimationsForSkinJoints(iflMesh);
		r = [];
		
		bindpose = @convertMatrix4(iflMesh.bindPoseMatrix);

		#create fake animation if nothing is animated
		if anims.length == 0
			anims[0] = {
				_reference:{
					id:"fake"
				}
				tracks: []
			}

		for i in [0...1] by 1
			anim3js = {};
			anim3js.name = iflMesh._reference.id+"_"+anims[i]._reference.id;
			anim3js.fps = 30;
			anim3js.hierarchy = [];

			totalMaxTime = 0;
			
			for k in [0...skeleton.length] by 1

				track = @getTrackForJoint( skeleton[k], anims[i] );

				stillMatDec = skeleton[k].jointMatrix.decompose();

				maxTime = 0;
				#stillPos = [stillMatDec[0].x,stillMatDec[0].y,stillMatDec[0].z];
				stillPos = skeleton[k].pos;
				#stillRot = [stillMatDec[1].x,stillMatDec[1].y,stillMatDec[1].z,stillMatDec[1].w];
				stillRot = skeleton[k].rotq;

				if track?
				
					track3js = {};
					track3js.parent = skeleton[k].parent;
					track3js.name = "track_"+skeleton[k].name;
					track3js.keys = [];

					sampler = track.sampler;
					trackLength = track.end - track.start;
					numTimes = sampler.times.length
					timePerFrame = (trackLength/numTimes)*1000;
					
					for j in [0...sampler.times.length] by 1
					
						key3js = {};
						key3js.time = sampler.times[j];

						maxTime = Math.max(key3js.time,maxTime);
						totalMaxTime = Math.max(maxTime,totalMaxTime);

						#mat = @convertMatrix4( sampler.matrices[j] );
						#parent = skeleton[skeleton[k].parent];
						#if(parent)
							#mat.multiply(mat,parent.scale)
							#mat.scale(new THREE.Vector3(parent.scale.x,parent.scale.y,parent.scale.z))
						#@setScale1(mat);
						#decomp = mat.decompose();

						#key3js.pos = [decomp[0].x,decomp[0].y,decomp[0].z]
						key3js.pos = [sampler.positions[j].x,sampler.positions[j].y,sampler.positions[j].z];
						#key3js.rot = [decomp[1].x,decomp[1].y,decomp[1].z,decomp[1].w]
						key3js.rot = [sampler.orientations[j].x,sampler.orientations[j].y,sampler.orientations[j].z,sampler.orientations[j].w];
						key3js.scl = [1,1,1];


						track3js.keys.push(key3js);
									
				
				else
				
					# no track for this joint, we need to add a fake one?
					console.log("no track for joint #{skeleton[k].name} creating a fake one")

					anim = anims[i];
					# we replicate the first sampler we find on this animation
					sampler = if anim.tracks.length > 0 then anim.tracks[0].sampler else {times:[0,1]}
					track3js = {};
					track3js.name = "fake_track_"+skeleton[k].name;
					track3js.parent = skeleton[k].parent;
					track3js.keys = [];

					for j in [0...sampler.times.length] by 1
					
						key3js = {};
						key3js.time = sampler.times[j];

						maxTime = Math.max(key3js.time,maxTime);
						totalMaxTime = Math.max(maxTime,totalMaxTime);

						key3js.pos = [stillPos[0],stillPos[1],stillPos[2]];
						key3js.rot = [stillRot[0],stillRot[1],stillRot[2],stillRot[3]];

						key3js.scl = [1,1,1];
						track3js.keys.push(key3js);
					
				

				anim3js.length = maxTime;
				anim3js.hierarchy.push(track3js);
			

			#keyLenght = 0;

			# keys check for threejs
			for k in [0...anim3js.hierarchy.length] by 1
			
				keys = anim3js.hierarchy[k].keys;
				lastkey = keys[keys.length-1];
				firstKey = keys[0];



				# add last key if missing
				if (lastkey.time < totalMaxTime)
					keys.push({time:totalMaxTime,pos:lastkey.pos,rot:lastkey.rot,scl:lastkey.scl});
				
				# add first key if missing
				if(firstKey.time > 0)
					keys.unshift({time:0,pos:firstKey.pos,rot:firstKey.rot,scl:firstKey.scl});

				#if(keyLenght == 0)
				#	keyLenght = keys.length;
				#else if(keys.length != keyLenght)
				#	console.warn("animation "+anim3js.hierarchy[k].name+" has "+keys.length+" while others have "+keyLenght)

				#anim3js.hierarchy[k].length = totalMaxTime;
			

			anim3js.length = totalMaxTime;

			r.push(anim3js);
		
		
		
		return r[0];
	
	getTrackForJoint: (joint,anim) ->
		for i in [0...anim.tracks.length] by 1
			if( anim.tracks[i].target.id == joint.name)
				return anim.tracks[i];
		return null;
	
	convertMaterial: (subMesh,meshname) ->

		matid = subMesh.material._reference.id

		if !@matCache[matid]

		# if meshname.indexOf("terrain") != -1
		#  	@matCache[matid] = @convertTerrainMaterial(subMesh);
		# else if  meshname.indexOf("mountains") != -1
		# 	@matCache[matid] = @convertMountainsMaterial(subMesh)
		# else
		# @matCache[matid] = @convertFresnelMaterial(subMesh);

		# else
		 	@matCache[matid] = @convertGenericMaterial(subMesh);


		return @matCache[matid]

	getMaterialParams:(subMesh)->
		params = 
			#colors
			color: 0xFFFFFF#subMesh.material.diffuse.uintValue 
			ambient: 0xFFFFFF#subMesh.material.ambient.uintValue
			specular: 0xFFFFFF#subMesh.material.specular.uintValue
			#maps
			map: @getSubmeshTexture(subMesh.diffuseTextures)
			# map: @getTexture("roundtent_diff.png")
			# map: THREE.ImageUtils.loadTexture "models/sphere_test_diff.jpg"#@getSubmeshTexture(subMesh.normalTextures)
			# normalMap: THREE.ImageUtils.loadTexture "models/sphere_test_nrml.png"#@getSubmeshTexture(subMesh.normalTextures)
			# normalMap: @getTexture("roundtent_nrml.jpg")
			# envMap: @sky
			# specularMap: THREE.ImageUtils.loadTexture "models/sphere_test_specular.jpg"#@getSubmeshTexture(subMesh.specularTextures)
			# specularMap:  @getTexture("roundtent_spec.jpg")
			lightMap: null
			bumpMap: null
			#properties
			reflectivity: 0#subMesh.material.reflectivity
			shininess: 30#subMesh.material.shininess
			opacity: 1#if subMesh.material.transparency != 0 and subMesh.material.transparency != 1 then 1-subMesh.material.transparency else 1
			wireframe: false
			side: THREE.DoubleSide
			depthWrite: true
			transparent: false
			lights: false
			combine:false

		return params


	convertGenericMaterial:(subMesh)->
		params = @getMaterialParams(subMesh)
		mat = new THREE.MeshLambertMaterial params
		mat.transparent = params.map?.transparent
		return mat


	getSubmeshTexture: (from) ->
		if from.length > 0 then return @getTexture( from[0].id, false )
		return null


	getTexture: (id) ->
		tex = @library.getContent( id )
		if tex?.converted?
			# if !@texCache[tex._reference.id]? 
			@texCache[tex._reference.id] = ret = new THREE.DataTexture( tex.converted , tex._width, tex._height, if tex._hasOriginalByteArray then THREE.RGBFormat else THREE.RGBAFormat)
			# else
				# ret = @texCache[tex._reference.id]
		if ret 
			ret.needsUpdate = true
			ret.flipY = false
			ret.transparent = tex.transparent
		return ret;				

	getCubeTexture:(array)->
		images = [];

		texture = new THREE.Texture();
		texture.image = images;
		#if ( mapping !== undefined ) texture.mapping = mapping;

		# no flipping needed for cube textures
		texture.flipY = false;

		for path,index in array
			tex = @getTexture(path)
			image = tex.image
			image.format = tex.format
			images[index] = image

		texture.needsUpdate = true
		return texture;				





	#######################################
	#
	#
	#
	#
	# Library functions
	#
	#
	#
	#
	#######################################






	IFLLibraryFuncs:
		getContent: (id) ->
			@_contentByID[ id ];
		
		getRootNodes: ->
			@getRootNodesIn(@_content);

		isIFLNode: (object) ->
			# manual way to detect base class IFLNode
			object.iflType == "IFLNode" || object.iflType == "IFLJoint" || object.iflType == "IFLMesh" || object.iflType == "IFLMeshContainer" || object.iflType == "IFLLight" || object.iflType == "IFLCamera";

		getDiffuseTexture: (subMesh) ->
			@getContent( subMesh._diffuseTextures[0].id );

		getRootNodesIn : (lib)->
		
			meshesChildrenOfSomeone = [];
			meshesNotChildrenOfSomeone = [];
			
							
			for tm in lib when @isIFLNode(tm)
			
				if(meshesChildrenOfSomeone.indexOf(tm._reference.id) == -1)
					# mesh not children of someone
					meshesNotChildrenOfSomeone.push(tm._reference.id);
				
				for m in tm.childIDs
					# children was marked as not children, remove it
					if(meshesNotChildrenOfSomeone.indexOf(m.id) != -1)
						meshesNotChildrenOfSomeone.splice( meshesNotChildrenOfSomeone.indexOf(m.id),1);
					
					meshesChildrenOfSomeone.push(m.id);
			
			return ( for k in [0...meshesNotChildrenOfSomeone.length] by 1 then @getContent( meshesNotChildrenOfSomeone[k] ) )


		isRoot: (contentID) ->
			@isRootWithin(contentID,@_content)

		isRootWithin : (contentID,context) ->
			
			for content in context when @isIFLNode(content)
				for childID in content.childIDs
					if( childID.id == contentID )
						return false;
			
			return true;


		findParent: (node,parent) ->
			
			if( not parent? )
			
				rootNodes = @getRootNodes();
				for rootNode in rootNodes
					p = @findParent(node,rootNode);
					return p if p?
				
			else
				
				for childID in parent.childIDs
					if(childID.id == node._reference.id)
						return parent;
					else
						ch = @getContent(childID.id);
						if(ch)
							p = @findParent(node,ch);
							return p if p?
			return null;


		getAnimationsForSkinJoints : (skin) ->
		
			r = []
			
			doneAnims = [];
			
			for jobj in skin.jointBindings

				joint = jobj.jointID;
				jointAnimations = @getAnimationsForID(joint.id,false);
				
				if (jointAnimations?)
					
					for jointAnimation in jointAnimations
					
						if(!doneAnims[ jointAnimation._reference.id ])
						
							doneAnims[ jointAnimation._reference.id ] = {tracks:[],iflType:"IFLAnimation"}
							doneAnims[ jointAnimation._reference.id ]._reference = { id:jointAnimation._reference.id,iflType:"IFLID"};
							r.push( doneAnims[jointAnimation._reference.id] );
						
						
						animRet = doneAnims[jointAnimation._reference.id];
						
						for track in jointAnimation.tracks when animRet.tracks.indexOf(track) == -1
							animRet.tracks.push( track );
					
				
			return r;


		getAnimationsForID : (id) ->
		
			r = []
			
			for animation in @_content when animation.iflType == "IFLAnimation"
				tracks = animation.tracks;

				for track in tracks when track.target.id == id && r.indexOf(animation) == -1
					r.push( animation );
			
			return if r.length > 0 then r 
			return null

		findJointParent: (node) ->
			for content in @_content when @isIFLNode(content)
				for childID in content.childIDs
					if childID.id == node._reference.id 
						if content.iflType == "IFLJoint"
							return content
						else
							return @findJointParent(content)
			return null