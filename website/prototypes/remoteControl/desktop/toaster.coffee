# => SRC FOLDER
toast 

    folders:
        "../service"        : "service"
        "src"               : "app"

    exclude: ['src/.svn', '../service/.svn', 'src/view/.svn', "..service/event/.svn" ]

    # => VENDORS (optional)
    vendors: ['../vendors/jquery-1.8.2.min.js', '../vendors/underscore-1.3.3.min.js', '../vendors/backbone-0.9.2.min.js']

    # => OPTIONS (optional, default values listed)
    bare: false
    packaging: false
    minify: false

    # => HTTPFOLDER (optional), RELEASE / DEBUG (required)
    httpfolder: 'js'
    release: 'bin/js/app.js'
    debug: 'bin/js/app-debug.js'