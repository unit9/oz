namespace "ifl"
	IFLJointBind:
		class IFLJointBind
			readExternal:(input)->
				IFLParser.readExternal(this,input)