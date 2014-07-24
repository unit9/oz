class IFLHotspotManager

    
    settings : null
    scene : null
    camera : null
    materialManager : null
    localeTexture : null
    hotspots : null
    clickedHotspot : null
    hotspotRolloutAlpha : 1

    dispose:->
        @settings = null
        @scene = null
        @camera = null
        @materialManager = null
        @localeTexture = null
        @hotspots = null
        @clickedHotspot = null

    update:(delta)->
        if @hotspots?
            for hotspot in @hotspots
                hotspot.lookAt(@camera.position)        
        return

    handleMouseUp:(mouseUpObjects,mouseDownObjects)->
        if @hotspots?
            for hotspot in @hotspots
                mouseUpHotspot = if mouseUpObjects[hotspot.name]? then mouseUpObjects[hotspot.name] else false
                mousedownhotspot = if mouseDownObjects[hotspot.name]? then mouseDownObjects[hotspot.name] else false
                if mousedownhotspot != false && mouseUpHotspot != false && @is3DMouseClick(mousedownhotspot,mouseUpHotspot)

                    @clickedHotspot = hotspot.link
                    return true

        return false

    hotspotsAlpha:(alpha)->
        for hotspot in @hotspots
            if hotspot.rollovered
                new TWEEN.Tween(hotspot.material).to({opacity:alpha}, 500).start()
            else
                new TWEEN.Tween(hotspot.material).to({opacity:alpha}, 500).start()        
        return null

    is3DMouseClick:(intersectionDown,intersectionUp)->
        return false unless intersectionDown?.point? && intersectionUp?.point?
        dist = intersectionDown.point.distanceTo(intersectionUp.point)
        return Math.abs( dist ) < 2

    zoomInHotspot:(view,onCompleteCallback,mouseInteraction)->
        switch view
            when 'cutout'

                Analytics.track 'scene3D_1_title_cutout'

                SoundController.send "cutout_zoom_in"


                
                afterInteractivePosition = new THREE.Vector3(@settings.cutout.middle.position[0],@settings.cutout.middle.position[1],@settings.cutout.middle.position[2])
                afterInteractiveLookat = new THREE.Vector3(@settings.cutout.middle.lookat[0],@settings.cutout.middle.lookat[1],@settings.cutout.middle.lookat[2])
               
                @interactiveCameraTween( mouseInteraction.currentLookAt, afterInteractivePosition, afterInteractiveLookat, 50, 1500 ).onComplete onCompleteCallback

                @hotspotsAlpha(0)

                mouseInteraction.currentLookAt = afterInteractiveLookat.clone()
                return true

            when 'music'

                SoundController.send "musicbox_zoom_in"
                Analytics.track 'scene3D_1_title_music'

                afterInteractivePosition = new THREE.Vector3(@settings.music.position[0],@settings.music.position[1],@settings.music.position[2])
                afterInteractiveLookat = new THREE.Vector3(@settings.music.lookat[0],@settings.music.lookat[1],@settings.music.lookat[2])
               
                @interactiveCameraTween( mouseInteraction.currentLookAt, afterInteractivePosition, afterInteractiveLookat, 50, 1500 ).onComplete onCompleteCallback


                @hotspotsAlpha(0)

                mouseInteraction.currentLookAt = afterInteractiveLookat.clone()
                return true

            when 'zoetrope'

                SoundController.send "zoetrope_zoom_in"

                Analytics.track 'scene3D_2_title_zoe'

                afterInteractivePosition = new THREE.Vector3(@settings.zoetrope.position[0],@settings.zoetrope.position[1],@settings.zoetrope.position[2])
                afterInteractiveLookat = new THREE.Vector3(@settings.zoetrope.lookat[0],@settings.zoetrope.lookat[1],@settings.zoetrope.lookat[2])
               
                @interactiveCameraTween( mouseInteraction.currentLookAt, afterInteractivePosition, afterInteractiveLookat, 50, 1500 ).onComplete onCompleteCallback

                @hotspotsAlpha(0)

                mouseInteraction.currentLookAt = afterInteractiveLookat.clone()
                return true

        return false

    interactiveCameraTween:(currentLookAt,position,lookat,fov,time)->
        return unless @camera?
        return unless @camera.position?

        start = 
            positionX : @camera.position.x
            positionY : @camera.position.y
            positionZ : @camera.position.z
            lookAtX   : currentLookAt.x
            lookAtY   : currentLookAt.y
            lookAtZ   : currentLookAt.z
            fov       : @camera.fov

        end = 
            positionX : position.x
            positionY : position.y
            positionZ : position.z 
            lookAtX : lookat.x
            lookAtY : lookat.y
            lookAtZ : lookat.z
            fov     : fov

        tween = new TWEEN.Tween(start).to(end, time).easing( TWEEN.Easing.Quadratic.InOut )


        tween.onUpdate =>
            @camera.fov = start.fov
            @camera.updateProjectionMatrix()
            @camera.position.x = start.positionX
            @camera.position.y = start.positionY
            @camera.position.z = start.positionZ
            @camera.updateMatrix()

            @camera.lookAt new THREE.Vector3(start.lookAtX,start.lookAtY,start.lookAtZ)
            @camera.updateMatrix()

        tween.start()
        return tween

    init:(settings,scene,materialManager,localeTexture,camera)->
        @settings = settings
        @scene = scene
        @materialManager = materialManager
        @localeTexture = localeTexture
        @camera = camera

        @hotspots = []

        for config in @settings.hotspots

            if config.overrideMap? && config.overrideMap.length > 0
                tex = @materialManager.getPreloadedTexture(config.overrideMap)
                customTexture = true
            else
                texName = if config.localizedTexture? then config.localizedTexture else config.link
                customTexture = false

                localizedTexture = @localeTexture.get(texName)
                localizedCanvas = localizedTexture.canvas
                localizedCanvasBounds = localizedTexture.bound
                diffX = localizedCanvas.width - localizedCanvasBounds.width
                oX = diffX / localizedCanvas.width
                tex = new THREE.Texture( localizedCanvas )
                tex.name = config.name+"_localizedtex"
                tex.needsUpdate = true
                # tex.generateMipmaps = false
                # tex.magFilter = THREE.LinearFilter
                # tex.minFilter = THREE.LinearFilter
                tex.offset.x = tex.offset.y = oX / 2
                tex.repeat.x = tex.repeat.y = 1 - oX


            mat = new THREE.MeshBasicMaterial
                map         : tex
                lights      : false
                transparent : true
                opacity     : @hotspotRolloutAlpha
                side        : THREE.DoubleSide


            @materialManager.matLib.push mat
            @materialManager.texLib.push mat.map

            geom = new THREE.PlaneGeometry(config.size,config.size)

            plane = new THREE.Mesh(geom,mat)

            if config.reverse == true
                for vertex in geom.vertices
                    vertex.x = -vertex.x

            if customTexture == true
                for vertex in geom.vertices
                    vertex.y = -vertex.y

            plane.rollovered = false
            plane.pickable = if config.disabled == true then false else true
            plane.name = config.name
            plane.link = config.link
            plane.position.set(config.position[0],config.position[1],config.position[2])
            @hotspots.push( plane )

            @scene.add plane
        return null