$ ->

    console.log 'here'

    onCompleteLoad = (event) =>
        view = new View 
        view.parse event.responseText

    $.ajax
        url : '../locale/en/strings.txt'
        dataType : 'text'
        complete : onCompleteLoad
