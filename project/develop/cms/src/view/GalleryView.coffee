class GalleryView extends Backbone.View

    THUMB_WIDTH         : 300
    TOTAL_WIDTH         : 300 * 12

    el                  : $(".wrapper")

    pagination          : null
    gallery             : null

    spritesheetPlayer   : null
    transitionTime      : 100
    currentX            : 0

    kind                : "cutout"
    
    initialize: ( type ) =>

        @kind = type

        if @kind == "cutoutDesktop"
            @kind = 'cutout'

        @render()

        @requestData()

    render: =>

        $(@el).append view.oz.templates.get "gallery"

        # Add pagination controls
        @pagination = new PaginationView
        @pagination.on "change", @changePage
        @pagination.on "search", @search

    changePage: ( direction ) =>

        @requestData "/api/moderation/queue/#{@kind}?#{direction}=#{$("##{direction}").data "id"}"

    search: ( id ) =>

        request = $.ajax {

            url     : "/api/image/info/#{id}"
            type    : "GET",
            data    : null,
            dataType: "json"

        }

        request.done @searchResult

        request.fail (jqXHR, status) ->
            console.log jqXHR, status

# -----------------------------------------------------
# Data management
# -----------------------------------------------------

    requestData: ( url ) =>

        # Default url request
        if !url
            url = "/api/moderation/queue/#{@kind}"

        request = $.ajax {

            url     : url
            type    : "GET",
            data    : null,
            dataType: "json"

        }

        request.done @parseData

        request.fail (jqXHR, status) ->
            console.log jqXHR, status

    parseData: ( result ) =>

        result = result.result

        unless result?
            return

        # console.log result

        # Handle arrows
        @updatePaginationNav result.prev, result.next
        
        # Create one Collection with the data
        @gallery = new CollectionGallery result.images

        # Add thumbs to the DOM
        @addThumbs()

    searchResult: ( result ) =>

        if result.error
            @pagination.inputInvalid true
        else

            r = {
                result:
                    {
                        images: [ result.result ],
                        next: -1
                        prev: -1
                    }
            }

            @parseData r

# -----------------------------------------------------
# DOM management
# -----------------------------------------------------

    addThumbs: =>
        
        $(".gallery .content").empty()

        for index, value of @gallery.models

            # Add correct links to be parsed to the template           
            value.urlReject = _globals.ROOT + "reject/#{value.attributes.id}"
            value.uploaded_date = value.attributes.date
            value.reviewed_date = value.attributes.date_approved

            # Add the template to the DOM
            thumb = _.template view.oz.templates.get "thumb"

            $(".gallery .content").prepend thumb value

            # Add 'new' css class if it's new
            if !value.attributes.viewed
                $("##{value.attributes.id}").addClass "new"

            # Setup thumb with the features
            @setupThumb value.attributes

    setupThumb: ( data ) =>

        # Hide loading
        @loadingIsVisible data.id, false, true

        # Hide and setup confirmation
        @confirmationIsVisible data.id, false, true
        @setupConfirmation data.id

        # Hide rejected overlay
        @rejectedIsVisible data.id, false, true

        # Add action to REJECT button
        @setupRejectButton data.id

        # Add 'rejected' css class if it's rejected
        if !data.approved
            @setAsRejected data.id

        # Add image
        @addSpritesheet data

        if @kind.toLowerCase().indexOf('cutout') > -1
            console.log $("##{data.id}")
            $("##{data.id}").addClass 'cutout_div'
            $("##{data.id}").children('.image').addClass 'cutout_image'

    setAsRejected: ( id ) =>

        # Hide loading
        @loadingIsVisible id, false

        # Remove 'new' css class
        $("##{id}").removeClass "new"

        # Add 'rejected' css class
        $("##{id}").addClass "rejected"

        # Disable the reject button
        $("##{id}").children(".tools").children("ul").children("li").children("#reject").addClass "rejected"
        $("##{id}").children(".tools").children("ul").children("li").children("#reject").children("span").html "REJECTED"

        # Show rejected overlay
        @rejectedIsVisible id, true

    updatePaginationNav: (back, next) =>

        @pagination.enabled "prev", back != -1
        @pagination.enabled "next", next != -1

        @pagination.set "next", next
        @pagination.set "prev", back

# -----------------------------------------------------
# Spritesheet
# -----------------------------------------------------

    addSpritesheet: ( data ) =>

        image = $("##{data.id}").children(".image")

        image.css { "background-image" : "url('#{data.uri}')" }

        if @kind == "zoetrope"
            
            image.mouseover ( event ) =>
                @playSpritesheet data, event

            image.mouseout ( event ) =>
                @stopSpritesheet data, event

    nextFrame: ( data ) =>

        console.log @currentX

        @currentX -= @THUMB_WIDTH
        if @currentX <= -(@TOTAL_WIDTH)
            @currentX = 0

        image = $("##{data.id}").children(".image")
        image.css { "background-position-x" : "#{@currentX}px" }

    playSpritesheet: ( data, event ) =>

        image = $("##{data.id}").children(".image")

        @spritesheetPlayer = setInterval (=> @nextFrame data), @transitionTime

    stopSpritesheet: ( data, event ) =>
        
        image = $("##{data.id}").children(".image")

        clearInterval @spritesheetPlayer
        image.css { "background-position-x" : "0px" }


# -----------------------------------------------------
# Loading overlay
# -----------------------------------------------------

    loadingIsVisible: ( id, visible, fast = false ) =>

        loader = $("##{id}").children(".loaderContainer")
        time = if !fast then 150 else 0

        if visible
            loader.fadeIn time
        else
            loader.fadeOut time

# -----------------------------------------------------
# Confirmation overlay
# -----------------------------------------------------

    confirmationIsVisible: ( id, visible, fast = false ) =>

        confirmation = $("##{id}").children(".confirmation")
        time = if !fast then 150 else 0

        if visible
            confirmation.fadeIn time
        else
            confirmation.fadeOut time

    setupConfirmation: ( id ) =>

        confirmation = $("##{id}").children(".confirmation")

        buttonYes = confirmation.children(".buttons").children(".yes")
        buttonNo = confirmation.children(".buttons").children(".no")

        $(buttonYes).click ( event ) =>

            event.preventDefault()
            @confirm id

        $(buttonNo).click ( event ) =>

            event.preventDefault()
            @cancel id

    confirm: ( id ) =>

        @confirmationIsVisible id, false
        @loadingIsVisible id, true

        r = $.ajax {
                type: "PUT",
                url: "/api/image/reject/#{id}",
                data: null,
                dataType: "json"
            }

        r.done (result) =>
            if result.result.id
                @setAsRejected result.result.id

        r.error (result) =>

            console.log result

    cancel: ( id ) =>

        @confirmationIsVisible id, false

# -----------------------------------------------------
# Rejected overlay
# -----------------------------------------------------

    rejectedIsVisible: ( id, visible, fast = false ) =>

        rejected = $("##{id}").children(".rejected")
        time = if !fast then 150 else 0

        if visible
            rejected.fadeIn time
        else
            rejected.fadeOut time

# -----------------------------------------------------
# Reject button
# -----------------------------------------------------

    setupRejectButton: ( id ) =>

        button = $("##{id}").children(".tools").children("ul").children("li").children("#reject")
        
        $(button).click ( event ) =>

            event.preventDefault()
            if !button.hasClass "rejected"
                @confirmationIsVisible id, true

    


