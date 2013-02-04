namespace "ifl"
	IFLFolder:
		class IFLFolder
			readExternal:(input)->
				IFLParser.readExternal(this,input)