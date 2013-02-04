function App()
{
	// Camera feed
	this.camera 			= "";
	
	// Current canvas to draw the picture from the video
	this.currentPicture 	= 0;

	// Number of pictures needed to make the Zoetrope
	this.numberOfPictures	= 24;

	// Interval between shots in miliseconds
	this.pictureInterval	= 250;

	// Timer interval to take shots
	this.shooter			= "";

	// Canvas where is created the spritesheet
	this.canvas 			= "";

	// Current filter style effect
	this.style 				= "";
}

App.prototype = new Base();

/* -----------------------------------------------------
 * Initiate the application
 * ----------------------------------------------------- */

App.prototype.init = function()
{
	console.log("* Init App");

	// Hide Zoetrope
	$('.wrapper').fadeOut(0);

	// Camera input
	this.camera = new Cam();
	this.camera.init();
	addEventListener("webcamLoaded", this.Bind(this.enableNavigation));
}

/* -----------------------------------------------------
 * Navigation Handler
 * ----------------------------------------------------- */

App.prototype.enableNavigation = function()
{
	// Change filter when click on the webcam feed
	$(this.camera.video).click( this.camera.Bind( this.camera.changeFilter ) );

	// Make zoetrope
	this.enableButton("#btTakePic", this.makezoetrope);

	// Disable the preview
	this.disableButton("#btPreview");

	// Disable PDF
	this.disableButton("#btPrintPdf");
}

App.prototype.disableButton = function( bt )
{
	$(bt).css({cursor: "default"});
	$(bt).stop().animate({"background-color": "#222", color: "#353535"}, 250);

	$(bt).unbind("click");
	$(bt).unbind("mouseover");
	$(bt).unbind("mouseout");
}

App.prototype.enableButton = function( bt, action )
{
	$(bt).css({cursor: "pointer"});
	$(bt).stop().animate({"background-color": "#34ca85", color: "#FFF"}, 250);

	$(bt).mouseover(function()
	{
		$(this).stop().animate({"background-color": "#59997b", color: "#FFF"}, 250);
	});

	$(bt).mouseout(function()
	{
		$(this).stop().animate({"background-color": "#34ca85", color: "#FFF"}, 250);
	});

	$(bt).click( this.Bind( action ) );
}

/* -----------------------------------------------------
 * Zoetrope builder
 * ----------------------------------------------------- */

App.prototype.makezoetrope = function()
{
	// Disable change filter when click on the webcam feed
	$(this.camera.video).unbind("click");

	// Disable make zoetrope button
	this.disableButton("#btTakePic");

	// Add the canvas
	this.addCanvas();

	// Start the sequence shooter
	this.shooter = setInterval( this.Bind(this.takePicture), this.pictureInterval );
}

App.prototype.takePicture = function()
{
	if(this.currentPicture >= this.numberOfPictures)
		this.picturesTaken();
	else
	{
		this.camera.snapshot( this.canvas, this.currentPicture * 100 );
		this.currentPicture++;

		// Scroll the slider to the right to always show the last frame
		if(this.currentPicture * 100 > $(".photo").width())
			$(".photo").stop().animate({scrollLeft: (this.currentPicture * 100) - $(".photo").width() }, 500);
	}
}

App.prototype.addCanvas = function()
{
	// Current effect of the webcam
	var effect = this.camera.filters[ this.camera.currentFilter ];
	if(effect) this.style = effect;

	// How large is the canvas and the container
	var w = (this.numberOfPictures * 100);
	$(".photoscontainer").append('<canvas id="spritesheet" width="'+ w +'" height="100" class="'+ this.style +'"></canvas>');
	$(".photoscontainer").css({ width: w });

	this.canvas = document.getElementById("spritesheet");
}

App.prototype.picturesTaken = function()
{
	// Clear the sequence shooter
	clearInterval(this.shooter);

	// Enable the preview
	this.enableButton("#btPreview", this.previewZoetrope);
}

App.prototype.previewZoetrope = function()
{
	// Enable PDF Print
	this.enableButton("#btPrintPdf", this.print);

	// Disable Preview Button
	this.disableButton("#btPreview");

	// Hide webcam feed
	$(".videosource").animate({left: - $(".videosource").width() }, { duration: 500, easing: "easeOutCubic", complete: this.camera.Bind( this.camera.stop ) });

	// Hide photos footer
	$(".container").animate({bottom: - $(".container").height() + 39 }, { duration: 500, easing: "easeOutCubic" });

	// Show zoetrope and start the rotation
	$('.wrapper').fadeIn(100);
	$(".frames").addClass("framesMoving");

	// Create the spritesheet
	$(".zoetrope.horse .frames > div").css({"background-image": "url(" + this.canvas.toDataURL("image/jpeg") + ")"});

	// Zoetrope zoom mouse controller
	var zoetroper = new Zoetrope();
}

App.prototype.print = function()
{
	// Grab the image strip as a jpeg encoded in base64, but only the data
	var strip = this.canvas.toDataURL("image/jpeg").slice('data:image/jpeg;base64,'.length);
	// Convert the data to binary form
	strip = atob(strip);

	// Open the window to show the pdf
	var w = window.open("");

	// Load the zoetrope template jpg

	// Because of security restrictions, getImageFromUrl will
	// not load images from other domains.  Chrome has added
	// security restrictions that prevent it from loading images
	// when running local files.  Run with: chromium --allow-file-access-from-files --allow-file-access
	// to temporarily get around this issue.

	var getImageFromUrl = function(url, callback)
	{
		var img = new Image, data, ret = {data: null, pending: true};
	
		img.onError = function()
		{
			throw new Error("Cannot load image: " + url);
		}

		img.onload = function()
		{
			var canvas = document.createElement("canvas");
			document.body.appendChild(canvas);
			canvas.width = img.width;
			canvas.height = img.height;

			var ctx = canvas.getContext("2d");
			ctx.drawImage(img, 0, 0);

			// Grab the image as a jpeg encoded in base64, but only the data
			data = canvas.toDataURL("image/jpeg").slice("data:image/jpeg;base64,".length);

			// Convert the data to binary form
			data = atob(data);
			document.body.removeChild(canvas);

			ret["data"] = data;
			ret["pending"] = false;

			if (typeof callback === "function")
			{
				callback(data);
			}
		}
		
		img.src = url;

		return ret;
	}

	// Since images are loaded asyncronously, we must wait to create
	// the pdf until we actually have the image data.
	// If we already had the jpeg image binary data loaded into
	// a string, we create the pdf without delay.

	var createPDF = function(imgData)
	{
		var doc = new jsPDF("landscape");
		
		doc.addImage( imgData, "JPEG", 0, 0, 297, 210);
		doc.addImage( strip, "JPEG", 5, 5, (2400 * 4.5) * 2.54 / 96, (100 * 4.5) * 2.54 / 96 );
		
		// Output as Data URI
		var url = doc.output("dataurlstring");

		w.location = url;
	}

	getImageFromUrl("img/zoetrope_template_01.jpg", createPDF);
}