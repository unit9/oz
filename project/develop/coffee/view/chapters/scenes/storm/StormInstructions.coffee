class StormInstructions extends AbstractScene

    id              : "storm"
    videoElement    : null
    video           : null

    init : =>

        @render()

        @$el.bind "click", @hideMe

        @oz().appView.footer.mainMenu.hide true

        @hide()
        @show true

    hideMe: =>

        @$el.unbind 'click', @hideMe

        @hide true, =>
            @remove @instructions

            @oz().appView.wrapper.remove @subArea
            @oz().appView.wrapper.remove @containerSubArea
            @oz().appView.subArea = null
            @mouseEnabled false            

        @oz().appView.area.activate()

    render : =>

        @addLayout "instructions_balloon", "storm_intructions"
        super()

    dispose: =>

        @


    addLayout : (assetID, localeID) =>

        super assetID, localeID
        @instructions.show true