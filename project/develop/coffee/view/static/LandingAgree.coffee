class LandingAgree extends BaseLandingOpenings

    checkBox : null
    mpaa : null
    buttonContainer : null
    buttonEnter : null

    init: =>
        super()

        @hide()

        @mouseEnabled true

        ### Header ###

        header = new Abstract
        header.dispose = () => return
        header.$el.addClass 'bigDividers'

        ### Dividers ###

        topEnding = new SSAsset 'interface', 'final_end_top'

        bottom = $('<div class="containerBottom" />')
        bigDividerBottom = new SSAsset 'interface', 'bottomheader'
        bigDividerBottom.$el.css {display: 'table-cell'}
        bottom.append bigDividerBottom.$el

        header.addChild topEnding

        @titles.$el.find('.openingTitlesHeader').css {'margin-top' : '0'}

        ###bigDividerRight = new SSAsset 'interface', 'divider_large_left'
        bigDividerLeft = new SSAsset 'interface', 'divider_large_right'
        landing_top = new SSAsset 'interface', 'landing_top'
        landing_top.$el.css
            'margin' : '-10px auto'###


        bottom = $('<div class="containerBottom" />')
        bigDividerBottom = new SSAsset 'interface', 'landing_bottom'
        bigDividerBottom.$el.css {display: 'table-cell'}
        bottom.append bigDividerBottom.$el

        # ### Heading ###

        # heading = new Abstract
        # heading.dispose = () => return
        # heading.$el.addClass 'heading'
        # heading.$el.append("<span>#{@oz().locale.get 'waltHeader'}</span>")

        # header.addChild bigDividerRight
        # header.addChild heading
        # header.addChild bigDividerLeft
        
        header.$el.insertAfter(@titles.$el.children()[0])

        # add bottom divider
        @titles.header.append bottom
        @titles.fluorish.$el.remove()

        bottom.width(bigDividerBottom.$el.width())
        bottom.height(bigDividerBottom.$el.height())

        ### Check Box ###

        @checkBox = new CheckBox()
        @checkBox.on 'toggled', @clickAgree

        @titles.cta.find('.cta').prepend @checkBox.$el
        @titles.cta.find('p').addClass 'pMargin'
        @titles.cta.find('p').find('a').attr('href', '/tou.html')
        @titles.cta.find('p').find('a').click (event) =>
            event.preventDefault()
            window.open '/tou.html'

        @titles.cta.find('p').bind 'click', @clickAgree

        @buttonContainer = new Abstract().setElement "<div class='enterButtonContainer'/>"
        @buttonContainer.dispose = () -> null

        @buttonEnter = new SimpleButton "enter", @oz().locale.get 'homeButton'

        @buttonContainer.addChild @titles.cta.find('.left')
        @buttonContainer.addChild @buttonEnter.$el
        @buttonContainer.addChild @titles.cta.find('.right')


        @titles.remove @titles.diamond
        @titles.addChild @buttonContainer
        # @titles.addChild @titles.diamond

        @enableEnterButton false

        #@titles.$el.prepend landing_top.$el

        @show true
        null

    enableEnterButton : (bool = true) =>
        if bool
            @buttonEnter.$el.css {cursor : 'pointer'}
            @buttonEnter.on 'click', @onEnterClick
            @buttonEnter.on 'mouseover', =>
                SoundController.send "btn_enter_over"

        else 
            @buttonEnter.$el.css {cursor : 'default'}
            @buttonEnter.off 'click', @onEnterClick
            @buttonEnter.off 'mouseover'

        null


    clickAgree : (event) =>
        if event
            return if event.srcElement.nodeName == "A"

        @checkBox.toggleCheck()

        @enableEnterButton @checkBox.val()
       
        @buttonContainer.$el.css 
            'opacity' : if @checkBox.val() == true then 1 else 0.2
            'pointer-events' : if @checkBox.val() == true then 'visible' else 'none'

        null


    onEnterClick : =>
        return if @checkBox.val() == false
        Analytics.track 'click_enter'
        SoundController.send 'landing_end'
        @trigger 'agreedEnter'
        null
