namespace "amf"
	AMF:
		class AMF
			@aliases = {}
			
			@registerClassAlias: (fullClassPath,classAlias) ->
				@aliases[fullClassPath] = classAlias;
			
			@getClassForAlias: (fullClassPath) ->
				@aliases[fullClassPath]
