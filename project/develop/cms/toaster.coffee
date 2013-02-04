# => SRC FOLDER
toast 'src'

    # EXCLUDED FOLDERS (optional)
    exclude: [ '.DS_Store', '.svn' ]

    # => VENDORS (optional)
    vendors: [  '../../../website/js/vendor/dat.gui.min.js',
                '../../../website/js/vendor/jquery-1.8.3.min.js',
                '../../../website/js/vendor/jquery.color-2.1.0.min.js',
                '../../../website/js/vendor/jquery.easing.1.3.js',
                '../../../website/js/vendor/jquery.form.js',
                '../../../website/js/vendor/modernizr-2.6.2.min.js',
                '../../../website/js/vendor/underscore-1.3.3.min.js',
                '../../../website/js/vendor/backbone-0.9.2.min.js',
                '../../../website/js/vendor/preloadjs-0.2.0.min.js'
                ]

    # => OPTIONS (optional, default values listed)
    bare: true
    packaging: false
    minify: false

    # => HTTPFOLDER (optional), RELEASE / DEBUG (required)
    httpfolder: 'js'
    release: '../gae/templates/cms/js/app.js'
    debug: '../gae/templates/cms/js/app-debug.js'