namespace "ifl"
	IFLVertexBuffer:
		class IFLVertexBuffer
			readExternal:(input)->
				IFLParser.readExternal(this,input)