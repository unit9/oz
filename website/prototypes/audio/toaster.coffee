# => SRC FOLDER
toast 'src'

	# EXCLUDED FOLDERS (optional)
	exclude: ['src/.svn', 'src/view/.svn' ]

	# => VENDORS (optional)
	vendors: ['../defaults/vendors/jquery-1.8.2.min.js', '../defaults/vendors/underscore-1.3.3.min.js', '../defaults/vendors/backbone-0.9.2.min.js']

	# => OPTIONS (optional, default values listed)
	# bare: false
	packaging: false
	# expose: ''
	minify: false

	# => HTTPFOLDER (optional), RELEASE / DEBUG (required)
	httpfolder: ''
	release: 'bin/js/app.js'
	debug: 'bin/js/app-debug.js'