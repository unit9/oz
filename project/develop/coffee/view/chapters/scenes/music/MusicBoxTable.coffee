class MusicBoxTable extends Abstract

    template: "musicbox-table"

    playing: false
    
    tempo               : 1 / 3
    cellWidth           : 31
    colNo               : 0

    initialize: (data) =>

        @data = data
        super()

        null

    init : =>

        @clock =  new THREE.Clock()

        @grid = new MusicBoxGrid
        @grid.buildTable @data
        @container = @$el.find ".grid-mask"
        @container.append @grid.$el

        # Chords list
        chordsList = new Abstract().setElement '<div class="chordsList"></div>'
        for i in [0...@data.notes.length]
            chordsList.$el.prepend @data.notes[i].label
            if i < @data.notes.length - 1
                chordsList.$el.prepend "<br />"

        chordsList.dispose = () -> return
        @container.append chordsList.$el

        null

    addLine : =>

        centerBar = new SSAsset 'interface', 'music_mid_bar'
        @$el.find('.decorated-box').find('.center_bar').append(centerBar.$el)

        null

    goShare : =>

        Analytics.track 'music_share'

        @oz().appView.subArea.buttons.share.disable()
        @oz().appView.subLoader.show true

        data = @exportSong 'col'
        data.dimensions = 
            "lines" : @data.dimensions.lines
            "cols"  : @data.dimensions.cols
        data.notes = @data.notes
        data.loops = @data.loops

        Requester.addMusic JSON.stringify(data), @musicSaved, @fail
        # For preview: Requester.getMusic data.result.id, @onGetMusic, @fail

        null

    musicSaved: ( data ) =>

        url = window.location.origin + "/preview/music/" + data.result.id
        Requester.shortURL url, @showShareBox, @fail

        null

    showShareBox : (event) =>

        @oz().appView.subArea.buttons.share.enable()
        @oz().appView.subLoader.hide()
        @trigger "SHARE", event.id

        null

    fail: =>
        @oz().appView.subLoader.showError()
        @trigger "fail"

        null

    togglePlay: =>

        if @playing then @stop() else @play()

        null

    play: =>

        # Analytics
        Analytics.track 'music_click_play'

        # Soundcontroller
        SoundController.send "musicbox_play"

        # Deal with buttons
        @trigger 'playState'

        # Set columnn
        @colNo = @data.cols.length / 2

        # Clone the current table to make the loop
        @cloneTable()

        # Export loop to sequencer to be played
        @saveUserLoop()

        # Flag
        @playing = true

        null

    stop: =>

        # Flag
        @playing = false

        # Analytics
        Analytics.track 'music_click_pause'

        # Soundcontroller
        SoundController.send "musicbox_pause"

        # Deal with buttons
        @trigger 'pauseState'

        # Reset Timer
        @resetTimer()

        # Clean up
        @grid.$el.animate {'margin-left' : 0}, 800, "easeInOutQuad", @removeTable
        ###@grid.$el.css {'margin-left' : 0}
        ()###

        null

    resetTimer: =>

        @clock.stop()
        @clock.startTime = 0
        @clock.oldTime = 0
        @clock.elapsedTime = 0

    removeTable: =>

        if @$el.find('table').length > 1
            table = $(@$el.find('table')[0])
            table.remove()

        $(@$el.find('table')).removeClass "leftTweak"

        null

    cloneTable: =>

        table = $(@grid.$el.find('table')[0])
        clone = table.clone(true, true)

        @grid.$el.append clone
        clone.addClass 'leftTweak'
        
        @cleanFlash clone

        null

    checkColumn: =>

        if @lastCol != @colNo

            @lastCol = @colNo
            currentCol = @data.cols[ @colNo ]

            # Animate cell and play respective chord sound
            i = 0
            while i < currentCol.rows.length
                rowNo = currentCol.rows[i]
                @animateCell @colNo, rowNo
                @playCell @colNo, rowNo
                i++

            # PLAY LOOPS
            i = 0
            while i < @data.loops.length
                @playLoop @data.loops[i]
                i++
        
        null

    animateCell: (colNo, rowNo) ->

        # Animate cell flash
        if colNo < (@data.cols.length / 2) and @$el.find('table').length > 1
            table = @$el.find('table')[1]
        else
            table = @$el.find('table')[0]

        row = $(table).find('tr')[rowNo]
        cell = $(row).find('td')[colNo]

        $(cell).stop().addClass "flash"

        $(cell).delay(400).queue () =>
            $(cell).removeClass "flash"
            $(cell).dequeue()


        null

    playCell: (col, row) =>

        #console.log "[ Play chord ]", col, row
        MusicBoxSequencer.playSound col, row

        null

    playLoop: ( data ) =>

        event = ""
        if @colNo == data.col
            event = data.event

        if event != ""
            #console.log "[ Play loop ]", data.col
            SoundController.send data.event

        null

    saveUserLoop: =>

        # Take the original loop and add the new chords that the user just created
        @data.cols = @exportSong('col').cols

        # Tell the SoundController that the user just made a new loop
        SoundController.userLoop = @data

        null

    onEnterFrame : =>

        return if !@playing

        # Move table along according to time
        timePercent = (@clock.getElapsedTime() * 100) / (@tempo * @data.dimensions.cols)
        progressWidth = (@grid.$el.width() * timePercent) /  100

        @grid.$el.css
            "margin-left" : - progressWidth / 2

        # Calculate the column in the center based on the position
        diff = (@cellWidth * (timePercent / 100).toFixed(1)).toFixed(1)
        nPw = progressWidth + (diff * 2)
        col = Math.floor( ( nPw * (@data.dimensions.cols-1) ) / @grid.$el.width())

        if col < (@data.dimensions.cols / 2)
            col = col + (@data.dimensions.cols / 2)
        else
            col = col - (@data.dimensions.cols / 2)

        @colNo = col

        # Check if this column has any selected row
        @checkColumn()

        # Need a new table
        margins = 6 # tweak gap
        if (Math.abs(parseInt(@grid.$el.css("margin-left"))) * 2) + margins >= @grid.$el.width()
            @removeTable()
            @grid.$el.css
                "margin-left" : 0
            @cloneTable()
            @resetTimer()

        null

    exportSong: (orderBy) =>

        if !orderBy
            orderBy = 'row'

        # export simple song array from DOM
        table = $(@$el.find('table'))
        
        if orderBy == 'row'
            songExport = { 'rows' : [] }
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

    addChord: (col, row) =>

        # Add the highlight to both tables
        tables = @$el.find 'table'
        $(tables[0]).find("##{col}-#{row}").addClass "on"
        $(tables[1]).find("##{col}-#{row}").addClass "on"

        @data.cols[col].rows.push parseInt(row)

        null

    removeChord: (col, row) =>

        tables = @$el.find 'table'
        $(tables[0]).find("##{col}-#{row}").removeClass "on"
        $(tables[1]).find("##{col}-#{row}").removeClass "on"

        index = @data.cols[col].rows.indexOf row
        @data.cols[col].rows.splice index, 1

        null

    cleanFlash: (table) =>

        table.children().children().children().removeClass "flash"

        null

    checkCell: (table, rowNum, colNum) =>

        row = $(table.find('tr')[rowNum])
        cell = $(row.find('td')[colNum])

        if cell
            if cell.hasClass 'on'
                true
            else
                false
        else
            throw "Error exporting song: couldn't find specified cell."

    dispose: => 
        null

