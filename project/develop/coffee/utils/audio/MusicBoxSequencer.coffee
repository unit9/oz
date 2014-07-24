class MusicBoxSequencer

    @data                : null
    @playing             : false
    @animationTimer      : null
    @animationDuration   : 1000 / 3

    @initialize : (data) =>

        @data = data

        if !@playing
            @play()

        null

    @toggle : =>

        if @playing then @stop() else @play()
        null

    @play : (from) =>

        @playing = true
        @playAudioLoop from        
        null

    @stop : =>

        @playing = false
        @stopAudioLoop()
        null

    @playAudioLoop : (col) =>

        colStepDuration = @animationDuration
        
        if col
            @colNo = col
        else
            @colNo = @data.cols.length / 2

        @doLoopAudio()
        @loopAudio = setInterval @doLoopAudio, colStepDuration
        null

    @doLoopAudio : (max = @data.cols.length - 1)=>

        if(@colNo > max)
            @colNo = 0

        currentCol = @data.cols[ @colNo ]
        
        i = 0
        while i < currentCol.rows.length
            rowNo = currentCol.rows[i]
            @playSound @colNo, rowNo
            i++

        # PLAY LOOPS
        i = 0
        while i < @data.loops.length
            @playLoopSound @data.loops[i]
            i++

        @colNo++

        null

    @playLoopSound : (data) =>

        event = ""

        if data.step
            if @colNo % data.step == 0
                event = data.event
        else if data.col? 
            if @colNo == data.col
                event = data.event

        if event != ""
            SoundController.send data.event

        null

    @stopAudioLoop : =>

        clearInterval(@loopAudio)
        null

    @playSound: (colNo, rowNo) =>

        # console.log 'Playing sound for cell [col][row] : ['+colNo+']['+rowNo+']..'
        SoundController.send @getSoundEvent(colNo, rowNo)
        null

    @getSoundEvent: (colNo, rowNo) =>

        @data.notes[(@data.dimensions.lines-1) - rowNo].event

    @transitionTo: (playing, currentCol, data) =>

        SoundController.userLoopLonger = data
        
        if playing
            @data = data
            col = if currentCol < 12 then (currentCol + 12) + (data.dimensions.cols / 2) else (currentCol - 12) + (data.dimensions.cols / 2)
            @play col
        else
            @initialize data

        null