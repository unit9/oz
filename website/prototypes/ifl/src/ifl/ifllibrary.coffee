namespace "ifl"
	IFLLibrary:
		class IFLLibrary

			_content : null
			_contentByID : {}


			readExternal: (input) ->
				IFLParser.readFile(this,input)

