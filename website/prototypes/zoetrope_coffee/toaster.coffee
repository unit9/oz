# => SRC FOLDER
toast 'src'

    # EXCLUDED FOLDERS (optional)
    exclude: [ '.DS_Store', 'src/.svn', 'src/views/.svn', 'src/core/.svn', '.svn' ]

    # => VENDORS (optional)
    vendors: [  'vendors/dat.gui.js',
                'vendors/jquery-1.8.0.min.js',
                'vendors/jquery.color-2.1.0.min.js',
                'vendors/jquery.easing.1.3.js',
                'vendors/jquery.transit.min.js',
                'vendors/jspdf.js',
                'vendors/jspdf.plugin.addimage.js',
                'vendors/jspdf.plugin.from_html.js',
                'vendors/jspdf.plugin.split_text_to_size.js',
                'vendors/jspdf.plugin.standard_fonts_metrics.js',
                'vendors/modernizr-2.6.1.min.js',
                'vendors/underscore-1.3.3.min.js',
                'vendors/backbone-0.9.2.min.js'
                ]

    # => OPTIONS (optional, default values listed)
    bare: true
    packaging: false
    # minify: false

    # => HTTPFOLDER (optional), RELEASE / DEBUG (required)
    httpfolder: ''
    release: 'www/js/app.js'
    debug: 'www/js/app-debug.js'