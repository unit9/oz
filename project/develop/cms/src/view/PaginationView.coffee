class PaginationView extends Backbone.View

    initialize: =>
        
        @render()

    render: =>

        $(".gallery").prepend view.oz.templates.get "pagination"

        # Enable search
        $("#search").click @search
        $("#searchID").focus @onInputFocus
        $("#searchID").blur @onLoseFocus

# -----------------------------------------------------
# Previous / Next management
# -----------------------------------------------------

    enabled: ( button, enabled ) =>

        if enabled

            $("##{button}").addClass "active"
            $("##{button}").removeClass "inactive"

            $("##{button}").off "click"
            $("##{button}").on "click", @change

        else

            $("##{button}").removeClass "active"
            $("##{button}").addClass "inactive"
            $("##{button}").off "click"

    set: ( button, id ) =>

        $("##{button}").data "id", id

    change: ( event )=>

        @trigger "change", event.currentTarget.id

# -----------------------------------------------------
# Search
# -----------------------------------------------------

    onInputFocus: ( event ) =>

        $("#searchID").removeClass "error"

        searchTerm = $("#searchID").val()

        if searchTerm == "SEARCH BY ID"
            $("#searchID").css {"font-family": "Arial", "color": "#666"}
            $("#searchID").val ""

    onLoseFocus: ( event ) =>

        searchTerm = $("#searchID").val()

        if searchTerm == ""
            $("#searchID").css {"font-family": "Terminal Dosis", "color": "#444"}
            $("#searchID").val "SEARCH BY ID"

    search: ( event ) =>

        searchTerm = $("#searchID").val()
        
        if searchTerm != "SEARCH BY ID"
            @trigger "search", searchTerm
        else
            @trigger "change", ""

    inputInvalid: ( bool ) =>

        if bool
            $("#searchID").addClass "error"
        else
            $("#searchID").removeClass "error"