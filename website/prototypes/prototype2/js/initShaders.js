// JavaScript Document
function getShader(gl, id) {
var shaderScript = document.getElementById(id);
  if (!shaderScript) {
	return null;
  }

  var str = "";
  var k = shaderScript.firstChild;
  while (k) {
	if (k.nodeType == 3) {
	  str += k.textContent;
	}
	k = k.nextSibling;
  }

  var shader;
  if (shaderScript.type == "x-shader/x-fragment") {
	shader = gl.createShader(gl.FRAGMENT_SHADER);
  } else if (shaderScript.type == "x-shader/x-vertex") {
	shader = gl.createShader(gl.VERTEX_SHADER);
  } else {
	return null;
  }

  gl.shaderSource(shader, str);
  gl.compileShader(shader);

  if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
	alert(gl.getShaderInfoLog(shader));
	return null;
  }

  return shader;
}

function createProgram(fragmentShaderID, vertexShaderID) {
  var fragmentShader = getShader(gl, fragmentShaderID);
  var vertexShader = getShader(gl, vertexShaderID);

  var program = gl.createProgram();
  gl.attachShader(program, vertexShader);
  gl.attachShader(program, fragmentShader);
  gl.linkProgram(program);
  if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
	alert("Could not initialise shaders");
  }

  program.vertexPositionAttribute = gl.getAttribLocation(program,   "aVertexPosition");
  if (program.vertexPositionAttribute >= 0)
    gl.enableVertexAttribArray(program.vertexPositionAttribute);

  program.vertexPositionAttribute2 = gl.getAttribLocation(program, 'aVertexPosition2');
  if (program.vertexPositionAttribute2 >= 0)
    gl.enableVertexAttribArray(program.vertexPositionAttribute2);

  program.vertexNormalAttribute = gl.getAttribLocation(program,     "aVertexNormal");
  if (program.vertexNormalAttribute >= 0)
    gl.enableVertexAttribArray(program.vertexNormalAttribute);

  program.vertexColorAttribute = gl.getAttribLocation(program,      "aVertexColor");
  if (program.vertexColorAttribute >= 0)
    gl.enableVertexAttribArray(program.vertexColorAttribute);

  program.textureCoordAttribute = gl.getAttribLocation(program,     "aTextureCoord");
  if (program.textureCoordAttribute >= 0)
    gl.enableVertexAttribArray(program.textureCoordAttribute);

  program.textureCoord2Attribute = gl.getAttribLocation(program, 'aTextureCoord2');
  if (program.textureCoord2Attribute >= 0)
    gl.enableVertexAttribArray(program.textureCoord2Attribute);

  
  program.world = gl.getUniformLocation(program,              "uWorld");
  program.worldView = gl.getUniformLocation(program,          "uWorldView");
  program.worldViewProj = gl.getUniformLocation(program,      "uWorldViewProj");
  program.worldInvTranspose = gl.getUniformLocation(program,  "uWorldInvTranspose");
  program.viewInv = gl.getUniformLocation(program,            "uView");
  program.viewInv = gl.getUniformLocation(program,            "uViewInv");
  
  program.sampler0 = gl.getUniformLocation(program,           "uSampler0");
  program.sampler1 = gl.getUniformLocation(program,           "uSampler1");
  program.sampler2 = gl.getUniformLocation(program,           "uSampler2");
  program.sampler3 = gl.getUniformLocation(program,           "uSampler3");
  
  program.uTransform = gl.getUniformLocation(program, 'uTransform');

  program.uBlendFactor = gl.getUniformLocation(program, 'uBlendFactor');
  program.currentTime = gl.getUniformLocation(program,          "uCurrentTime");
  program.currentJellyfishTime = gl.getUniformLocation(program, "uCurrentJellyfishTime");
  
  program.near = gl.getUniformLocation(program,               "uNear");
  program.far = gl.getUniformLocation(program,                "uFar");
  
  program.lightPos = gl.getUniformLocation(program,           "uLightPos");
  program.lightCol = gl.getUniformLocation(program,           "uLightCol");
  program.specCol = gl.getUniformLocation(program,            "uLightSpecCol");
  program.lightRadius = gl.getUniformLocation(program,        "uLightRadius");
  program.lightSpecPower = gl.getUniformLocation(program,     "uSpecPower");
  program.ambientCol = gl.getUniformLocation(program,         "uAmbientCol");
  program.fogDist = gl.getUniformLocation(program,            "uFogDist");
  program.fogTopCol = gl.getUniformLocation(program,          "uFogTopCol");
  program.fogBottomCol = gl.getUniformLocation(program,       "uFogBottomCol");
  program.fresnelCol = gl.getUniformLocation(program,         "uFresnelCol");
  program.fresnelPow = gl.getUniformLocation(program,         "uFresnelPower");  
  program.shaderDebug = gl.getUniformLocation(program,        "uShaderDebug");

  program.pPosition = gl.getUniformLocation(program,          "uParticlePosition");
  program.pScale = gl.getUniformLocation(program,             "uParticleScale");
  program.pMatrix = gl.getUniformLocation(program,            "uParticleMatrix");
  program.pBbox = gl.getUniformLocation(program,              "uPBbox");
  program.pID = gl.getUniformLocation(program,                "uPID");
  program.pAlpha = gl.getUniformLocation(program,             "uPAlpha");
  program.rAlpha = gl.getUniformLocation(program,             "uRAlpha");
 
  return program;
}

var currentProgram;
var shaderProgram = {};
  
function initShaders() {
  shaderProgram["skybox"] = createProgram("skybox-fs", "skybox-vs");
  shaderProgram["creature"] = createProgram("creature-fs", "creature-vs");
  shaderProgram["vcolor"] = createProgram("vcolor-fs", "vcolor-vs");
  shaderProgram["wire"] = createProgram("wire-fs", "wire-vs");
  shaderProgram["plankton"] = createProgram("plankton-fs", "plankton-vs");
  shaderProgram["ray"] = createProgram("ray-fs", "ray-vs");
  shaderProgram['wing'] = createProgram('wing-fs', 'wing-vs');
  currentProgram = shaderProgram["vcolor"];
  gl.useProgram(currentProgram);
}

function setShader(name){
  currentProgram = shaderProgram[name];
  gl.useProgram(currentProgram);
  setDebugUniforms();
}
