FILE = "./video.webm"
NUM_CHUNKS = 5
video = $("video")[0]
chunkSize = null
file = null
sourceBuffer = null
asynCall = true

window.MediaSource = window.MediaSource || window.WebKitMediaSource
if (!!!window.MediaSource) then alert("MediaSource API is not available")
window.mediaSource = new MediaSource()

$("[data-num-chunks]").text( NUM_CHUNKS )

video.src = window.URL.createObjectURL( mediaSource )

mediaSource.addEventListener "webkitsourceopen", (e) ->
    sourceBuffer = mediaSource.addSourceBuffer 'video/webm; codecs="vorbis,vp8"'
    logger.log "mediaSource readyState : #{this.readyState}"

    GET FILE, ( uInt8Array ) ->
        file = new Blob [uInt8Array], {type: "video/webm"}
        chunkSize = Math.ceil(file.size / NUM_CHUNKS)

        logger.log "num chunks: #{NUM_CHUNKS}"
        logger.log "chunkSize: #{chunkSize}, totalSize: #{file.size}"

        # Slice the video into NUM_CHUNKS and append each to the media element.
        i = 0

        readChunk_ i
        null

    , false

mediaSource.addEventListener "webkitsourceended", ( e ) ->
    logger.log "mediaSource readyState: #{this.readyState}"

    , false


readChunk_ = (i) =>
    reader = new FileReader()
    reader.onload = (e) =>
        
        sourceBuffer.append(new Uint8Array(e.target.result))
        logger.log('appending chunk:' + i)

        if (i == NUM_CHUNKS - 1)
            mediaSource.endOfStream()
        else 
            video.play() if (video.paused)
            readChunk_ ++i
        
    startByte = chunkSize * i
    chunk = file.slice(startByte, startByte + chunkSize)
    reader.readAsArrayBuffer(chunk)

GET = ( url, callback ) ->
    xhr = new XMLHttpRequest()
    xhr.open "GET", url, asynCall
    xhr.responseType = "arraybuffer"
    xhr.send()

    xhr.onload = ( e ) ->
        if xhr.status != 200
            console.log url
            alert "Unexpected status code #{xhr.status} for #{url}"
            return false
        callback new Uint8Array xhr.response

logger = new Logger("log")

