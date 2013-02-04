$ ->

    list = []

    $('#commandList li label').each (index, value) -> 
        list.push $(value).html()

    window.onSpeechChange = (event) =>

        word = event.results[0].utterance

        $('#result').html "You said: " + word

        success = false

        for a in list 
            console.log word, a
            if word.toLowerCase().indexOf(a.toLowerCase()) > -1
                success = true
                $('#result').css 
                    color : '#458B00'

                return

        $('#result').css 
            color : '#FF0000'