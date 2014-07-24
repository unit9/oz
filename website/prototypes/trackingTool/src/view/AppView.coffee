class AppView extends Backbone.View

    tagName : "body"
    input   : null

    initialize : =>

        $('#convert').click ->
            s = $('#raw').val().split("Y pixels")[1].split("Motion")[0]
            s = $.trim s
            list = s.split("\n")
            result = []

            for a in list
                a = $.trim a
                a = a.replace /\t/, " "
                a = a.replace /(    )/, " "
                a = a.replace /(   )/, " "
                a = a.replace /(  )/, " "
                a = a.split("\t").join(' ')

                a = a.split(" ")

                result.push
                    frame : $.trim a[0]
                    x     : $.trim a[1]
                    y     : $.trim a[2]

            $('#converted').html JSON.stringify result

