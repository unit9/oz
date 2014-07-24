/**
 * @author alteredq / http://alteredqualia.com/
 * @author mrdoob / http://mrdoob.com/
 */

CustomImageUtils = {

	crossOrigin: 'anonymous',

	cacheTextures:true,

	loadedCompressedTextures:{},
	parsedCompressedTextures:{},

	loadedTextures:{},

	loadTexture: function ( url, mapping, onLoad, onProgress, onError, textureIndex ) {
		
		var image = new Image();
		var texture = new THREE.Texture( image, mapping );
		texture.name = "PNG_"+url

		if(CustomImageUtils.loadedTextures[url]!=undefined) {
			
			texture.image = CustomImageUtils.loadedTextures[url];
			texture.needsUpdate = true;

			//console.log("CustomImageUtils texture cached");

			if ( onProgress ) onProgress( 1, textureIndex );
			if ( onLoad ) onLoad( texture, textureIndex );
			return texture;
		}

		var loader = new CustomImageLoader(url);

		loader.onLoadCallback =  function ( event ) {
			//alert("load di Utils");
			texture.image = event.content;
			texture.needsUpdate = true;

			if(CustomImageUtils.cacheTextures)
				CustomImageUtils.loadedTextures[url] = event.content;

			//console.log("CustomImageUtils texture caching");
			
			if ( onLoad ) onLoad( texture, textureIndex );

		};
		
		loader.onProgressCallback = function ( event ) {
			//alert("progress di Utils");
			if ( onProgress ) onProgress( event.progress, textureIndex );

		};
		
		loader.onErrorCallback =  function ( event ) {
			//alert("error di Utils:"+event.message);
			if ( onError ) onError( event.message );

		};

		loader.crossOrigin = this.crossOrigin;
		loader.load( url, image );

		texture.sourceFile = url;

		return texture;

	},
	loadCompressedTexture: function ( url, mapping, onLoad, onProgress, onError, skipParse, textureIndex ) {
		
		var texture = new THREE.CompressedTexture();
		texture.mapping = mapping;
		texture.name = "DDS_"+url

		if(CustomImageUtils.loadedCompressedTextures[url] != undefined) {

			if(!skipParse)
			{
				var buffer = CustomImageUtils.loadedCompressedTextures[url];
				var dds;
				if(CustomImageUtils.parsedCompressedTextures[url] != undefined) {
					dds = CustomImageUtils.parsedCompressedTextures[url]
				}
				else {
					try
					{
						dds = THREE.ImageUtils.parseDDS( buffer, true );
						if(CustomImageUtils.cacheTextures)
							CustomImageUtils.parsedCompressedTextures[url] = dds;
					}
					catch (error)
					{
						if(onError) onError(texture,error)
						return texture
					}
				}

				texture.format = dds.format;
				texture.mipmaps = dds.mipmaps;
				texture.image.width = dds.width;
				texture.image.height = dds.height;

			}
			texture.generateMipmaps = false;
			texture.needsUpdate = true;
			
			//console.log("CustomImageUtils texture compressed cached");
			if ( onProgress ) onProgress( 1, textureIndex );
			if ( onLoad ) onLoad( texture, textureIndex );
			return texture
		}

		var request = new XMLHttpRequest();

		request.onload = function () {

			var buffer = request.response;

			if(!skipParse)
			{
				var dds;
				var dds;
				if(CustomImageUtils.parsedCompressedTextures[url] != undefined) {
					dds = CustomImageUtils.parsedCompressedTextures[url]
				}
				else {
					try
					{
						dds = THREE.ImageUtils.parseDDS( buffer, true );
						if(CustomImageUtils.cacheTextures)
							CustomImageUtils.parsedCompressedTextures[url] = dds
					}
					catch (error)
					{
						if(onError) onError(texture,error)
						return texture
					}						
				}

				texture.format = dds.format;
				texture.mipmaps = dds.mipmaps;
				texture.image.width = dds.width;
				texture.image.height = dds.height;
			}	
			// gl.generateMipmap fails for compressed textures
			// mipmaps must be embedded in the DDS file
			// or texture filters must not use mipmapping
			texture.generateMipmaps = false;
			texture.needsUpdate = true;

			if(CustomImageUtils.cacheTextures)
				CustomImageUtils.loadedCompressedTextures[url] = buffer;

			//console.log("CustomImageUtils texture compressed caching");
			if ( onLoad ) onLoad( texture, textureIndex );

		}
		
		request.onprogress = function (evt){
			if (evt.lengthComputable) { 
    			var prog = (evt.loaded / evt.total);  
    			if ( onProgress ) onProgress( prog, textureIndex );
  			} 
		}
		
		request.onerror = onError;

		request.open( 'GET', url, true );
		request.responseType = "arraybuffer";
		request.send( null );

		return texture;

	}

};
