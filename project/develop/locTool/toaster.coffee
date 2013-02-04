# => SRC FOLDER
toast 'src'

    # EXCLUDED FOLDERS (optional)
    exclude: ['src/.svn', 'src/view/.svn']

    vendors: ['../../../website/prototypes/defaults/vendors/jquery-1.8.2.min.js', '../../../website/prototypes/defaults/vendors/jquery.transit.min.js', '../../../website/prototypes/defaults/vendors/underscore-1.3.3.min.js', '../../../website/prototypes/defaults/vendors/backbone-0.9.2.min.js']

    # => OPTIONS (optional, default values listed)
    bare: true
    packaging: false
    minify: false

    # => HTTPFOLDER (optional), RELEASE / DEBUG (required)
    httpfolder: '../../../website/locTool/js/app.js'
    release: '../../../website/locTool/js/app.js'
    debug: '../../../website/locTool/js/app-debug.js'