class IFLVideoTexture
	id : 0
	image : null
	mapping : null
	wrapS : 0
	wrapT : 0
	magFilter : 0
	minFilter : 0
	anisotropy : 0
	format : 0
	type : 0
	offset : null
	repeat : null
	generateMipmaps : false
	premultiplyAlpha : false
	flipY : true
	needsUpdate : true
	#onUpdate : null

	video : null
	canvaselement : null
	canvascontext : null

	videoURL : null
	videoWidth : 0
	videoHeight : 0

	width : 0;
	height : 0;
	fps : 24
	clock : null

	constructor:( videoURL, videoWidth, videoHeight, width, height, fps )->
		@id = THREE.TextureCount++;

		@clock =  new THREE.Clock()
		#@image = image;

		@mapping =  new THREE.UVMapping();

		@wrapS = THREE.ClampToEdgeWrapping;
		@wrapT = THREE.ClampToEdgeWrapping;

		@magFilter = THREE.LinearFilter;
		@minFilter = THREE.LinearFilter;

		@anisotropy = 1;

		@format = THREE.RGBFormat;
		@type = THREE.UnsignedByteType;

		@offset = new THREE.Vector2( 0, 0 );
		@repeat = new THREE.Vector2( 1, 1 );

		@generateMipmaps = false;
		@premultiplyAlpha = false;
		@flipY = true;

		@needsUpdate = true;
		#@onUpdate = null;

		@videoURL = if videoURL? then videoURL else "video.mp4"
		@videoWidth = if videoWidth? then videoWidth else 1024
		@videoHeight = if videoHeight? then videoHeight else 1024
		@width = if width? then width else 1024
		@height = if height? then height else 1024
		@fps = if fps? then fps else 24

		@video 				= document.createElement('video')
		@video.src 			= @videoURL
		@video.width 		= @videoWidth;
		@video.height    	= @videoHeight;
		@video.autoplay 	= true;
		@video.loop  		= true;

		@canvaselement 			= document.createElement('canvas')
		@canvaselement.width 	= @width
		@canvaselement.height 	= @height

		@canvascontext = @canvaselement.getContext("2d")
		
		# @canvascontext.webkitImageSmoothingEnabled = false


		@image = @canvaselement


		# setInterval(@updateTexture,1000/@fps);
		return


	updateTexture:()=>
		@canvascontext.clearRect(0, 0, @width, @height)
		@canvascontext.drawImage( @video, 0, 0, @videoWidth, @videoHeight, 0, 0, @width, @height )
		@needsUpdate = true
		return

	clone:()->
		texture = new VideoTexure(@videoURL,@videoWidth,@videoHeight,@width,@height);

		texture.image = @image;

		texture.mapping = @mapping;

		texture.wrapS = @wrapS;
		texture.wrapT = @wrapT;

		texture.magFilter = @magFilter;
		texture.minFilter = @minFilter;

		texture.anisotropy = @anisotropy;

		texture.format = @format;
		texture.type = @type;

		texture.offset.copy( @offset );
		texture.repeat.copy( @repeat );

		texture.generateMipmaps = @generateMipmaps;
		texture.premultiplyAlpha = @premultiplyAlpha;
		texture.flipY = @flipY;

		return texture;