/**
 * Main.js: OZ tornado shader example
 *
 */

var TORNADO_RT = 8; // Downsamples

var width;
var height;
var timer;
var renderer;
var scene, camera;
var controls;
var hud;
var tornadoW, tornadoH;
var tornadoRT, tornadoMat;

var test, cube;

function main() {
	// Initialize stuff
	if (Detector.webgl) {
		init();
		animate();
	}
	else
		Detector.addGetWebGLMessage();
}

// init the scene
function init(){

	console.log("Loading...");

	// Vars
	width  = window.innerWidth;
	height = window.innerHeight;
	tornadoW = width / TORNADO_RT;
	tornadoH = height / TORNADO_RT;	

	// Timer
	timer = new Timer();

	// Renderer
	renderer = new THREE.WebGLRenderer();
	renderer.setClearColorHex(0x404040, 1);
	renderer.setSize(width, height);
	document.body.appendChild(renderer.domElement);

	// create a scene
	scene = new THREE.Scene();

	// put a camera in the scene
	camera = new THREE.PerspectiveCamera(70, width/height, 1, 1000);
	camera.position.set(30, 30, 30);
	scene.add(camera);

	// Controls
	controls = new THREE.TrackballControls(camera);

	// create the Cube
	cube = new THREE.Mesh(new THREE.CubeGeometry(8, 8, 8), new THREE.MeshNormalMaterial());
	scene.add(cube);

	// Test material
	test = THREE.ImageUtils.loadTexture('images/test.jpg');	

	// Hud for Tornado
	hud = new Hud(renderer, width,height, false, false);

	// Tornado
	var params = { minFilter: THREE.LinearFilter, magFilter: THREE.LinearFilter, format: THREE.RGBAFormat, depthBuffer: false };
	tornadoRT = new THREE.WebGLRenderTarget(width,height, params);
	renderer.clearTarget(tornadoRT);

	// Shader
	var uniforms = {
		time: 		   	{ type: "f", value: 0 },
		resolution:    	{ type: "v2", value: new THREE.Vector2(0,0) }, 
		camera_matrix: 	{ type: "m4", value: new THREE.Matrix4() },
	};
	tornadoMat = new THREE.ShaderMaterial({
		uniforms: uniforms,
		vertexShader: getText('tornadoVS'),
		fragmentShader: getText('tornadoFS'),
		transparent: true,
	});
	tornadoMat.uniforms["resolution"].value = new THREE.Vector2(tornadoW, tornadoH);

	// init the Stats and append it to the Dom - performance vuemeter
	stats = new Stats();
	stats.domElement.style.position = 'absolute';
	stats.domElement.style.top = '0px';
	container.appendChild(stats.domElement);

	console.log("Done!");
}


// animation loop
function animate() {
	requestAnimationFrame(animate);
	stats.update();
	timer.update();
	controls.update();

	// Render
	renderer.setClearColorHex(0, 1);
	renderer.autoClear = false;
	renderer.clear();

	// Render
	hud.render(test, 0,0, width,height, 0, 1, THREE.NormalBlending);

	// Material
	tornadoMat.uniforms["camera_matrix"].value = camera.matrix;
	tornadoMat.uniforms["time"].value = timer.time;

	// Render tornado shader
	renderer.setClearColorHex(0, 0);
	renderer.clearTarget(tornadoRT, true, false, false);
	hud.renderTarget = tornadoRT;
	hud.renderMaterial(tornadoMat, 0,0, tornadoW,tornadoH, 0);
	hud.renderTarget = null;

	// Render to screen
	hud.render(test, 0,0, width,height, 0, 1, THREE.NormalBlending); // This renders a background
	hud.render(tornadoRT, 0,0, width,height, 0, 1.0, THREE.NormalBlending, { x: 0, y: 0, w: tornadoW / width, h: tornadoH / height }); // This renders the tornado, set it at 0.5 transparency to see background + overlay
	renderer.render(scene, camera); // This renders the topmost scene (a cube)
}
