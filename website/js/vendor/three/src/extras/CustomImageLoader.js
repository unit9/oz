/**
 * @author mrdoob / http://mrdoob.com/
 */
var CustomImageLoader = (function() {
    // "private" variables 
   
	 // constructor
    function CustomImageLoader(){
		this._urlToLoad="test";
		this._preload = new createjs.PreloadJS();
		this.onLoadCallback=null;
		this.onProgressCallback=null;
		this.onErrorCallback=null;
	};

    CustomImageLoader.prototype.load = function ( url, image ) {
		var self = this;
		this._urlToLoad = url;
		this._preload.onFileLoad = function (event){
			//alert("loader invia un load");
			if(self.onLoadCallback) self.onLoadCallback({ type: 'load', content: event.result });
		};
		
		this._preload.onFileProgress = function(event){
			//alert("loader invia un progress");
			if(self.onProgressCallback) self.onProgressCallback({ type: 'progress', progress: event.progress });
		};
		this._preload.onError = function(event){
			//alert("loader invia un error "+self._urlToLoad +"-->"+self.onErrorCallback);
			if(self.onErrorCallback) self.onErrorCallback({ type: 'error', message: 'Couldn\'t load URL [' + self._urlToLoad + ']' });
		};
		
		this._preload.loadFile(url);
	};
	
    return CustomImageLoader;
})();

