namespace "ifl"
	IFLNode:
		class IFLNode
			readExternal:(input)->
				IFLParser.readExternal(this,input)