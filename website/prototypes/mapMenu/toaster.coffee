# => SRC FOLDER
toast 'src'

	# EXCLUDED FOLDERS (optional)
	exclude: ['.svn', 'src/.svn', 'src/mapMenu/.svn' ]

	# => VENDORS (optional)
	vendors: ['../defaults/vendors/jquery-1.8.2.min.js', '../defaults/vendors/underscore-1.3.3.min.js', '../defaults/vendors/backbone-0.9.2.min.js','vendors/requestAnimationFrame.js', 'vendors/easeljs-0.5.0.min.js', 'vendors/Tween.js']

	# => OPTIONS (optional, default values listed)
	# bare: false
	packaging: false
	# expose: ''
	minify: false

	# => HTTPFOLDER (optional), RELEASE / DEBUG (required)
	httpfolder: ''
	release: 'www/js/app.js'
	debug: 'www/js/app-debug.js'