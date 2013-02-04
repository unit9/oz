function Cam()
{
	console.log("* Init Cam");

	this.video 			= document.querySelector("video");
	this.stream 		= "";

	this.filters 		= ["grayscale", "sepia", "brightness", "contrast", "hue-rotate", "hue-rotate2", "hue-rotate3", "saturate", "invert", ""];
	this.currentFilter	= this.filters.length;
}

Cam.prototype = new Base();

Cam.prototype.init = function()
{
	// Start webcam streaming
	this.getUserMedia();
}

/* -----------------------------------------------------
 * Initiate the webcam streaming
 * ----------------------------------------------------- */

Cam.prototype.getUserMedia = function()
{
	console.log(this);
	
	try
	{
		navigator.webkitGetUserMedia({audio:true, video:true}, this.Bind(this.onUserMediaSuccess), this.Bind(this.onUserMediaError));
	}
	catch (e)
	{
		try
		{
			navigator.webkitGetUserMedia("video,audio", this.Bind(this.onUserMediaSuccess), this.Bind(this.onUserMediaError));
		}
		catch (e)
		{
			alert("webkitGetUserMedia() failed. Is the MediaStream flag enabled in about:flags?");
			console.log("webkitGetUserMedia failed with exception: " + e.message);
		}
	}
}

Cam.prototype.stop = function()
{
	this.video.pause();
	this.video.src = "";
}


/* -----------------------------------------------------
 * Callback when user has granted access to local media
 * ----------------------------------------------------- */

Cam.prototype.onUserMediaSuccess = function(stream)
{
	this.stream = stream;
	this.video.src = webkitURL.createObjectURL(stream);

	this.video.addEventListener("loadedmetadata", this.Bind(this.onMetaDataLoaded));
}

/* -----------------------------------------------------
 * If the user doens't have webcam or doesn't allow it
 * ----------------------------------------------------- */

Cam.prototype.onUserMediaError = function(error)
{
	console.error("Failed to get access to local media. Error code was " + error.code);
}

/* -----------------------------------------------------
 * When the video receives metadata from the streaming
 * ----------------------------------------------------- */

Cam.prototype.onMetaDataLoaded = function(e)
{
	var event = document.createEvent("Event");
	event.initEvent("webcamLoaded", true, true);
	window.dispatchEvent(event);
}

/* -----------------------------------------------------
 * CSS Filters over the video
 * ----------------------------------------------------- */

Cam.prototype.changeFilter = function( )
{
	this.video.className = "";
	
	this.currentFilter++;
	if(this.currentFilter >= this.filters.length) this.currentFilter = 0;

	var effect = this.filters[ this.currentFilter ];

	if (effect)
	{
		console.log(effect);
    	this.video.classList.add(effect);
    }
}

/* -----------------------------------------------------
 * Return the current frame of the webcam streaming feed
 * ----------------------------------------------------- */

Cam.prototype.snapshot = function( canvas, x )
{
	canvas.getContext("2d").drawImage(this.video, x, 12, 100, 75);
}