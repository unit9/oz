class SoundController

    # Links to files, we will host them during development, and then send them over for you to deploy.
    @xmlLink : null 
    @mp3link : null
    @swfLink : null

    @loaded: false
    @progress: 0
    @holding: []
    @userPaused : false

    @userLoop : null
    @userLoopLonger : null

    @active : false
    @onBatchComplete : null
    batchLoaded : false

    @init:(remote) =>
        
        if remote

            @xmlLink = "http://soundcontroller.se/unit9/oz/config.xml"
            @mp3link = "http://soundcontroller.se/unit9/oz/mp3s/"
            @swfLink = "http://soundcontroller.se/unit9/oz/"
            require(["http://soundcontroller.se/unit9/oz/scsound.js"],@onLibLoaded)

        else

            @xmlLink = "/sounds/config.xml"
            @mp3link = "/sounds/"
            @swfLink = "/sounds/"
            require(["/js/vendor/scsound.js"],@onLibLoaded)

            # $.getScript 'http://soundcontroller.se/unit9/oz/scsound.js',
            #     (data)=>
            #         console.log data

        # Initialize sound engine.
        # Links to xml, mp3s and swfs (if flash fallback, which is not implemented yet).
        # Callback function when ready and progress update

    @onLibLoaded:=>
        if @active
            SCSound.initialize @xmlLink, @mp3link, @swfLink, @onloadcomplete, @onloadprogress, @onbatchloaded
        else
            @progress = 100        

    @onloadprogress: (percent) =>

        @progress = Math.round percent.toFixed(2) * 100

    @onloadcomplete: =>

        @loaded = true

        SoundController.send 'landing_start'

        # if @holding.length > 0
        #     for i in [0...@holding.length]
        #         SCSound.send @holding[i]

    @onbatchloaded:=>
        
        if @onBatchComplete?

            if typeof @onBatchComplete != "string"
                @send( @onBatchComplete[0] )
                @onBatchComplete = @onBatchComplete[1]
            else
                @send( @onBatchComplete )
                
                if @onBatchComplete != "musicbox_shared"
                    @playBackgroundMusic()
                else
                    @batchLoaded = true

                @onBatchComplete = null


    @send: (id,onBatchComplete) =>
        
        if onBatchComplete?
            @onBatchComplete = onBatchComplete

        # console.log "[SoundController] Send #{id}"
        if @active
            if @loaded
                # console.log "[Plan8 Sound Event] SCSound.send('#{id}')"
                SCSound.send id
            else
                @holding.push id

    @paused : ( user ) =>
        return if @userPaused
        @userPaused = user
        @send "sound_off"

    @resume : (user = false) =>
        if user
            @userPaused = false
            @send "sound_on"
            return

        return if @userPaused
        @userPaused = false
        @send "sound_on"

    @oz : =>

        return (window || document).oz

    # --------------------------------------------------------
    #
    #   Music box sequencer
    #
    # --------------------------------------------------------

    @playBackgroundMusic : =>

        if @userLoop
            MusicBoxSequencer.initialize @userLoopLonger
        else
            MusicBoxSequencer.initialize JSON.parse(@oz().baseAssets.get('loopbg').result)

    @preview: (data) =>

        MusicBoxSequencer.initialize data

    @stopBackgroundMusic : =>

        MusicBoxSequencer.stop();

    @transition : (playing, column) =>

        base = JSON.parse(@oz().baseAssets.get('loopbg').result)
        user = @userLoop

        # console.log base
        # console.log user

        cols = []
        for i in [0...base.dimensions.cols]
            cols[i] = {"rows" : []}

        for i in [0...user.cols.length]

            currentCol = user.cols[i]
            j = 0

            col = if i < 12 then i + (user.dimensions.cols / 2) else i - (user.dimensions.cols / 2)

            rows = []
            while j < currentCol.rows.length

                row = currentCol.rows[j]
                j++
                
                # console.log "-"
                # console.log col, row
                # console.log col + (base.dimensions.cols / 2), row
                # console.log ""

                rows.push row

            cols[col + (base.dimensions.cols / 2)] = {"rows" : rows}

        base.cols = cols

        MusicBoxSequencer.transitionTo playing, column, base
