namespace "ifl"
	IFLParser:
		class IFLParser

			@_loadedObjectTable	= null
			@_library			= null
			@_knownClasses		= {}
			@_knownInterfaces	= {}

			@METHOD_OBJECT		= "a"
			@METHOD_UTF			= "b"

			@METHOD_BOOLEAN		= "c"
			@METHOD_BYTE		= "d"
			@METHOD_DOUBLE		= "e"
			@METHOD_FLOAT		= "f"
			@METHOD_INT			= "g"
			@METHOD_SHORT		= "h"
			@METHOD_UINT		= "i"


			@_customMethodReadHandlers =
				a:"readObject"
				b:"readUTF"


			@_methodReadHandlers =
				c:"readBoolean"
				d:"readByte"
				e:"readDouble"
				f:"readFloat"
				g:"readInt"
				h:"readShort"
				i:"readUnsignedInt"




			@setKnownInterface: (fullClassPath,classType) ->
				IFLParser._knownInterfaces[fullClassPath] = classType;

			@setKnownClass: (fullClassPath,classType) ->
				# var desc:Array;
				# try
				# {
				# 	desc = classType["structureDescription"];
				# }
				# catch(err:ReferenceError)
				# {
				# 	throw new ArgumentError("Class "+fullClassPath+" does not have a static function structureDescription");
				# }
				# _runningObjectTable[fullClassPath] = desc;
				AMF.registerClassAlias(fullClassPath,classType);
				IFLParser._knownClasses[fullClassPath] = classType;


			@readFile: (object,input)->
				@_loadedObjectTable = input.readObject();
				@readExternal(object,input);
				

			@readExternal : (object,input) ->

				objectType = input.readUTF();
				object.iflType = objectType.split("::")[1];

				desc = @_loadedObjectTable[objectType];
				l = desc.length;
				
				for i in [0...l] by 2
					prop = desc[i];
					method = desc[i+1];
					throw "Parse Error" if not method?
					#hasProp = false;
					# try
					# {
					# 	var t:* = object[prop];
					# 	hasProp = true;
					# }
					# catch(err:ReferenceError)
					# {
					# 	hasProp = false;
					# }
					
					# if(hasProp)
					# {
					@readMethod(method,object,prop,input);				
					# }
					# else
					# {
						# object created does not have this property
						# read it anyways from the file and discard it
						#readMethod(method,{},prop,input);
					#}
				return null
				
			@readMethod: (method,object,prop,input) ->

				nativeHandler = @_methodReadHandlers[method]

				if (nativeHandler?) 
					object[prop] = input[nativeHandler]()
				else
					customHandler = @_customMethodReadHandlers[method]
					if (customHandler?) 
						@[customHandler](object,prop,input)
					else
						throw "Cannot find a method to read property #{prop} on object #{object} (method: #{method})"

				return null;

			@isKnownClassString: (str) ->
				@_knownClasses[ str ]?

			@isKnownInterfaceString: (str) ->
				@_knownInterfaces[ str  ]?

			@isSupportedBuiltinClassString: (str) ->
			 	str == "flash.utils::Dictionary" ||
					str == "flash.geom::Matrix" ||
					str == "flash.geom::Matrix3D" ||
					str == "flash.geom::Vector3D" ||
					str == "flash.utils::ByteArray" ||
					str == "Array" ||
					@isVectorString(str)

			@isBuiltinClassString: (str) ->
				str == "int" ||
					str == "uint" ||
					str == "Number" ||
					str == "String"

			@isVectorString: (str) ->
				str.indexOf("__AS3__.vec::Vector") != -1

			@readUTF: (object,prop,input) ->
				object[prop] = input.readUTF() if input.readBoolean()

			@readObject: (object,prop,input) ->
				
				if (input.readBoolean())
				
					type = input.readUTF();
					if(type == "" || !type)
						throw "Parse Error";

					if( @isKnownClassString(type) )
						object[prop] = input.readObject();
					else if(type == "flash.geom::Matrix3D")
						@readMatrix3D(object,prop,input);
					else if(type == "flash.utils::ByteArray")
						@readByteArray(object,prop,input);
					else if(type == "flash.geom::Matrix")
						@readMatrix(object,prop,input);
					else if(type == "Array")
						@readArray(object,prop,input);
					else if(type == "flash.geom::Vector3D")
						@readVector3D(object,prop,input);
					else if(type == "flash.utils::Dictionary")
						@readDictionary(object,prop,input);
					else if(@isVectorString(type))
						@readVector(object,prop,input)
					else
						#alert("Reading",prop,"on",object,"is unknown type:",type);
						AMF.registerClassAlias(type,{}.constructor);
						input.readObject()
				return null;


			@forceRead: (object,prop,type,input) ->

				returnObj = {}
				
				if(@isKnownClassString(type))
					return input.readObject();
				
				else if( @isSupportedBuiltinClassString( type ) )
				
					if(type == "flash.geom::Matrix")
						@readMatrix(returnObj,"prop",input)
					else if(type == "flash.geom::Matrix3D")
						@readMatrix3D(returnObj,"prop",input)
					else if(type == "flash.utils::ByteArray")
						@readByteArray(returnObj,"prop",input)
					else if(type == "flash.utils::Dictionary")
						@readDictionary(returnObj,"prop",input)
					else if(type == "flash.geom::Vector3D")
						@readVector3D(returnObj,"prop",input)
					else if(@isVectorString(type))
						@readVector(returnObj,"prop",input)

				else if( @isBuiltinClassString( type ) )
				
					if(type == "int")
						returnObj.prop = input.readInt()
					else if(type == "uint")
						returnObj.prop = input.readUnsignedInt();
					else if(type == "Number")
						returnObj.prop = input.readFloat();
					else if(type == "String")
						returnObj.prop = input.readUTF()
				
				else
				
					console.warn("Reading",prop,"on",object,"is unknown type:",type);
					
					if( @isKnownClassString(type) )
						input.readObject();
					else if(type == "flash.geom::Matrix3D")
						@readMatrix3D({},prop,input);
					else if(type == "flash.geom::Matrix")
						@readMatrix({},prop,input);
					else if(type == "flash.utils::ByteArray")
						@readByteArray({},prop,input);
					else if(type == "Array")
						@readArray({},prop,input);
					else if(type == "flash.geom::Vector3D")
						@readVector3D({},prop,input);
					else if(type == "flash.utils::Dictionary")
						@readDictionary({},prop,input);
					else if(@isVectorString(type))
						@readVector({},prop,input);
					else
					
						AMF.registerClassAlias(type,{}.constructor);
						input.readObject()
					
				
				return returnObj.prop;


			@readMatrix3D: (object,prop,input) ->

				dat = [];
				dat[0] = input.readFloat();
				dat[1] = input.readFloat();
				dat[2] = input.readFloat();
				dat[3] = input.readFloat();
				dat[4] = input.readFloat();
				dat[5] = input.readFloat();
				dat[6] = input.readFloat();
				dat[7] = input.readFloat();
				dat[8] = input.readFloat();
				dat[9] = input.readFloat();
				dat[10] = input.readFloat();
				dat[11] = input.readFloat();
				dat[12] = input.readFloat();
				dat[13] = input.readFloat();
				dat[14] = input.readFloat();
				dat[15] = input.readFloat();
				object[prop] = dat

			@readByteArray: (object,prop,input) ->

				l = input.readInt();


				ba = new Uint8Array(l);
				ba.set(input.data.subarray(input.pos,input.pos+l));
				input.pos += l;

				object[prop] = ba;
				return null;

			@readMatrix: (object,prop,input) ->

				m = {};
				m.a = input.readFloat();
				m.b = input.readFloat();
				m.c = input.readFloat();
				m.d = input.readFloat();
				m.tx = input.readFloat();
				m.ty = input.readFloat();
				object[prop] = m;
				return null;

			@readArray: (object,prop,input) ->

				objType = input.readUTF();
				if(@isKnownClassString(objType) || @isBuiltinClassString(objType))
					object[prop] = input.readObject();
				else if(@isSupportedBuiltinClassString(objType))
				
					# TODO: We need to manually read each value
					arr = [];
					l = input.readInt();

					for i in [0...l] by 1 when input.readBoolean()
						arr[i] = @forceRead(arr,i,objType,input)
					
					object[prop] = arr;
				
				else
				
					AMF.registerClassAlias(objType,{}.constructor)
					input.readObject();

				return null;
	
			@readVector3D: (object,prop,input) ->

				v = {};
				v.x = input.readFloat();
				v.y = input.readFloat();
				v.z = input.readFloat();
				v.w = input.readFloat();
				object[prop] = v;
				return null;

			@readDictionary: (object,prop,input) ->

				idsLength = input.readInt();
				keyClass = input.readUTF();
				valueClass = input.readUTF();
				
				d = {};
				
				for i in [0...idsLength] by 1 
					key = @forceRead(object,prop,keyClass,input);
					value = @forceRead(object,prop,valueClass,input);
					d[key] = value if key? and value?

				object[prop] = d;

				return null;


			@readVector: (object,prop,input) ->

				typeName = input.readUTF();
				typeList = input.readObject();

				
				if( @isKnownClassString(typeName) || @isBuiltinClassString(typeName) )
					object[prop] = input.readObject();
				
				else if(@isKnownInterfaceString(typeName))
				
					#def = getDefinitionByName("__AS3__.vec::Vector.<"+typeName+">")
					
					v = [];
					
					for i in [0...typeList.length] by 1 
					
						if(  @isKnownClassString(typeList[i]) || @isBuiltinClassString(typeList[i]) )
						
							obj = input.readObject();
							#var obj = {};
							#readObject(obj,"v",input);
							if(obj?)
								v.push( obj );
							else
								throw "Reading went wrong";
						
						else
						
							console.warn "Reading Vector #{prop} on #{object}, Element: #{i} is unknown type: #{typeList}";
							AMF.registerClassAlias(typeList[i],{}.constructor)
							input.readObject();
						
					
					object[prop] = v;		
				
				else if (@isSupportedBuiltinClassString(typeName))
				
					#def = getDefinitionByName("__AS3__.vec::Vector.<"+typeName+">")
					
					v = [];
					for i in [0...typeList.length] by 1 
						@readObject(v,i.toString(),input)

					object[prop] = v;
				
				else
				
					# TODO: objects contained cannot be read, skip property...
					console.warn "Reading #{prop} on #{object} is unknown type: #{typeName}"
					AMF.registerClassAlias(typeName,{}.constructor);
					input.readObject()
				
