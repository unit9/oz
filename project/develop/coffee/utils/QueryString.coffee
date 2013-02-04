class QueryString

    @get : (name) =>

    	if name

	        name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
	        regexS = "[\\?&]" + name + "=([^&#]*)"
	        regex = new RegExp regexS

	        results = regex.exec window.location.search

	        if results == null
	            ""
	        else
	            return decodeURIComponent results[1].replace(/\+/g, " ")
	     else
	     	""