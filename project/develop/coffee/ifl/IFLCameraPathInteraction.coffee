class IFLCameraPathInteraction
    
    cameraPositionPoints    : null
    cameraLookatPoints      : null
    lookDeviationY          : null
    lookDeviationX          : null
    bobSpeed                : null
    currentLookAt           : null
    motionspeedelastic      : null
    lookRectangle           : null
    normalVector            : null
    transformedVector       : null
    interpolationVector     : null
    camera                  : null

    motionspeed         : 0.0
    maxspeed            : 0.14
    maxYLookDeviation   : 15
    maxXLookDeviation   : 50
    constantSpeed       : false

    minIndex        : 0
    maxIndex        : 95
    currentIndex    : 20
    currentProgress : 0.0
    delta           : 0

    APP_WIDTH   : 800
    APP_HEIGHT  : 600
    APP_HALF_X  : 400
    APP_HALF_Y  : 300

    mouseX : 0
    mouseY : 0

    forcePathYLookAt : 0
    forcePathYPosition : 0

    mouseEnabled : true



    constructor:(camera)->
        @camera                 = camera
        @cameraPositionPoints   = []
        @cameraLookatPoints     = []
        @currentLookAt          = new THREE.Vector3
        @normalVector           = new THREE.Vector3
        @transformedVector      = new THREE.Vector3
        @interpolationVector    = new THREE.Vector3
        @lookDeviationY         = new ElasticNumber
        @lookDeviationX         = new ElasticNumber
        @bobSpeed               = new ElasticNumber
        @motionspeedelastic     = new ElasticNumber

        @lookDeviationY.spring = @lookDeviationX.spring = @bobSpeed.spring = 0.0015
        @lookDeviationY.damping = @lookDeviationX.damping = @bobSpeed.damping = 0.07

        @motionspeedelastic.spring = 0.002
        @motionspeedelastic.damping = 0.07      

        @lookRectangle = new THREE.Rectangle()
        @lookRectangle.containsPoint = (x, y) -> return x > @getLeft() && x < @getRight() && y > @getTop() && y < @getBottom()           

    update:(delta,mouseX,mouseY)->

        @mouseX = mouseX
        @mouseY = mouseY
        @delta = delta

        @normalMouseInteraction()
        # @swipeMouseInteraction()

        #
        # path movement FIX based on deviation, not mouse posision
        #
        movementMouseAreaWidth = @maxXLookDeviation / 6

        @lookRectangle.set(movementMouseAreaWidth,0,@maxXLookDeviation - movementMouseAreaWidth,@maxYLookDeviation)
        devX = @lookDeviationX._value + (@maxXLookDeviation / 2)

        motionspeed = @calcMotionSpeed(devX,movementMouseAreaWidth)


        if @cameraPositionPoints && @cameraLookatPoints

            @advanceProgress(motionspeed)


            #
            # place camera and deviate lookat
            # 

            # put camera in current interpolated path point
            @camera.position.copy(@interpolate(@cameraPositionPoints))
            @camera.updateMatrix()

            @currentLookAt = @interpolate(@cameraLookatPoints)

            # make camera look at current interpolated path lookat
            # (no mouse deviation)
            @camera.lookAt(@currentLookAt)
            @camera.updateMatrix()

            #calculate normal transformed vec
            @normalVector.set(0,0,0)
            @camera.matrix.multiplyVector3(@normalVector)
            #calculated transformed vec based on deviation
            @transformedVector.set(@lookDeviationX._value,@lookDeviationY._value,0)
            @camera.matrix.multiplyVector3(@transformedVector)            

            # adjust deviated vec
            @transformedVector.subSelf(@normalVector)
            # add it to lookat
            @currentLookAt.addSelf(@transformedVector)
            #redo lookat
            @camera.lookAt(@currentLookAt)
            @camera.updateMatrix()


            #
            # bob camera
            #
            # if (@currentIndex == @minIndex && motionspeed < 0) || ( @currentIndex == @maxIndex && motionspeed > 0)
            #     # disable at borders
            #     @bobSpeed.aimAt(0)
            # else
            #     @bobSpeed.aimAt( -(motionspeed*0.05)/@maxspeed)
            
            # @bobSpeed.step(@delta);

            # #find forward
            # @transformedVector.set(0,0,1)
            # @camera.matrix.multiplyVector3(@transformedVector)
            # @transformedVector.subSelf(@normalVector)
            # #rotate cam
            # @camera.matrix.rotateByAxis(@transformedVector.normalize(),@bobSpeed._value)


        return null

    advanceProgress:(motionspeed)->
        if @constantSpeed 
            # constant speed takes distance between one point ant the other and scales speed accordingly
            distance  = @cameraPositionPoints[@currentIndex].distanceTo(@cameraPositionPoints[@currentIndex+1])
            @currentProgress += (motionspeed * (@delta*100)) / distance
        else
            # no constant speed
            @currentProgress += motionspeed * (@delta*100)

        # go back on path points
        if @currentProgress < 0
            # @currentIndex--
            # @currentProgress = 1
            numskip = Math.abs( Math.floor(@currentProgress) )
            @currentIndex -= numskip
            @currentProgress = @currentProgress + numskip

        # advance on path points
        if @currentProgress > 1
            # @currentIndex++
            # @currentProgress = 0
            numskip = Math.floor(@currentProgress)
            @currentIndex += numskip;
            @currentProgress = @currentProgress - numskip
        
        # block path movement at borders
        if @currentIndex > @maxIndex
            @currentIndex = @maxIndex
            @currentProgress = 1
        else if @currentIndex < @minIndex
            @currentIndex = @minIndex;
            @currentProgress = 0;        

    calcMotionSpeed:(devX,movementMouseAreaWidth)->
        ret = 0

        if devX > @lookRectangle.getRight()
            ret = ( ( devX - @lookRectangle.getRight() ) * @maxspeed) / movementMouseAreaWidth
        else if devX < @lookRectangle.getLeft()
            ret = ( ( devX - @lookRectangle.getLeft() ) * @maxspeed) / movementMouseAreaWidth

        return ret * Math.abs(ret)

    goToIndexAndPosition:(indexAndPosition)->
        @currentIndex  = Math.floor(indexAndPosition)
        @currentProgress = indexAndPosition - @currentIndex
        return null


    findNearestPathPoint:()->
        pos = @camera.position.clone();
        mindistance = 10000000000000
        mindistancepoint = null
        mindistanceindex = -1

        for point,index in @cameraPositionPoints
            dist = Math.abs( point.distanceTo(pos) )
            if dist < mindistance
                mindistancepoint = point
                mindistance = dist
                mindistanceindex = index
       
        if mindistanceindex > @maxIndex
            mindistanceindex = @maxIndex
        if mindistanceindex < @minIndex
            mindistanceindex = @minIndex

        return mindistanceindex

    swipeMouseInteraction:->
        thrustX = 0;
        thrustY = 0;
        if @mouseDown && !@mouseLeft
            thrustX = (@mouseDownPoint.x - @mouseX) / 25
            thrustY = -(@mouseDownPoint.y - @mouseY) / 25
            thrustX *= @delta * 100
            thrustY *= @delta * 100

            aimX = Math.min(@maxXLookDeviation,Math.max( -@maxXLookDeviation, @lookDeviationX._value + thrustX ))
            aimY = Math.min(@maxYLookDeviation,Math.max( -@maxYLookDeviation, @lookDeviationY._value + thrustY ))

            @lookDeviationX.aimAt(aimX) 
            @lookDeviationY.aimAt(aimY) 

        @lookDeviationY.step(@delta);
        @lookDeviationX.step(@delta);

        @lookDeviationX._value = Math.min(@maxXLookDeviation, Math.max( -@maxXLookDeviation , @lookDeviationX._value) )
        @lookDeviationY._value = Math.min(@maxYLookDeviation, Math.max( -@maxYLookDeviation , @lookDeviationY._value) )        
        return null


    normalMouseInteraction:->
        # movementMouseAreaWidth = @APP_WIDTH / 4

        if @mouseEnabled == true
            mmx = @mouseX
            mmy = @mouseY
            mx = @mouseX + @APP_HALF_X
            my = @mouseY + @APP_HALF_Y 
        else
            mmx = 0
            mmy = 0
            mx = @APP_HALF_X
            my = @APP_HALF_Y 


        # @lookRectangle = new THREE.Rectangle()
        # @lookRectangle.containsPoint = (x, y) -> return x > @getLeft() && x < @getRight() && y > @getTop() && y < @getBottom() 
        # @lookRectangle.set(movementMouseAreaWidth,0,@APP_WIDTH - movementMouseAreaWidth,@APP_HEIGHT)

            
        @lookDeviationY.aimAt( -(mmy*@maxYLookDeviation)/@APP_HALF_Y )
        # devX =

        # if @lookRectangle.containsPoint(mx,my)
        @lookDeviationX.aimAt(  (mmx*@maxXLookDeviation) / @APP_HALF_X )
        # else if mx < @lookRectangle.getLeft()
        #     diff = 0
        #     # diff = (@lookRectangle.getLeft() - mx) / movementMouseAreaWidth
        #     # diff /= 2
        #     @lookDeviationX.aimAt( devX * ( 1 - diff ) )
        # else if mx > @lookRectangle.getRight()
        #     diff = 0
        #     # diff = -(@lookRectangle.getRight() - mx) / movementMouseAreaWidth
        #     # diff /= 2
        #     @lookDeviationX.aimAt( devX * ( 1 - diff ) )


        @lookDeviationY.step(@delta)
        @lookDeviationX.step(@delta)
        
        @lookDeviationX._value = Math.min(@maxXLookDeviation, Math.max( -@maxXLookDeviation , @lookDeviationX._value) )
        @lookDeviationY._value = Math.min(@maxYLookDeviation, Math.max( -@maxYLookDeviation , @lookDeviationY._value) )

        return null


    p1 : new THREE.Vector3
    p2 : new THREE.Vector3

    interpolate:(arr)->

        @p1.copy arr[@currentIndex]
        @p2.copy arr[@currentIndex+1]


        if arr == @cameraPositionPoints
            @p1.y += @forcePathYPosition
            @p2.y += @forcePathYPosition

        if arr == @cameraLookatPoints
            @p1.y += @forcePathYLookAt
            @p2.y += @forcePathYLookAt

        @interpolationVector.sub(@p2,@p1)
        @interpolationVector.multiplyScalar(@currentProgress)

        return @interpolationVector.addSelf(@p1)

    handleResize:(w,h)->
        @APP_WIDTH = w
        @APP_HEIGHT = h
        @APP_HALF_X = @APP_WIDTH/2
        @APP_HALF_Y = @APP_HEIGHT/2
        return null

