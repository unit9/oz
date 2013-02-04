namespace "ifl"
	IFLIndexBuffer:
		class IFLIndexBuffer
			readExternal:(input)->
				IFLParser.readExternal(this,input)