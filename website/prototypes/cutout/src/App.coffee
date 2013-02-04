$ ->

    window.URL = (window.URL || window.webkitURL)
    navigator.getUserMedia = (navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia)

    $(document).ready ->
        view = new CutoutView
        $('body').append view.$el