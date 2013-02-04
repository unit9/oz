/*
 * Binary Ajax 0.1.1
 * Copyright (c) 2008 Jacob Seidelin, cupboy@gmail.com, http://blog.nihilogic.dk/
 * MIT License [http://www.opensource.org/licenses/mit-license.php]
 */


var BinaryAjax = (function() {

	function BinaryFile(strData) {
		this._data = strData;

		this.getRawData = function() {
			return this._data;
		}

		if (typeof strData == "string") {
			this.getByteAt = function(iOffset) {
				return this._data.charCodeAt(iOffset) & 0xFF;
			}
			this.getLength = function() {
				return this._data.length;
			}
		} else if (typeof strData == "unknown") {
			this.getByteAt = function(iOffset) {
				return IEBinary_getByteAt(this._data, iOffset);
			}
			this.getLength = function() {
				return IEBinary_getLength(this._data);
			}
		}

		this.getSByteAt = function(iOffset) {
			var iByte = this.getByteAt(iOffset);
			if (iByte > 127)
				return iByte - 256;
			else
				return iByte;
		}

		this.getShortAt = function(iOffset, bBigEndian) {
			return bBigEndian ? 
				(this.getByteAt(iOffset) << 8) + this.getByteAt(iOffset+1)
				: (this.getByteAt(iOffset+1) << 8) + this.getByteAt(iOffset)
		}
		this.getSShortAt = function(iOffset, bBigEndian) {
			var iUShort = this.getShortAt(iOffset, bBigEndian);
			if (iUShort > 32767)
				return iUShort - 65536;
			else
				return iUShort;
		}
		this.getLongAt = function(iOffset, bBigEndian) {
			var iByte1 = this.getByteAt(iOffset),
				iByte2 = this.getByteAt(iOffset+1),
				iByte3 = this.getByteAt(iOffset+2),
				iByte4 = this.getByteAt(iOffset+3);

			return bBigEndian ? 
				(((((iByte1 << 8) + iByte2) << 8) + iByte3) << 8) + iByte4
				: (((((iByte4 << 8) + iByte3) << 8) + iByte2) << 8) + iByte1;
		}
		this.getSLongAt = function(iOffset, bBigEndian) {
			var iULong = this.getLongAt(iOffset, bBigEndian);
			if (iULong > 2147483647)
				return iULong - 4294967296;
			else
				return iULong;
		}
		this.getStringAt = function(iOffset, iLength) {
			var aStr = [];
			for (var i=iOffset,j=0;i<iOffset+iLength;i++,j++) {
				aStr[j] = String.fromCharCode(this.getByteAt(i));
			}
			return aStr.join("");
		}
		this.getCharAt = function(iOffset) {
			return String.fromCharCode(this.getByteAt(iOffset));
		}


		this.toBase64 = function() {
			return window.btoa(this._data);
		}

		this.fromBase64 = function(strBase64) {
			this._data = window.atob(strBase64);
		}
	}


	return function(strURL, fncCallback, fncError) {
		var oHTTP = null;
		if (window.XMLHttpRequest) {
			oHTTP = new XMLHttpRequest();
		} else if (window.ActiveXObject) {
			oHTTP = new ActiveXObject("Microsoft.XMLHTTP");
		}
		if (oHTTP) {
			if (fncCallback) {
				if (typeof(oHTTP.onload) != "undefined") {
					oHTTP.onload = function() {
						this.binaryResponse = new BinaryFile(oHTTP.responseText);
						fncCallback(this);
						oHTTP = null;
					};
				} else {
					oHTTP.onreadystatechange = function() {
						if (oHTTP.readyState == 4) {
							this.binaryResponse = new BinaryFile(oHTTP.responseBody);
							fncCallback(this);
							oHTTP = null;
						}
					};
				}
			}
			oHTTP.open("GET", strURL, true);

			if (oHTTP.overrideMimeType) oHTTP.overrideMimeType('text/plain; charset=x-user-defined');

			oHTTP.setRequestHeader("If-Modified-Since", "Sat, 1 Jan 1970 00:00:00 GMT");

			oHTTP.send(null);
		} else {
			if (fncError) fncError();
		}
	}

}());


document.write(
	"<script type='text/vbscript'>\r\n"
	+ "Function IEBinary_getByteAt(strBinary, iOffset)\r\n"
	+ "	IEBinary_getByteAt = AscB(MidB(strBinary,iOffset+1,1))\r\n"
	+ "End Function\r\n"
	+ "Function IEBinary_getLength(strBinary)\r\n"
	+ "	IEBinary_getLength = LenB(strBinary)\r\n"
	+ "End Function\r\n"
	+ "</script>\r\n"
);