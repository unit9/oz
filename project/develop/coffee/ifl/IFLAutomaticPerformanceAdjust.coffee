class IFLAutomaticPerformanceAdjust


    # this FPS determines when affects begin to be gradually disabled
    maxFrameTime : 1 / 15
    # this framerate determines when effects are all immediately disabled
    emergencyFramerate : 1 / 9


    MAXSAMPLES : 400
    tickindex : 0
    ticksum : 0
    ticklist : null
    steps : null
    ignoreticks : 0
    resetTime : 0

    constructor:->
        @steps = []
        @reset()

    update:(delta)->
        @resetTime += delta
        average =  @calcAverageFrametime( delta )

        @steps.sort( (a,b)-> return b.priority - a.priority )

        halfTicksDone = @tickindex > @MAXSAMPLES / 2
        timeOutPassed = @resetTime > 20000

        for step in @steps


            if step.enabled && ( halfTicksDone or timeOutPassed )

                if average > @maxFrameTime
                    step.enabled = false

                    if step.disableFunc?
                        step.disableFunc()
                    else
                        step.object[step.property] = false
                    console.info "[IFLAutomaticPerformanceAdjust] Disabled #{step.name} as average Frame time [#{average}] is above maximum [#{@maxFrameTime}] after [#{@tickindex}] ticks out of [#{@MAXSAMPLES}]"
                    @reset()


                break    
        return 

    reset:->
        @resetTime = 0
        @ignoreticks = 0
        @tickindex = 0
        @ticksum = 0
        @ticklist = []
        for i in [0...@MAXSAMPLES] by 1
            @ticklist[i] = 0
        # console.log "ticklist reset"
        return


    # need to zero out the ticklist array before starting */
    # average will ramp up until the buffer is full */
    # returns average ticks per frame over the MAXSAMPPLES last frames */

    calcAverageFrametime:(newtick)->
        @ignoreticks++
        return unless @ignoreticks > 10
        
        @ticksum -= @ticklist[@tickindex];  # subtract value falling off
        @ticksum += newtick;                # add new value
        @ticklist[@tickindex] = newtick     # save new value so it can be subtracted later
        if ++@tickindex == @MAXSAMPLES      # inc buffer index
            @tickindex = 0;

        # return average */
        return @ticksum/@MAXSAMPLES        