# => SRC FOLDER
toast 'src'

    # EXCLUDED FOLDERS (optional)
    # exclude: ['folder/to/exclude', 'another/folder/to/exclude', ... ]

    exclude: ['src/.svn', 'src/view/.svn' ]

    vendors: ['../defaults/vendors/jquery-1.8.2.min.js', '../defaults/vendors/underscore-1.3.3.min.js', '../defaults/vendors/backbone-0.9.2.min.js']

    # => OPTIONS (optional, default values listed)
    bare: true
    packaging: false
    minify: false

    # => HTTPFOLDER (optional), RELEASE / DEBUG (required)
    httpfolder: 'js'
    release: 'bin/js/app.js'
    debug: 'bin/js/app-debug.js'