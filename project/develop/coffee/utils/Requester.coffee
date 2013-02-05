class Requester

    @requests : []

    @request: ( data ) =>

        r = $.ajax {

            url         : data.url
            type        : if data.type then data.type else "POST",
            data        : if data.data then data.data else null,
            dataType    : if data.dataType then data.dataType else "json",
            contentType : if data.contentType then data.contentType else "application/x-www-form-urlencoded; charset=UTF-8",
            processData : if data.processData != null and data.processData != undefined then data.processData else true

        }

        r.done data.done
        r.fail data.fail
        null

    @send: (url, params) =>

        formData = new FormData

        for key, value of params
            formData.append key, value

        xhr = new XMLHttpRequest
        
        xhr.open "POST", url, true

        xhr.onload = (e) =>
            console.log e

        xhr.send formData
        null

    @shortURL : ( url, done, fail ) =>

        #### USAGE: Requester.shortURL 'http://unit9.com', @end, @fail

        event = {result: {id : url}}

        done(event)

        return
        
        @request
            url         : "https://www.googleapis.com/urlshortener/v1/url",
            type        : "POST",
            data        : JSON.stringify({ "longUrl" : url }),
            done        : done,
            fail        : fail,
            dataType    : "json",
            contentType : "application/json"

        null

    @addImage : (data, kind, done, fail) =>

        ###
        Usage:
            data = canvass.toDataURL("image/jpeg").slice("data:image/jpeg;base64,".length)
            Requester.addImage data, "zoetrope", @done, @fail
        ###

        @request
            url    : '/api/image/add'
            type   : 'POST'
            data   : {image : encodeURI(data), kind : kind}
            done   : done
            fail   : fail

        null

    @addMusic : (data, done, fail) =>

        @request
            url    : '/api/music/'
            type   : 'POST'
            data   : { data : data }
            done   : done
            fail   : fail

        null

    @getMusic : (id, done, fail) =>

        @request
            url    : '/api/music/' + id
            type   : 'GET'
            data   : null
            done   : done
            fail   : fail

        null