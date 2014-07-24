class ShaderManager

    @shaders        : [ "Basic", "Displacement", "Dotscreen", "Star", "Wave", "Color", "BleachPass", "Dof", "Colorify", "Film", "Kaleidoscope", "Vignette" ]

    @uniforms       : null
    @attributes     : null

# -----------------------------------------------------
# Get a shader
# -----------------------------------------------------
    
    @shader : ( id, texture ) ->

        # Reset shader
        @attributes = { }
        @uniforms = {
            tDiffuse: { type: "t", value: texture }
        }
        
        # Get current settings of the selected shader
        @addAttributesOf( id )
        @addUniformsOf( id )

        # Create the material
        shaderMaterial = new THREE.ShaderMaterial {
            uniforms: @uniforms,
            attributes: @attributes,
            vertexShader: @load( id, "vs" ),
            fragmentShader: @load( id, "fs" )
        }

        # Return
        shaderMaterial

# -----------------------------------------------------
# Add respective attributes of each shader
# -----------------------------------------------------

    @addAttributesOf : ( id ) ->

        attributes = { }

        switch id

            # Basic
            when 0

                attributes = { }

            # Displacement
            when 1

                attributes = {
                    displacement: { type: "f", value: [] }
                }

            # Dotscreen
            when 2

                attributes = { }

            # Star
            when 3

                attributes = { }

            # Wave
            when 4

                attributes = { }

            # Color
            when 5

                attributes = { }

            # BleachPass
            when 6

                attributes = { }

            # Dof
            when 7

                attributes = { }

            # Colorify
            when 8

                attributes = { }

            # Film
            when 9

                attributes = { }

            # Test
            when 10

                attributes = { }

            # Vignette
            when 11

                attributes = { }

            else console.log "Invalid shader ID."

         for key, value of attributes
            @attributes[ key ] = value

# -----------------------------------------------------
# Add respective uniforms of each shader
# -----------------------------------------------------

    @addUniformsOf : ( id ) ->

        uniforms = { }

        switch id

            # Basic
            when 0

                uniforms = { }

            # Displacement
            when 1

                uniforms = {
                    amplitude: { type: "f", value: 0 }
                }

            # Dotscreen
            when 2

                uniforms = { }

            # Star
            when 3

                uniforms = {
                    time: { type: "f", value: 1.0 },
                    resolution: { type: "v2", value: new THREE.Vector2() }
                }

            # Wave
            when 4

                uniforms = {
                    time: { type: "f", value: 1.0 },
                    resolution: { type: "v2", value: new THREE.Vector2() }
                }

            # Color
            when 5

                uniforms = {
                    time: { type: "f", value: 1.0 },
                    resolution: { type: "v2", value: new THREE.Vector2() }
                }

            # Bleach Pass
            when 6

                uniforms = {
                    time: { type: "f", value: 1.0 },
                    opacity: { type: "f", value: 1.0 }
                }

            # Dof
            when 7

                uniforms = {
                    "tColor":   { type: "t", value: null },
                    "focus":    { type: "f", value: 1.0 },
                    "aspect":   { type: "f", value: 1.0 },
                    "aperture": { type: "f", value: 0.025 },
                    "maxblur":  { type: "f", value: 1.0 }
                }

            # Colorify
            when 8

                uniforms = { }

            # Film
            when 9

                uniforms = {
                    "time":       { type: "f", value: 0.0 },
                    "nIntensity": { type: "f", value: 1.0 },
                    "sIntensity": { type: "f", value: 1.0 },
                    "sCount":     { type: "f", value: 4096 },
                    "grayscale":  { type: "i", value: 0 }
                }
            
            # Test
            when 10

                uniforms = {
                    "resolution": { type: "v2", value: new THREE.Vector2( 200, 160 ) },
                    "time":      { type: "f", value: 1.0 }
                }

            # Vignette
            when 11

                uniforms = {
                    "offset":   { type: "f", value: 1.0 },
                    "darkness": { type: "f", value: 1.0 }
                }

            else console.log "Invalid shader ID."

         for key, value of uniforms
            @uniforms[ key ] = value

# -----------------------------------------------------
# Manager
# -----------------------------------------------------

    @load : ( id, type ) ->

        XHR = new XMLHttpRequest
        XHR.open "GET", "js/shaders/#{ @shaders[ id ] }/#{ @shaders[ id ] }.#{ type }", false

        if XHR.overrideMimeType
            XHR.overrideMimeType "text/plain"

        try
            XHR.send null
        catch e
            console.log "Error reading file " + path

        XHR.responseText

    @process : ( id, params ) ->

        switch id

            # Displacement
            when 1

                verts = params.plane.geometry.vertices
                values = @attributes.displacement.value
                for v in [0..verts.length]
                    values.push Math.random() * 10

            # Dotscreen
            when 2

                a = 1

            # Star
            when 3

                @uniforms.resolution.value.x = 200
                @uniforms.resolution.value.y = 160

            # Wave
            when 4

                @uniforms.resolution.value.x = 200
                @uniforms.resolution.value.y = 160

            # Color
            when 5

                @uniforms.resolution.value.x = 200
                @uniforms.resolution.value.y = 160

            # Bleach Pass
            when 6

                @uniforms.opacity.value = 1.0

            # Dof
            when 7

                @uniforms.tColor.value = @uniforms.tDiffuse.value;

            # Colorify
            when 8

                a = 1

            # Film
            when 9

                a = 1

            # Test
            when 10

                a = 1

            # Vignette
            when 11

                a = 1



        console.log "Shader '#{ @shaders[ id ] }' processed."

    @render : ( id, params ) ->

        switch id

            # Displacement
            when 1
                
                @uniforms.amplitude.value = Math.sin params.elapsedTime

            # Dotscreen
            when 2

                a = 1

            # Star
            when 3

                @uniforms.time.value = params.elapsedTime

            # Wave
            when 4

                @uniforms.time.value = params.elapsedTime

            # Color
            when 5

                @uniforms.time.value = params.elapsedTime

            # Bleach Pass
            when 6

                @uniforms.time.value = params.elapsedTime
                @uniforms.opacity.value = 1.0

            # Dof
            when 7

                @uniforms.focus.value = 0.3;
                @uniforms.aperture.value = 0.075;
                @uniforms.maxblur.value = 3;

            # Colorify
            when 8

                a = 1

            # Film
            when 9

                @uniforms.time.value = params.elapsedTime

            # Test
            when 10

                @uniforms.time.value = params.elapsedTime

            # Vignette
            when 11

                @uniforms.offset.value = Math.sin(params.elapsedTime) * 2

