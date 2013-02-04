class BrowserDetection

    browser = null
    browserVersion = null
    webGL = false

    constructor: ->
        @browser = BrowserDetect.browser
        @browserVersion = BrowserDetect.version

        webGLContextCreationSuccessful = false

        try 
            _canvas = document.createElement( 'canvas' )
            if ( ! ( _gl = _canvas.getContext( 'experimental-webgl', { alpha: 1, premultipliedAlpha: true, antialias: false, stencil: true, preserveDrawingBuffer: false } ) ) )
                webGLContextCreationSuccessful = false
            else
                
                # TODO: this should not exclude the device from viewing the site
                _glExtensionCompressedTextureS3TC = _gl.getExtension( 'WEBGL_compressed_texture_s3tc' ) || _gl.getExtension( 'MOZ_WEBGL_compressed_texture_s3tc' ) || _gl.getExtension( 'WEBKIT_WEBGL_compressed_texture_s3tc' );
                formats = _gl.getParameter(_gl.COMPRESSED_TEXTURE_FORMATS)

                dxt5Supported = false;
                dxt3Supported = false;
                dxt1Supported = false;
                dxt1Supported2 = false;

                if formats?
                    for format in formats
                        if format ==  _glExtensionCompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT5_EXT 
                            dxt5Supported = true;
                        if format ==  _glExtensionCompressedTextureS3TC.COMPRESSED_RGB_S3TC_DXT1_EXT 
                            dxt1Supported = true;
                        if format ==  _glExtensionCompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT1_EXT 
                            dxt1Supported2 = true;
                        if format ==  _glExtensionCompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT3_EXT 
                            dxt3Supported = true;
                

                _glExtensionTextureFilterAnisotropic = _gl.getExtension( 'EXT_texture_filter_anisotropic' ) || _gl.getExtension( 'MOZ_EXT_texture_filter_anisotropic' ) || _gl.getExtension( 'WEBKIT_EXT_texture_filter_anisotropic' );

                webGLContextCreationSuccessful = _glExtensionCompressedTextureS3TC && _glExtensionTextureFilterAnisotropic && dxt5Supported && dxt3Supported && dxt1Supported && dxt1Supported2

        catch error
            webGLContextCreationSuccessful =  false  


        webGL = Modernizr.webgl && webGLContextCreationSuccessful

    init: ->
        @compare()

    compare: =>
        if @browser == 'Chrome' and webGL
            @onSuccess()

        else if @browser == 'Chrome' and !webGL
            @onError
                message : 'Chrome_NoWebGL_message'
                buttons : ['Chrome_NoWebGL_button1', 'Chrome_NoWebGL_button2']

        else if @browser == 'Firefox' and webGL
            @onError
                message : 'FF4_Safari_WebGLmessage'
                buttons : ['FF4_Safari_WebGL_button1', 'FF4_Safari_WebGL_button2']

        else if @browser == 'Firefox' and !webGL
            @onError
                message : 'FF4_noWebGL_message'
                buttons : ['FF4_noWebGL_button1', 'FF4_noWebGL_button2']

        else if @browser == 'Explorer' and ( @browserVersion == 6 || @browserVersion == 7 || @browserVersion == 8 || @browserVersion == 9 )
            @onError
                message : 'Explorer_OldVersion_message'
                buttons : ['Explorer_OldVersion_button1']

        else if @browser == 'Safari' and webGL
            @onError
                message : 'FF4_Safari_WebGLmessage'
                buttons : ['FF4_Safari_WebGL_button1', 'FF4_Safari_WebGL_button2']

        else if @browser == 'Safari' and !webGL 
            @onError
                message : 'Safari_message'
                buttons : ['Safari_button1']

        else 
            if !window.WebGLRenderingContext
                @onError
                    message : 'NoWebGLRenderingContext_message'
                    buttons : ['NoWebGLRenderingContext_button1', 'NoWebGLRenderingContext_button2']

            # gl = canvas.getContext("webgl")
            if !webGLContextCreationSuccessful
                @onError
                    message : 'NoWebGL_message'
                    buttons : ['NoWebGL_button1', 'NoWebGL_button2']

    onSuccess: =>
        @onError
            message : 'Chrome_NoWebGL_message'
            buttons : ['Chrome_NoWebGL_button1', 'Chrome_NoWebGL_button2']

    onError: ( error ) =>

    





