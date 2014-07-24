namespace "amf"
	ByteArray:
		class ByteArray 
			data			: []
			length			: 0
			pos				: 0
			pow				: Math.pow
			endian			: amf.Endian.BIG
			TWOeN23			: Math.pow(2, -23)
			TWOeN52			: Math.pow(2, -52)
			ObjectEncoding	: amf.ObjectEncoding.AMF3
			stringTable		: []
			objectTable		: []
			traitTable		: []
			progressCallback:(parsed,total)->


			needTraitSnapshot 	: false
			tempTi				: null

			# this horrible thing is to optimize float64 parsing speed (use fixed references intead of a while loop)
			float64Zero1: "0"
			float64Zero2: "00"
			float64Zero3: "000"
			float64Zero4: "0000"
			float64Zero5: "00000"
			float64Zero6: "000000"
			float64Zero7: "0000000"
			float64Zero8: "00000000"
			float64Zero9: "000000000"
			float64Zero10:"0000000000"
			float64Zero11:"00000000000"
			float64Zero12:"000000000000"
			float64Zero13:"0000000000000"
			float64Zero14:"00000000000000"
			float64Zero15:"000000000000000"
			float64Zero16:"0000000000000000"
			float64Zero17:"00000000000000000"
			float64Zero18:"000000000000000000"
			float64Zero19:"0000000000000000000"
			float64Zero20:"00000000000000000000"
			float64Zero21:"000000000000000000000"
			float64Zero22:"0000000000000000000000"
			float64Zero23:"00000000000000000000000"

			float64CacheS12 		: {}
			float64CacheS3 			: {}
			float64CacheParseInt 	: {}
			
			dispose: ->
				@float64CacheParseInt = @float64CacheS12 = @float64CacheS3 = @data = @traitTable = @stringTable = @objectTable = null
				return

			constructor: (data, endian) ->
				@data = data ? [];

				@endian = endian ? amf.Endian.BIG;
				@length = data.length;

				# Cache the function pointers based on endianness.
				# This avoids doing an if-statement in every function call.
				funcExt = if endian == amf.Endian.BIG then 'BE' else 'LE'
				funcs = ['readInt32', 'readInt16', 'readUInt30','readUInt32', 'readUInt16', 'readFloat32', 'readFloat64'];

				for func in funcs
					ByteArray::[func] =  ByteArray::[func + funcExt]

				# Add redundant members that match actionscript for compatibility
				funcMap = 
					readUnsignedByte: 'readByte'
					readUnsignedInt: 'readUInt32'
					readFloat: 'readFloat32'
					readDouble: 'readFloat64'
					readShort: 'readInt16'
					readUnsignedShort: 'readUInt16'
					readBoolean: 'readBool'
					readInt: 'readInt32'
				
				for func of funcMap
					 @[func] = ByteArray::[funcMap[func]]
			
			readByte: ->
				@progressCallback(@pos,@length) if @pos % 10000 == 0
				@data[@pos++]

			writeByte:(byte) ->
				@data.push(byte)

			readBool: ->
				if @data[@pos++] & 0xFF then true else false

				
			readUInt29: ->
				# Each byte must be treated as unsigned
				b = @readByte() & 0xFF;

				if (b < 128)
					return b;

				value = (b & 0x7F) << 7;
				b = @readByte() & 0xFF;

				if (b < 128)
					return (value | b);

				value = (value | (b & 0x7F)) << 7;

				b = @readByte() & 0xFF;

				if (b < 128)
					return (value | b);

				value = (value | (b & 0x7F)) << 8;

				b = @readByte() & 0xFF;

				return (value | b);

			readUInt16BE: ->
				data = @data
				pos = (@pos += 2) - 2;
				((data[pos] & 0xFF) << 8) | (data[++pos] & 0xFF)

			readUInt30BE: ->
				ch1 = @readByte()
				ch2 = @readByte()
				ch3 = @readByte()
				ch4 = @readByte()

				if (ch1 >= 64) 
					undefined 
				
				ch4 | (ch3 << 8) | (ch2 << 16) | (ch1 << 24)
			
			readUInt32BE: ->
				data = @data
				pos = (@pos += 4) - 4
				( (data[pos] & 0xFF) << 24 ) | ( (data[++pos] & 0xFF) << 16 ) | ( (data[++pos] & 0xFF) << 8 ) | (data[++pos] & 0xFF)
				
			readInt16BE: ->
				data = @data
				pos = (@pos += 2) - 2
				x = ( (data[pos] & 0xFF) << 8 ) | (data[++pos] & 0xFF)
				if x >= 32768 
					x - 65536 
				return x

			readInt32BE: ->
				data = @data
				pos = (@pos += 4) - 4;
				x = ((data[pos] & 0xFF) << 24) | ((data[++pos] & 0xFF) << 16) | ((data[++pos] & 0xFF) << 8) | (data[++pos] & 0xFF)
				if (x >= 2147483648) 
					return x - 4294967296
				return x;

			readFloat32BE: ->
				data = @data
				pos = (@pos += 4) - 4

				b1 = data[pos] 		& 0xFF
				b2 = data[++pos] 	& 0xFF
				b3 = data[++pos] 	& 0xFF
				b4 = data[++pos] 	& 0xFF

				sign = 1 - ((b1 >> 7) << 1);                   # sign = bit 0
				exp = (((b1 << 1) & 0xFF) | (b2 >> 7)) - 127;  # exponent = bits 1..8
				sig = ((b2 & 0x7F) << 16) | (b3 << 8) | b4;    # significand = bits 9..31

				
				return 0 if sig == 0 and exp == -127

				return sign * (1 + @TWOeN23 * sig) * @pow(2, exp);



			readFloat64BE: ->
				b1 = @readByte();
				b2 = @readByte();
				b3 = @readByte();
				b4 = @readByte();
				b5 = @readByte();
				b6 = @readByte();
				b7 = @readByte();
				b8 = @readByte();


				sign = 1 - ((b1 >> 7) << 1)						# sign = bit 0
				exp = (((b1 << 4) & 0x7FF) | (b2 >> 4)) - 1023;	# exponent = bits 1..11


				s1 = (((b2 & 0xF) << 16) | (b3 << 8) | b4)#.toString(2)
				s2 = (((b5 & 0xF) << 16) | (b6 << 8) | b7)#.toString(2)
				s3 = (b8)#.toString(2)

				# this is needed
				# l = s1.length;
				# if(l < 24)
				# 	s1 = @["float64Zero"+String(24 - l)] + s1;

				# l = s2.length;
				# if(l < 24)
				# 	s2 = @["float64Zero"+String(24 - l)] + s2;

				# l = s3.length;
				# if(l < 8)
				# 	s3 = @["float64Zero"+String(8 - l)] + s3;
				


				# toString(2) and the leading ZEROS computations are expensive
				# we try to cache the process
				# this generally makes it 2x faster

				if !@float64CacheS12[s1]?
					@float64CacheS12[s1] = s1.toString(2)
					l = @float64CacheS12[s1].length;
					if(l < 24)
						@float64CacheS12[s1] = @["float64Zero"+String(24 - l)] + @float64CacheS12[s1];


				if !@float64CacheS12[s2]?
					@float64CacheS12[s2] = s2.toString(2)
					l = @float64CacheS12[s2].length;
					if(l < 24)
						@float64CacheS12[s2] = @["float64Zero"+String(24 - l)] + @float64CacheS12[s2];
		

				if !@float64CacheS3[s3]?
					@float64CacheS3[s3] = s3.toString(2)
					l = @float64CacheS3[s3].length;
					if(l < 8)
						@float64CacheS3[s3] = @["float64Zero"+String(8 - l)] + @float64CacheS3[s3];

				s1 = @float64CacheS12[s1]
				s2 = @float64CacheS12[s2]
				s3 = @float64CacheS3[s3]

				sig = parseInt(s1 + s2 + s3, 2)

				
				return 0 if sig == 0 and exp == -1023

				return sign*(1.0 + @TWOeN52*sig)*@pow(2, exp);

			readDate: ->
				time_ms = @readDouble();
				tz_min = @readUInt16();
				new Date(time_ms + tz_min * 60 * 1000);

			readString: (len)->
				str = "";
				while len > 0
					str += String.fromCharCode( @readUnsignedByte() ) 
					len-- 
				return str;

			readUTF: ->
				@readString(@readUnsignedShort())

			readLongUTF: ->
				@readString(@readUInt30())

			stringToXML: (str) ->
				if @hasOwnProperty("window") and window.DOMParser
					parser = new DOMParser();
					xmlDoc = parser.parseFromString(str, "text/xml");
				else
					xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
					xmlDoc.async = false;
					xmlDoc.loadXML(str);
				return xmlDoc;

			readXML: ->
				@stringToXML( @readLongUTF() )

			readStringAMF3: ->
				ref = @readUInt29();

				if (ref & 0x1) == 0 
					return @stringTable[(ref >> 1)]  #This is a reference

				len = ref >> 1;

				if len == 0 then return "";

				str = @readString(len);

				@stringTable.push(str);

				return str;

			readTraits: (ref,store = true) ->

				if (ref & 0x3) == 1 and ref != 1
					return @traitTable[ref >> 2]

				traitInfo = {};

				traitInfo.properties = [];
				traitInfo.externalizable = (ref & 0x4) == 4;
				traitInfo.dynamic = (ref & 0x8) == 8;
				traitInfo.count = ref >> 4;

				if store then @traitTable.push(traitInfo);

				traitInfo.className = @readStringAMF3();
				
				for i in [0...traitInfo.count] by 1
					propName = @readStringAMF3()
					traitInfo.properties.push(propName)

				return traitInfo;

			readExternalizable: (className,o) -> 

				if(o.readExternal?)
					o.readExternal(this)
				else
					ifl.IFLParser.readExternal(o,this)

				return null;
				#if className.indexOf("::IFlash3DLibrary") != -1
				#	ifl.IFLParser.readFile(o,this) 
				#else
				#	ifl.IFLParser.readExternal(o,this)

			readObject: -> 
				marker = @readByte();

				switch marker
					when amf.Amf3Types.kUndefinedType then return undefined
					when amf.Amf3Types.kNullType then return null
					when amf.Amf3Types.kFalseType then return false
					when amf.Amf3Types.kTrueType then return true
					when amf.Amf3Types.kIntegerType then return @readUInt29()
					when amf.Amf3Types.kDoubleType then return @readDouble()
					when amf.Amf3Types.kStringType then return @readStringAMF3()
					when amf.Amf3Types.kXMLType then return @readXML()
					when amf.Amf3Types.kDateType then return @readDateAMF3();   
					when amf.Amf3Types.kArrayType then return @readArrayAMF3()   
					when amf.Amf3Types.kObjectType then return @readObjectAMF3()
					when amf.Amf3Types.kAvmPlusXmlType then return @readAVMPlusXMLAMF3()
					when amf.Amf3Types.kByteArrayType then return @readByteArrayAMF3()
					when amf.Amf3Types.kVectorIntType then return @readVectorIntAMF3()
					when amf.Amf3Types.kVectorUintType then return @readVectorUintAMF3()
					when amf.Amf3Types.kVectorNumberType then return @readVectorNumberAMF3()
					when amf.Amf3Types.kVectorObjectType then return @readVectorObjectAMF3()
					else
						console.warn "Object Marker at #{@pos-1} not recognised, trying next byte" 
						return @readObject() # try next byte instead of throwing an error
			
			readObjectAMF3: ->

				ref = @readUInt29()
				if (ref & 1) == 0 then return @objectTable[ref >> 1]

				ti = @readTraits(ref)

				#if (@needTraitSnapshot)
				#	@needTraitSnapshot = false;
				#	@tempTi = ti;

				#ti = @tempTi if @tempTi?

				className = ti.className

				externalizable = ti.externalizable

				al = AMF.getClassForAlias(className)

				if ( al? ) then	o = new al() else o = {}

				@objectTable.push(o)

				# TODO: should read externalizables only when traits are externalizable
				# howsever there are bugs with traits
				@readExternalizable(className,o)

				return o;
  
			readVectorIntAMF3: ->

				ref = @readUInt29()
				if (ref & 1) == 0 then return @objectTable[ref >> 1]

				len = ref >> 1;

				ref2 = @readUInt29()

				array = new Int32Array(len)
				for obj,index in array
					array[index] =  @readInt()

				#array = for i in [0...len] by 1 then @readInt()

				@objectTable.push(array)

				return array;

			readVectorUintAMF3: ->

				ref = @readUInt29();
				if (ref & 1) == 0 then return @objectTable[ref >> 1]

				len = ref >> 1;

				ref2 = @readUInt29()

				array = new Uint32Array(len)
				for obj,index in array
					array[index] = @readUInt32()

				@objectTable.push(array)

				return array;
  
			readVectorNumberAMF3: ->

				#t = new Date().getTime()

				ref = @readUInt29();
				if (ref & 1) == 0 then return @objectTable[ref >> 1]

				len = ref >> 1

				ref2 = @readUInt29()

				array = new Float32Array(len)

				for obj,index in array
					array[index] = @readDouble()

				@objectTable.push(array)

				#console.log( "parse vector double time: " + (new Date().getTime() - t) / 1000 )
				return array;

			readVectorObjectAMF3: ->

				ref =  @readUInt29();
				if (ref & 1) == 0 then return @objectTable[ref >> 1]

				len = ref >> 1
				array = []
				@objectTable.push(array)

				# Vector of Object is like an pure object, it's got a traits defining it's type
				ref2 = @readUInt29()
				ti2 = @readTraits(ref2,false)
				#className = ti2.className
				
				#@needTraitSnapshot = true;

				for i in [0...len] by 1 then array.push( @readObject() )

				#@needTraitSnapshot = false;
				#@tempTi = null;

				return array

			readByteArrayAMF3: ->

				ref =  @readUInt29()
				if (ref & 1) == 0 then return @objectTable[ref >> 1]

				len = ref >> 1

				ba = new a3d.ByteArray()

				@objectTable.push(ba);

				for i in [0...len] by 1 then ba.writeByte( @readByte() ) 

				return ba;

			readAVMPlusXMLAMF3: ->
				ref = @readUInt29()

				if (ref & 1) == 0 then	return @stringToXML( @objectTable[ref >> 1] )

				len = ref >> 1;

				if len == 0 then return null

				str = @readString(len)

				xml = @stringToXML(str)

				@objectTable.push(xml)

				return xml

			readDateAMF3: ->

				ref =  @readUInt29()
				if (ref & 1) == 0 then return @objectTable[ref >> 1]

				d = @readDouble();
				value = new Date(d);
				@objectTable.push(value);

				return value; 

			readArrayAMF3: ->
			
				ref =  @readUInt29()
				if (ref & 1) == 0 then return @objectTable[ref >> 1]

				len = ref >> 1;

				key = @readStringAMF3()

				# indexed array
				if key == ""
					a = for i in [0...len] by 1 then @readObject()
					@objectTable.push(a)
					return a
				

				# mixed array
				result = {};
				@objectTable.push(result);

				while (key != "")
					result[key] = @readObject();
					key 		= @readStringAMF3();
				

				for i in [0...len] by 1 then result[i] = this.readObject();

				return result;
			


  