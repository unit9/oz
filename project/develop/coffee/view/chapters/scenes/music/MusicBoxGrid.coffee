class MusicBoxGrid extends Abstract
    
    template    : "musicbox-grid"
    table       : null
    data        : null

    init: =>

        @table = @$el.find("table")

        null

    buildTable: (data) =>

        @data = data

        # Call the cells and cols
        content = $("<tbody></tbody>")

        for i in [0...@data.dimensions.lines]

            row = $("<tr></tr>")

            for j in [0...@data.dimensions.cols]

                col = $("<td data-note='#{i}' data-col='#{j}' id='#{j}-#{i}'></td>")
                row.append col

                if $.inArray(i, @data.cols[j].rows) > -1
                    @activateCell col

            content.append row

        @table.append content

        @render()

        null

    events:

        "click td" : "cellClick"

    cellClick: (e) =>

        # Analytics
        Analytics.track 'music_click_note'

        @activateCell $(e.currentTarget)

        # If the music is playing
        if @oz().appView.subArea.table.playing

            # Add / Remove the chord to the loop
            if $(e.currentTarget).hasClass "on"
                @oz().appView.subArea.table.addChord $(e.currentTarget).attr("data-col"), $(e.currentTarget).attr("data-note")
            else
                @oz().appView.subArea.table.removeChord $(e.currentTarget).attr("data-col"), $(e.currentTarget).attr("data-note")

        null

    activateCell: (el) =>
        
        el.toggleClass "on"

        null