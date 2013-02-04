// Ref:		http://www.youtube.com/watch?v=E-n2rDYj6X8
// 			http://andrew-hoyer.com/experiments/zoetrope/

function Zoetrope()
{
	console.log("* Init Zoetrope Viewer");

	this.enableMouse();
	this.loop();
}

Zoetrope.prototype = new Base();

Zoetrope.prototype.init = function()
{
	
}

Zoetrope.prototype.render = function()
{
	var currentTransform = new WebKitCSSMatrix(window.getComputedStyle($(".wrapper")[0]).webkitTransform);
	var scale = (window.mouseYPos / $(window).height()) + 1;
	
	document.querySelector(".wrapper").style[Modernizr.prefixed("transform")] = "scale(" + scale + ")";
}

/* -----------------------------------------------------
 * Track mouse position
 * ----------------------------------------------------- */

Zoetrope.prototype.enableMouse = function()
{
	$(window).mousemove(function(e)
	{
		window.mouseXPos = e.pageX;
		window.mouseYPos = e.pageY;
	});
}

/* -----------------------------------------------------
 * Animation
 * ----------------------------------------------------- */

window.requestAnimFrame = (function(){
  return  window.requestAnimationFrame       || 
          window.webkitRequestAnimationFrame || 
          window.mozRequestAnimationFrame    || 
          window.oRequestAnimationFrame      || 
          window.msRequestAnimationFrame     || 
          function( callback ){
            window.setTimeout(callback, 1000 / 60);
          };
})();

Zoetrope.prototype.loop = function()
{
    requestAnimFrame(this.Bind(this.loop));
    this.render();
};