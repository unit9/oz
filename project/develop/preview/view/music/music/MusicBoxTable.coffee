class MusicBoxTable extends Abstract

    template: 
        "
        <div class='box-container'>
            <div class='decorated-box'>

                <div class='center_bar'></div>
                
                <div id='r1' class='row'>
                    <div id='c11' class='cell'></div>
                    <div id='c12' class='cell'></div>
                    <div id='c13' class='cell'></div>
                </div>

                <div id='r2' class='row'>
                    <div id='c21' class='cell'></div>
                    <div id='c22' class='cell'>
                        <div class='grid-mask'></div>
                    </div>
                    <div id='c23' class='cell'></div>
                </div>

                <div id='r3' class='row'>
                    <div id='c31' class='cell'></div>
                    <div id='c32' class='cell'></div>
                    <div id='c33' class='cell'></div>
                </div>
            </div>
            <div class='musicbox_button_container'>
            </div>
        </div>
        "

    playing: false
    stopPlaying: false
    wasPlaying: false

    animationTimer: null
    animationDuration: 1000 / 3

    initialize: (data) =>

        @data = data

        super()

    init: =>

        @render()

    render: =>

        # Add grid
        @grid = new MusicBoxGrid
        @grid.buildTable @data
        @container = @$el.find ".grid-mask"
        @container.append @grid.$el

        # Play button
        @playBtn = new SSAsset 'button_play'
        
        # Pause button
        @pauseBtn = new SSAsset 'button_pause'
        @pauseBtn.$el.css
            "position"  : "absolute"
            "top"       : 0
            "width"     : "#{parseInt(@pauseBtn.$el.css("width")) + 1}px"

        @pauseBtn.hide()

        # Control buttons container
        @playPauseBtn = new Abstract().setElement $("<div class='autoplay'/>")
        @playPauseBtn.$el.on "click", @togglePlay
        @playPauseBtn.addChild @playBtn
        @playPauseBtn.addChild @pauseBtn

        # Buttons container
        buttonsContainer = @$el.find('.musicbox_button_container')

        # Add play/pause to container
        buttonsContainer.append @playPauseBtn.$el

        # Share your tune
        @export = new SimpleButton "exportJson", "Export JSON"
        @export.on "click", @exportJson
        buttonsContainer.append @export.$el


    exportJson : =>

        data = @exportSong 'col'
        data.dimensions = 
            "lines" : @data.dimensions.lines
            "cols"  : @data.dimensions.cols
        data.notes = @data.notes
        data.loops = @data.loops

        a = document.createElement('a')
        blob = new Blob([(JSON.stringify data)], {"type": "text\/json"})
        a.href = window.URL.createObjectURL blob
        a.download = "music.json"
        a.click()

    togglePlay: =>

        if @playing then @stop() else @play()

    play: =>

        @playLoop $(@$el.find('table')[0])
        @playAudioLoop @exportSong('col')

        # Playing state
        @playing = true
        @grid.playing true

        @playBtn.hide true
        @pauseBtn.show true

    stop: =>

        @stopLoop()
        @stopAudioLoop()

        # Playing state
        @playing = false
        @grid.playing false

        @playBtn.show true
        @pauseBtn.hide true

    playLoop: (table) ->

        # Remove any existing tooltips before cloning
        tooltips = table.find '.music-note-tooltip'
        i = 0
        while i < tooltips.length
            $(tooltips[i]).remove()
            i++

        # Clone the table
        clone = table.clone(true, true)
        @grid.$el.append clone

        # Once playing, add a -3px left tweak to make seamless (removed when stopping)
        clone.addClass "leftTweak"

        # Animate original table out, new table will graciously fall in
        tableWidth = parseInt(table.css("width"), 10)
        @loopAnimation = table.animate( {"margin-left" : -tableWidth}, @animationDuration * @data.dimensions.cols, "linear", () =>
                # Dispose, trigger next loop.
                table.remove()
                @playLoop $(@$el.find('table')[0])
            )

    stopLoop: ->

        @loopAnimation.stop()

        if @$el.find('table').length > 1
            table = $(@$el.find('table')[0])
            table.remove()

        # Remove the -3px tweak that makes grid animation seamless
        $(@$el.find('table')).removeClass "leftTweak"

    playAudioLoop: (songArr) ->

        colStepDuration = @animationDuration
        @colNo = @data.dimensions.cols / 2 # Start with column directly to the right of the play head.

        @doLoopAudio songArr

        @loopAudio = setInterval @doLoopAudio, colStepDuration, songArr

    doLoopAudio: (songArr) =>

        if @colNo > @data.dimensions.cols - 1
            @colNo = 0

        console.log "------------------------------------------- ", @colNo

        currentCol = songArr.cols[ @colNo ]
        
        i = 0
        while i < currentCol.rows.length
            rowNo = currentCol.rows[i]
            @playSound @colNo, rowNo
            @animateCell @colNo, rowNo
            i++

        # PLAY LOOPS
        i = 0
        while i < @data.loops.length
            @playLoopSound @data.loops[i]
            i++

        @colNo++

    playLoopSound : (data) =>

        event = ""

        if data.step
            if @colNo % data.step == 0
                # console.log '------------------------------------------- Playing loop at every '+data.step+' columns..'
                event = data.event
        else if data.col? 
            if @colNo == data.col
                # console.log '------------------------------------------- Playing loop at '+data.col+' column..'
                event = data.event

        if event != ""
            SoundController.send data.event

    stopAudioLoop: ->

        clearInterval(@loopAudio)

    exportSong: (orderBy) ->

        if !orderBy
            orderBy = 'row'

        # export simple song array from DOM
        table = $(@$el.find('table'))
        
        if orderBy == 'row'
            songExport = { 'rows' : []}
            i = 0

            # loop cells, create array
            while i < @data.dimensions.lines
                songExport.rows[i] = { 'columns' : [] }
                n = 0
                while n < @data.dimensions.cols
                    if @checkCell(table, i, n) == true
                         songExport.rows[i].columns.push n
                    n++
                i++

        else if orderBy == 'col'
            songExport = { 'cols' : []}
            i = 0

            # loop cells, create array
            while i < @data.dimensions.cols
                songExport.cols[i] = { 'rows' : [] }
                n = 0
                while n < @data.dimensions.lines
                    if @checkCell(table, n, i) == true
                         songExport.cols[i].rows.push n
                    n++
                i++

        songExport

    checkCell: (table, rowNum, colNum) ->

        row = $(table.find('tr')[rowNum])
        cell = $(row.find('td')[colNum])

        if cell
            if cell.hasClass 'on'
                true
            else
                false
        else

            throw "Error exporting song: couldn't find specified cell."

    playSound: (colNo, rowNo) ->

        # console.log 'Playing sound for cell [col][row] : ['+colNo+']['+rowNo+']..'

        # Play sound
        SoundController.send @getSoundEvent(colNo, rowNo)

    animateCell: (colNo, rowNo) ->

        # Animate cell flash

        if colNo < (@data.dimensions.cols / 2) and @$el.find('table').length > 1
            table = @$el.find('table')[1]
        else
            table = @$el.find('table')[0]

        row = $(table).find('tr')[rowNo]
        cell = $(row).find('td')[colNo]
        $(cell).addClass 'flash'
        removeFlash = ->
            $(cell).removeClass 'flash'
        flashDuration = @animationDuration
        setTimeout removeFlash, flashDuration

    getSoundEvent: (colNo, rowNo) ->

        @data.notes[(@data.dimensions.lines-1) - rowNo].event

    dispose: =>

        @loopAnimation.stop()

        @playPauseBtn.$el.off "click", @togglePlay
        @btAmbientSound.off "click", @testAmbientSound
        @export.off "click", @exportJson
