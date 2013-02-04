# => SRC FOLDER
toast 'src'

	# EXCLUDED FOLDERS (optional)
	exclude: ['.svn' ]

	# => VENDORS (optional)
	vendors: ['../defaults/vendors/jquery-1.8.2.min.js', '../defaults/vendors/underscore-1.3.3.min.js', '../defaults/vendors/backbone-0.9.2.min.js']

	# => OPTIONS (optional, default values listed)
	# bare: false
	packaging: false
	# expose: ''
	minify: false

	# => HTTPFOLDER (optional), RELEASE / DEBUG (required)
	httpfolder: 'js'
	release: 'www/js/app.js'
	debug: 'www/js/app-debug.js'