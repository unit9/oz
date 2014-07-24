// JavaScript Document<script type="text/javascript">
var gl;
var canvas;
var bufLoaded = false;
var texLoaded = false;
var mouseXY = V3.$(0,0,0);

function initWin(){
  docWidth = $(window).width();
  docHeight = $(window).height();
  $("#webgl-canvas").width(docWidth);
  $("#webgl-canvas").height(docHeight);    
  canvas.width = docWidth;
  canvas.height = docHeight;
  try {
    gl = canvas.getContext( "experimental-webgl") ;
    gl.viewportWidth = docWidth;
    gl.viewportHeight = docHeight;
  } catch(e) {
  }
  if (!gl) {
    alert("Your browser failed to initialize WebGL.");
  }
  initUI();
}

$(window).resize(function() {
  initWin();
});

function webGLStart() {
  canvas = document.getElementById("webgl-canvas");
  initWin();
  initCreature();
  initShaders();
  initTextures();
  initBuffers();
  setDebugParam();
  
  gl.clearColor(0., 0., 0., 0.);
  gl.clearDepth(1.);
  gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
  gl.enable(gl.BLEND);
  gl.enable(gl.DEPTH_TEST);
  gl.depthFunc(gl.LEQUAL);
  
  //toggleConsole();

  window.onmousemove = function ( ev ){
   mouseXY[0] = ev.clientX - docWidth/2;
   mouseXY[1] = ev.clientY - docHeight/2;
  }

  document.getElementById('mouse-target').onclick = function() {
    timeline.gotoState(3);
    this.style.display = 'none';
  };

  preloader.show();
}

function tryStartAnimation() {
  if (bufLoaded && texLoaded) {
    preloader.showPrompt(function() {
        preloader.hide();
        canvas.style.display = 'block';
        timeline.start();
        animate();
    });
  }
}
