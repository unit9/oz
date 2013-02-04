class Logger
	constructor: ( id ) ->
		@el = document.getElementById(id);

	log: ( msg ) ->
		fragment = document.createDocumentFragment()
		fragment.appendChild document.createTextNode msg
		fragment.appendChild document.createElement 'br'
		@el.appendChild fragment 

	clear: () ->
		@el.text('')
	
