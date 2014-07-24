namespace "ifl"
	IFLMaterial:
		class IFLMaterial
			readExternal:(input)->
				IFLParser.readExternal(this,input)