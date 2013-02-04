class ManageLocale extends Backbone.View

    tagName : 'label'
    label   : null
    name    : null
    className : 'manageLocale'
    callBack : null        

    constructor : (callBack) ->
        @callBack = callBack
        super()

    initialize : =>

        @label = $('<span>Locale name: <input id="localeName" type="text"/>Locale code*: <input id="localeCode" type="text"/><span class="saveLocale">Save Locale</span></span><br>*Use hyphen to separate locale-specific code as in en-GB or en-US. <a href="https://developers.google.com/adsense/host/v3/developer/adsense_api_locales" target="_blank">Check the Locale Codes</a><br>')
        @$el.append @label

        @save = @$el.find('.saveLocale')
        @save.click @onSaveClick

    onSaveClick : (event) =>
        @callBack @$el.find('#localeName').val(), @$el.find('#localeCode').val()
        @$el.css {display: 'none'}