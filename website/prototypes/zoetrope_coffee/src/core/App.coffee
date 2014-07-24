class App

    # Camera feed
    camera : ""

    # Current canvas to draw the picture from the video
    currentPicture : 0

    # Number of pictures needed to make the Zoetrope
    numberOfPictures : 24

    # Interval between shots in miliseconds
    pictureInterval : 250

    # Timer interval to take shots
    shooter : ""

    # Canvas where is created the spritesheet
    canvas : ""

    # Current filter style effect
    style : ""

# -----------------------------------------------------
# Initiate the application
# -----------------------------------------------------

    constructor: ->

        console.log "* Init App"

        # Hide Zoetrope
        $(".wrapper").fadeOut 0

        # Camera input
        @camera = new Cam
        addEventListener "webcamLoaded", @enableNavigation

# -----------------------------------------------------
# Navigation Handler
# -----------------------------------------------------

    enableNavigation: =>

        # Change filter when click on the webcam feed
        $(@camera.video).click @camera.changeFilter

        # Make zoetrope
        @enableButton "#btTakePic", @makezoetrope

        # Disable the preview
        @disableButton "#btPreview"

        # Disable PDF
        @disableButton "#btPrintPdf"

        # Disable Stripe
        @disableButton "#btGoStripe"        

    disableButton: (bt) =>

        $(bt).css {cursor: "default"}
        $(bt).stop().animate {"background-color": "#222", color: "#353535"}, 250

        $(bt).unbind "click"
        $(bt).unbind "mouseover"
        $(bt).unbind "mouseout"

    enableButton: (bt, action) =>

        $(bt).css {cursor: "pointer"}
        $(bt).stop().animate {"background-color": "#34ca85", color: "#FFF"}, 250

        $(bt).mouseover ->
            $(this).stop().animate {"background-color": "#59997b", color: "#FFF"}, 250

        $(bt).mouseout ->
            $(this).stop().animate {"background-color": "#34ca85", color: "#FFF"}, 250

        $(bt).click action

# -----------------------------------------------------
# Zoetrope builder
# -----------------------------------------------------

    makezoetrope: =>
        
        # Disable change filter when click on the webcam feed
        $(@camera.video).unbind "click"

        # Disable make zoetrope button
        @disableButton "#btTakePic"

        # Add the canvas
        @addCanvas()

        # Start the sequence shooter
        @shooter = setInterval @takePicture, @pictureInterval

    takePicture: =>

        if @currentPicture >= @numberOfPictures
            @picturesTaken()
        else
            @camera.snapshot @canvas, @currentPicture * 100
            @currentPicture++

            # Scroll the slider to the right to always show the last frame
            if @currentPicture * 100 > $(".photo").width()
                $(".photo").stop().animate {scrollLeft: ( @currentPicture * 100 ) - $(".photo").width() }, 500

    addCanvas: =>

        # Current effect of the webcam
        effect = @camera.filters[ @camera.currentFilter ]
    
        if effect != ""
            @style = effect

        # How large is the canvas and the container
        w = @numberOfPictures * 100

        $(".photoscontainer").append "<canvas id='spritesheet' width='#{w}' height='100' class='#{@style}'></canvas>"
        $(".photoscontainer").css { width: w }

        @canvas = document.getElementById "spritesheet"

    picturesTaken: =>

        # Clear the sequence shooter
        clearInterval @shooter

        # Enable the preview
        @enableButton "#btPreview", @previewZoetrope

    previewZoetrope: =>

        # Enable PDF Print
        @enableButton "#btPrintPdf", @print

        # Enable Go Stripe
        @enableButton "#btGoStripe", @goStripe

        # Disable Preview Button
        @disableButton "#btPreview"

        # Hide webcam feed
        $(".videosource").animate {left: - $(".videosource").width() }, { duration: 500, easing: "easeOutCubic", complete: @camera.stop }

        # Hide photos footer
        $(".container").animate {bottom: - $(".container").height() + 39 }, { duration: 500, easing: "easeOutCubic" }

        # Show zoetrope and start the rotation
        $('.wrapper').fadeIn 100
        $(".frames").addClass "framesMoving"

        # Create the spritesheet
        $(".zoetrope.horse .frames > div").css {"background-image": "url(#{ this.canvas.toDataURL("image/jpeg") })"}

        # Zoetrope zoom mouse controller
        zoetroper = new Zoetrope

    goStripe: =>

        # Grab the image strip as a jpeg encoded in base64, but only the data
        strip = this.canvas.toDataURL("image/jpeg")

        # Open the window to show the pdf
        w = window.open strip

    print: =>

        # Grab the image strip as a jpeg encoded in base64, but only the data
        strip = this.canvas.toDataURL("image/jpeg").slice 'data:image/jpeg;base64,'.length

        # Convert the data to binary form
        strip = atob strip

        # Open the window to show the pdf
        w = window.open ""

        # Load the zoetrope template jpg

        # Because of security restrictions, getImageFromUrl will
        # not load images from other domains.  Chrome has added
        # security restrictions that prevent it from loading images
        # when running local files.  Run with: chromium --allow-file-access-from-files --allow-file-access
        # to temporarily get around this issue.

        getImageFromUrl = (url, callback) ->

            img = new Image
            data = null
            ret = {data: null, pending: true}

            img.onError = ->

                throw new Error "Cannot load image: #{url}" 

            img.onload = ->

                canvas = document.createElement "canvas"

                document.body.appendChild canvas
                canvas.width = img.width
                canvas.height = img.height

                ctx = canvas.getContext "2d"
                ctx.drawImage img, 0, 0

                # Grab the image as a jpeg encoded in base64, but only the data
                data = canvas.toDataURL("image/jpeg").slice "data:image/jpeg;base64,".length

                # Convert the data to binary form
                data = atob data
                document.body.removeChild canvas

                ret["data"] = data
                ret["pending"] = false

                if typeof callback is "function"
                    callback data
            
            img.src = url

            ret

        # Since images are loaded asyncronously, we must wait to create
        # the pdf until we actually have the image data.
        # If we already had the jpeg image binary data loaded into
        # a string, we create the pdf without delay.

        createPDF = (imgData) ->

            doc = new jsPDF "landscape"
            
            doc.addImage imgData, "JPEG", 0, 0, 297, 210
            doc.addImage strip, "JPEG", 5, 5, (2400 * 4.5) * 2.54 / 96, (100 * 4.5) * 2.54 / 96
            
            # Output as Data URI
            url = doc.output "dataurlstring"

            w.location = url

        getImageFromUrl "img/zoetrope_template_01.jpg", createPDF