namespace "ifl"
	IFLSubMesh:
		class IFLSubMesh
			readExternal:(input)->
				IFLParser.readExternal(this,input)