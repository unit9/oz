class BrowserDetection

    browser         : null
    browserVersion  : null
    gl              : null
    webGL           : false
    webGLContext    : false
    webGLAdvanced   : false
    forcePass       : false

    constructor: ->
        @browser = BrowserDetect.browser
        @browserVersion = BrowserDetect.version
        try
            @webGLContext = @testWebGLContext()
            @webGLAdvanced = @testWebGLAdvancedFeats()
        catch error
            
        @webGL = Modernizr.webgl && @webGLContext

    init: ->
        @compare()

    compare: =>
        if ( @browser == 'Chrome' and ( @webGL && @webGLAdvanced ) ) || ( @forcePass == true )
            # all good
            @onSuccess()

        else if @browser == 'Chrome' and ( @webGL && !@webGLAdvanced )
            # chrome with webgl but no advanced feats (shitty chromebook) 
            @onError
                message : 'Chrome_NoWebGLAdvancedFeats_message'
                buttons : ['Chrome_NoWebGL_button1', 'Chrome_NoWebGL_button2']

        else if @browser == 'Chrome' and !@webGL
            # chrome with no webgl
            @onError
                message : 'Chrome_NoWebGL_message'
                buttons : ['Chrome_NoWebGL_button1', 'Chrome_NoWebGL_button2']

        else if @browser == 'Firefox' and ( @webGL && @webGLAdvanced )
            # firefox with webgl AND advanced feats
            @onError
                message : 'FF4_Safari_WebGLmessage'
                buttons : ['FF4_Safari_WebGL_button1', 'FF4_Safari_WebGL_button2']

        else if @browser == 'Firefox' and ( !@webGL || !@webGLAdvanced )
            # firefox with no webgl OR advanced feats
            @onError
                message : 'FF4_noWebGL_message'
                buttons : ['FF4_noWebGL_button1', 'FF4_noWebGL_button2']

        else if @browser == 'Explorer' and ( @browserVersion == 6 || @browserVersion == 7 || @browserVersion == 8 || @browserVersion == 9 )
            # old explorer
            @onError
                message : 'Explorer_OldVersion_message'
                buttons : ['Explorer_OldVersion_button1']

        else if @browser == 'Safari' and ( @webGL && @webGLAdvanced )
            # safari with webgl and advanced feats
            @onError
                message : 'FF4_Safari_WebGLmessage'
                buttons : ['FF4_Safari_WebGL_button1', 'FF4_Safari_WebGL_button2']

        else if @browser == 'Safari' and ( !@webGL || !@webGLAdvanced )
            # safari with no webgl OR no advanced feats
            @onError
                message : 'FF4_noWebGL_message'
                buttons : ['Safari_button1']

        else 
            if !window.WebGLRenderingContext
                @onError
                    message : 'NoWebGLRenderingContext_message'
                    buttons : ['NoWebGLRenderingContext_button1', 'NoWebGLRenderingContext_button2']

            else if !@webGLContext
                @onError
                    message : 'NoWebGL_message'
                    buttons : ['NoWebGL_button1', 'NoWebGL_button2']

    onSuccess: =>
        @onError
            message : 'Chrome_NoWebGL_message'
            buttons : ['Chrome_NoWebGL_button1', 'Chrome_NoWebGL_button2']

    onError: ( error ) =>

    testWebGLContext:()=>
        result = false

        try 
            _canvas = document.createElement( 'canvas' )
            if ( ! ( @gl = _canvas.getContext( 'experimental-webgl', { alpha: 1, premultipliedAlpha: true, antialias: false, stencil: true, preserveDrawingBuffer: false } ) ) )
                #failed webgl initialization
                result = false
            else
                result = true
        catch error
            # error doing stuff
            result =  false

        return result


    testWebGLAdvancedFeats:()->
        if !@gl?
            return false

        # test dxt texture support
        _glExtensionCompressedTextureS3TC = (
            @gl.getExtension( 'WEBGL_compressed_texture_s3tc' ) || 
            @gl.getExtension( 'MOZ_WEBGL_compressed_texture_s3tc' ) ||
            @gl.getExtension( 'WEBKIT_WEBGL_compressed_texture_s3tc' ) )


        formats = @gl.getParameter(@gl.COMPRESSED_TEXTURE_FORMATS)

        dxt5Supported       = false;
        dxt3Supported       = false;
        dxt1Supported       = false;
        dxt1rgbaSupported   = false;

        if formats?
            for format in formats
                switch format
                    when _glExtensionCompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT5_EXT  then dxt5Supported     = true
                    when _glExtensionCompressedTextureS3TC.COMPRESSED_RGB_S3TC_DXT1_EXT   then dxt1Supported     = true
                    when _glExtensionCompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT1_EXT  then dxt1rgbaSupported = true
                    when _glExtensionCompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT3_EXT  then dxt3Supported     = true
        
        # test anisotropic texture support
        _glExtensionTextureFilterAnisotropic = (
            @gl.getExtension( 'EXT_texture_filter_anisotropic' ) || 
            @gl.getExtension( 'MOZ_EXT_texture_filter_anisotropic' ) || 
            @gl.getExtension( 'WEBKIT_EXT_texture_filter_anisotropic' ) )


        # @gl.activeTexture( @gl.TEXTURE0 + 0 )
        # err = @gl.getError()
        # if err != 0
        #     return false
        
        # @gl.bindTexture( @gl.TEXTURE_2D, @gl.createTexture() )
        # err = @gl.getError()
        # if err != 0
        #     return false

        # @gl.compressedTexImage2D( @gl.TEXTURE_2D, 0, _glExtensionCompressedTextureS3TC.COMPRESSED_RGBA_S3TC_DXT5_EXT, 16, 16, 0,  new Uint8Array(16*16) )
        # err = @gl.getError()
        # if err != 0
        #     return false

        return _glExtensionCompressedTextureS3TC && _glExtensionTextureFilterAnisotropic && dxt5Supported && dxt3Supported && dxt1Supported && dxt1rgbaSupported