class LocaleView extends Backbone.View

    el            : $(".wrapper")
    data          : null
    buttonCreate  : null
    rows          : null
    translated    : null
    localesList   : null
    locales       : null
    container     : null
    english       : null
    saving        : false
    timer         : 0

    initialize: ( type ) =>
        @kind = type
        @kindAPI = @kind.split("locale")[1].toLowerCase()
        @render()


    timedSave : (event) =>
        clearTimeout @timer
        @timer = setTimeout @createTranslated, 2000

    render : =>
        $(@el).append view.oz.templates.get "locale"
        @container = $('.content')
        @containerContent = $('<div />')

        @requestLocales()

    requestLocales : =>
        @container.empty()

        $.ajax
            url : "/api/localisation/#{@kindAPI}/"
            success : (event) =>
                @createHeader event
                @requestData()
                @container.append @containerContent
        
    requestData : =>
        url = if @kindAPI == "desktop" then '/locale/en/strings.txt' else '/locale/en/mstrings.txt'
        $.ajax
            url : url
            dataType : 'text'
            complete : @onEnglishLoaded

    onEnglishLoaded : (event) =>
        @english = JSON.parse event.responseText
            
        @onCompleteLoad @english

        if @locales.length > 0
            @onSelectChange()


    createHeader : (event) =>

        @localesList = {
            'Add new locale' : 'addLocale',
            '--------------' : '-'
        }

        for i in event.result.locales
            @localesList[i.lang_name] = i.lang

        @locales = []

        selected = false

        for k,v of @localesList

            s = ""

            if selected == false

                if event.result.locales.length == 0 and v == "-"
                    s = "selected"
                    selected = true

                else if (v.toLowerCase() != '-' and v.toLowerCase() != 'addlocale')
                    s = "selected"
                    selected = true

            @locales.push "<option value='#{v}' #{s}>" + k + "</option>"


        @locales = $("<select class='localeSelect'>" + @locales.toString().split(",").join("") + "</select>")
        
        title = $('<span/>')
        title.append '<legend>1. Select locale</legend>'
        title.find('legend').append @locales

        @removeLocale = $("<img class='removeIcon' title='Remove Selected Locale' src='/cms/image/icon-delete.png'/>")        
        @removeLocale.click @removeLoc
        title.find('legend').append @removeLocale

        @manageLocale = new ManageLocale @addLocale
        title.append @manageLocale.$el

        @locales.change @onSelectChange

        @container.append title

        @upload = $('<span><legend>2. Upload a JSON format locale file <sup style="margin-left:5px;">(optional)</sup> <input class="uploadTextInput" type="file" /></legend></span>')
        @container.append @upload

        @uploadInput = $('.uploadTextInput')
        @uploadInput.change @onUploadFile
        
        @container.append '<legend>List of Strings</legend>'


    addLocale : (name, code)=>
        @locales.append "<option value=#{code.toLowerCase()} selected>#{name}</option>"


    removeLoc : (event) =>

        return if @locales.val() == "-"
        return if @locales.val() == "addLocale"

        if @locales.val().toLowerCase() == "en-us"
            alert('You cannot delete the English locale')
            return

        r = confirm("Are you sure you want to delete the selected locale?")

        if r == true
            $.ajax
                url : "/api/localisation/#{@kindAPI}/#{@locales.val().toLowerCase()}"
                type : "DELETE"
                success : @requestLocales

    onUploadFile : (event) =>
        r = new FileReader
        r.onload = (e) =>
            @uploadInput.val('')

            result = JSON.parse(e.target.result)

            if result.lang and result.strings
                @onCompleteLoad result
            else 
                a = {}
                a.lang = "upload"
                a.strings = {}
                for k, v of result
                    a.strings[k.split('_max_chars_')[0]] = v['message']

                @onCompleteLoad a
                

        r.readAsText event.srcElement.files[0]


    onCompleteLoad : (event) =>

        @containerContent.empty()

        @data = event or @english

        @rows = []

        for k, v of @english.strings
            row = new StringRow k, (@data.strings[k] or v), v, (!@data.strings[k] and @data.strings[k] != v)
            row.on 'change', @timedSave
            @rows.push row
            @containerContent.append row.$el

        @containerButton = $('<div class="buttonContainer" />')

        @buttonCreate = $('<span class="createLocalised">Create localised copy</span>')
        @buttonCreate.click @createTranslated

        @buttonDownload = $('<span class="createLocalised">Download Google format JSON</span>')
        @buttonDownload.click @downloadJson

        @buttonDownloadu9 = $('<span class="createLocalised">Download unit9 format JSON</span>')
        @buttonDownloadu9.click @downloadJsonu9

        @containerContent.append '<div style="height: 70px;">'

        @containerButton.append @buttonCreate
        @containerButton.append @buttonDownload
        @containerButton.append @buttonDownloadu9
        

        @$el.append @containerButton


    onSelectChange : (event) =>

        return if @locales.val() == "-"

        if @locales.val() == "addLocale"
            @manageLocale.$el.show()
            return

        @manageLocale.$el.hide()

        $.ajax 
            url      : "/api/localisation/#{@kindAPI}/" + @locales.val().toLowerCase()
            dataType : "json"
            success  : @onLangLoaded
            error    : @requestData

    onLangLoaded : (event) =>
        @onCompleteLoad event

    downloadJson : =>
        @translated = {}

        for i in @rows
            node = i.node()
            key = node[0]
            if node[0].indexOf("seo_") == -1 and node[0].indexOf("url") == -1
                key = (node[0] + "_max_chars_" + (node[1].length + (node[1].length * .25)).toFixed(0))
                
            @translated[key] = {"message" : node[1] }

        a = document.createElement('a')
        blob = new Blob([(JSON.stringify @translated)], {"type": "text\/json"})
        a.href = window.URL.createObjectURL blob
        a.download = "locale_" + $('.localeSelect').val().toLowerCase() + ".json"
        a.click()

    downloadJsonu9 : =>
        @translated = {}

        @translated.lang = $('.localeSelect').val().toLowerCase()
        @translated.strings = {}

        for i in @rows
            node = i.node()
            @translated.strings[node[0]] =  node[1]

        a = document.createElement('a')
        blob = new Blob([(JSON.stringify @translated)], {"type": "text\/json"})
        a.href = window.URL.createObjectURL blob
        a.download = "locale_" + $('.localeSelect').val().toLowerCase() + ".json"
        a.click()

    createTranslated : (event, download = false, unit9 = false) =>

        return if @locales.val() == "-" or @locales.val() == "addLocale" or @saving

        @translated = {}

        @translated.lang = $('.localeSelect').val().toLowerCase()
        @translated.strings = {}

        @saving = true

        @buttonCreate.html('<img src="/cms/image/ajax-loader.gif">')

        for i in @rows
            node = i.node()
            @translated.strings[node[0]] =  node[1]

        $.ajax
            url      : "/api/localisation/#{@kindAPI}/" + @translated.lang
            data     : "lang_name=#{$('.localeSelect').find(':selected').text()}&text=" + encodeURIComponent(JSON.stringify(@translated))
            type     : 'put'
            dataType : "json"
            success  : @onSuccess
            error    : @onError

    onSuccess : (event) =>
        @saving = false
        @buttonCreate.html('Create localised copy')

    onError : (event) =>
        @buttonCreate.html('Try again')
        setTimeout @revertButton, 2000






