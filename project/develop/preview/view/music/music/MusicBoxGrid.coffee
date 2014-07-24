class MusicBoxGrid extends Abstract
    
    animating   : false
    template    : 
        "
        <div class='music-grid-table'> 
            <table>

            </table>
        </div>
        "

    table       : null
    data        : null

    init: =>

        @table = @$el.find("table")

    buildTable: (data) =>

        @data = data

        # Call the cells and cols
        content = $("<tbody></tbody>")

        for i in [0...@data.dimensions.lines]

            row = $("<tr></tr>")

            for j in [0...@data.dimensions.cols]

                col = $("<td data-note='#{i}'></td>")
                row.append col

                if $.inArray(i, @data.cols[j].rows) > -1
                    @activateCell col

            content.append row

        @table.append content

        @render()

    events:
        "click td"      : "cellClick"
        "mouseenter td" : "cellHoverOn"
        "mouseleave td" : "cellHoverOff"

    playing: (bool) =>

        if bool == true
            @animating = true
        else if bool == false
            @animating = false

    cellClick: (e) =>

        @activateCell $(e.currentTarget)

    activateCell: (el) =>

        el.toggleClass "on"

    cellHoverOn: (e) =>

        if @animating == false

            $(e.currentTarget).prepend( @newTooltip @data.notes[(@data.dimensions.lines-1) - $(e.currentTarget).attr("data-note")].label )
            toolTip = $(e.currentTarget).find '.music-note-tooltip'
            
            toolTip.css { "margin-top" : "#{ - 44 }px", "margin-left" : "#{ ($(e.currentTarget).width() / 2) - 20 }px" }

            toolTip.fadeIn(300)

    cellHoverOff: (e) =>

        if @animating == false
            toolTip = $(e.currentTarget).find '.music-note-tooltip'
            toolTip.fadeOut(300).remove()

    newTooltip: (string) =>

        '<div class="music-note-tooltip">' +  string + '</div>'