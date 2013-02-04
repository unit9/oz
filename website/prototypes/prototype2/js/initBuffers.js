var vertexPositionBuffer = {};
var vertexPositionBuffer2 = {};
var vertexNormalBuffer = {};
var vertexColorBuffer = {};
var vertexTextureCoordBuffer = {};
var vertexTextureCoordBuffer2 = {};
var vertexIndexBuffer = {};
var bufferOK = {};
var numBuffersLoading = 6;

function initBuffers(){
  loadObject('axis','meshes/axis.json');
  loadObject('sphere','meshes/sphere.json');
  loadObject('box','meshes/box.json');
  loadObject('quad','meshes/quad.json');
  loadObject('creature', 'meshes/creature.json');
  loadObject('wing', 'meshes/wing.json');
  generate2DGrid('2Dgrid');
  generate3DGrid('3Dgrid')
}

function loadObject(name, file){
  var request = new XMLHttpRequest();
  request.open("GET", file);
  request.onreadystatechange = function() {
    if (request.readyState == 4) {
      initBuffer(name, JSON.parse(request.responseText));
      bufferOK[name] = 1;

      numBuffersLoading--;
      preloader.update();

      if (numBuffersLoading <= 0) {
        bufLoaded = true;
        tryStartAnimation();
      }
    }
  }
  request.send();
}

function generate2DGrid(name) {
   gPositions = [];
   gNormals = [];
   gColor = [];
   gUVs = [];
   for (i=-10;i<=10;i++){
     for (j=-10;j<=10;j=j+20){
       gPositions.push(i); gPositions.push(0); gPositions.push(j);
    gNormals.push(0); gNormals.push(0); gNormals.push(0);
    if(i==-10||i==0||i==10){
      gColor.push(1); gColor.push(1); gColor.push(1);
    }else{
      gColor.push(0.6); gColor.push(0.6); gColor.push(0.6);
    }
    gUVs.push(0); gUVs.push(0); gUVs.push(0);
     }  
   }
   for (i=-10;i<=10;i++){
     for (j=-10;j<=10;j=j+20){
       gPositions.push(j); gPositions.push(0); gPositions.push(i);
    gNormals.push(0); gNormals.push(0); gNormals.push(0);
    if(i==-10||i==0||i==10){
      gColor.push(1); gColor.push(1); gColor.push(1);
    }else{
      gColor.push(0.6); gColor.push(0.6); gColor.push(0.6);
    }
    gUVs.push(0); gUVs.push(0); gUVs.push(0);
     }  
   }

  vertexPositionBuffer[name] = gl.createBuffer();
  vertexNormalBuffer[name] = gl.createBuffer();
  vertexColorBuffer[name] = gl.createBuffer();
  vertexTextureCoordBuffer[name] = gl.createBuffer();
  vertexIndexBuffer[name] = gl.createBuffer();

  gl.bindBuffer(gl.ARRAY_BUFFER, vertexPositionBuffer[name]);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(gPositions), gl.STATIC_DRAW);
  vertexPositionBuffer[name].itemSize = 3;

  gl.bindBuffer(gl.ARRAY_BUFFER, vertexNormalBuffer[name]);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(gNormals), gl.STATIC_DRAW);
  vertexNormalBuffer[name].itemSize = 3;

  gl.bindBuffer(gl.ARRAY_BUFFER, vertexColorBuffer[name]);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(gColor), gl.STATIC_DRAW);
  vertexColorBuffer[name].itemSize = 3;

  gl.bindBuffer(gl.ARRAY_BUFFER, vertexTextureCoordBuffer[name]);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(gUVs), gl.STATIC_DRAW);
  vertexTextureCoordBuffer[name].itemSize = 3;

  vertexIndexBuffer[name].numItems = gPositions.length;
}

function generate3DGrid(name) {
   gPositions = [];
   gNormals = [];
   gColor = [];
   gUVs = [];
   for (i=-10;i<=10;i++){
     for (j=-10;j<=10;j++){
	   for (k=-10;k<=10;k = k + 20){
         gPositions.push(i); gPositions.push(j); gPositions.push(k);
         gNormals.push(0); gNormals.push(0); gNormals.push(0);
         gColor.push(0.6); gColor.push(0.6); gColor.push(0.6);
         gUVs.push(0); gUVs.push(0); gUVs.push(0);
	   }
     }  
   }
   for (i=-10;i<=10;i++){
     for (j=-10;j<=10;j++){
	   for (k=-10;k<=10;k = k + 20){
         gPositions.push(i); gPositions.push(k); gPositions.push(j);
         gNormals.push(0); gNormals.push(0); gNormals.push(0);
         gColor.push(0.6); gColor.push(0.6); gColor.push(0.6);
         gUVs.push(0); gUVs.push(0); gUVs.push(0);
	   }
     }  
   }
   for (i=-10;i<=10;i++){
     for (j=-10;j<=10;j++){
	   for (k=-10;k<=10;k = k + 20){
         gPositions.push(k); gPositions.push(j); gPositions.push(i);
         gNormals.push(0); gNormals.push(0); gNormals.push(0);
         gColor.push(0.6); gColor.push(0.6); gColor.push(0.6);
         gUVs.push(0); gUVs.push(0); gUVs.push(0);
	   }
     }  
   }
	
  vertexPositionBuffer[name] = gl.createBuffer();
  vertexNormalBuffer[name] = gl.createBuffer();
  vertexColorBuffer[name] = gl.createBuffer();
  vertexTextureCoordBuffer[name] = gl.createBuffer();
  vertexIndexBuffer[name] = gl.createBuffer();

  gl.bindBuffer(gl.ARRAY_BUFFER, vertexPositionBuffer[name]);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(gPositions), gl.STATIC_DRAW);
  vertexPositionBuffer[name].itemSize = 3;

  gl.bindBuffer(gl.ARRAY_BUFFER, vertexNormalBuffer[name]);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(gNormals), gl.STATIC_DRAW);
  vertexNormalBuffer[name].itemSize = 3;

  gl.bindBuffer(gl.ARRAY_BUFFER, vertexColorBuffer[name]);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(gColor), gl.STATIC_DRAW);
  vertexColorBuffer[name].itemSize = 3;

  gl.bindBuffer(gl.ARRAY_BUFFER, vertexTextureCoordBuffer[name]);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(gUVs), gl.STATIC_DRAW);
  vertexTextureCoordBuffer[name].itemSize = 3;

  vertexIndexBuffer[name].numItems = gPositions.length;
}

function initBuffer(name, data) {
  console.log('initing', name);
  vertexPositionBuffer[name] = gl.createBuffer();
  vertexNormalBuffer[name] = gl.createBuffer();
  vertexColorBuffer[name] = gl.createBuffer();
  vertexTextureCoordBuffer[name] = gl.createBuffer();
  vertexIndexBuffer[name] = gl.createBuffer();

  if (data.animated == true) {
    var seq_name;

    jfAnimator = new VertexAnimator();

    for (seq_name in data.sequences) {
      var f, numBuffers, buffers = [], seq = data.sequences[seq_name];

      //numBuffers = 20;
      numBuffers = seq.frames.length;

      for (f=0; f<numBuffers; f++) {
          var buf, verts;

          verts = seq.frames[f];

          buf = gl.createBuffer();
          gl.bindBuffer(gl.ARRAY_BUFFER, buf);
          gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(verts), gl.STATIC_DRAW);
          buf.itemSize = 3;
          buf.numItems = verts.length/3;

          buffers[f] = buf;
      }

      jfAnimator.addSequence(seq_name, buffers, seq.pivots);

      vertexPositionBuffer[name] = buffers[0];
      vertexPositionBuffer2[name] = buffers[1];
    }
  }
  else {
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexPositionBuffer[name]);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(data.vertexPositions), gl.STATIC_DRAW);
    vertexPositionBuffer[name].itemSize = 3;
    vertexPositionBuffer[name].numItems = data.vertexPositions.length/3;  
  }

  gl.bindBuffer(gl.ARRAY_BUFFER, vertexNormalBuffer[name]);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(data.vertexNormals), gl.STATIC_DRAW);
  vertexNormalBuffer[name].itemSize = 3;
  vertexNormalBuffer[name].numItems = data.vertexNormals.length/3;

  gl.bindBuffer(gl.ARRAY_BUFFER, vertexColorBuffer[name]);
  vertexColorBuffer[name].itemSize = 3;
  vertexColorBuffer[name].numItems = data.vertexNormals.length/3;
  if (data.vertexColors) {
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(data.vertexColors), gl.STATIC_DRAW);
  }
  else {
    var colors = [],
        len = data.vertexNormals.length;
    while (len--) {
        colors.push(1);
    }

    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(colors), gl.STATIC_DRAW);
  }

  var uvItemSize = (data.vertexTextureCoords.length == vertexPositionBuffer[name].length)? 3 : 2;

  gl.bindBuffer(gl.ARRAY_BUFFER, vertexTextureCoordBuffer[name]);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(data.vertexTextureCoords), gl.STATIC_DRAW);
  vertexTextureCoordBuffer[name].itemSize = uvItemSize;
  vertexTextureCoordBuffer[name].numItems = data.vertexTextureCoords.length/uvItemSize;

  if (data.vertexTextureCoords2) {
    vertexTextureCoordBuffer2[name] = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexTextureCoordBuffer2[name]);
    gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(data.vertexTextureCoords2), gl.STATIC_DRAW);
    vertexTextureCoordBuffer2[name].itemSize = uvItemSize;
    vertexTextureCoordBuffer2[name].numItems = data.vertexTextureCoords2.length/uvItemSize;
  }

  gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, vertexIndexBuffer[name]);
  gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(data.indices), gl.STREAM_DRAW);
  vertexIndexBuffer[name].itemSize = 1;
  vertexIndexBuffer[name].numItems = data.indices.length;
}

function drawBuffer(name){
  if(vertexPositionBuffer[name]){
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexPositionBuffer[name]);
    gl.vertexAttribPointer(currentProgram.vertexPositionAttribute, vertexPositionBuffer[name].itemSize, gl.FLOAT, false, 0, 0);

    if (vertexPositionBuffer2.hasOwnProperty(name)) {
      gl.bindBuffer(gl.ARRAY_BUFFER, vertexPositionBuffer2[name]);
      gl.vertexAttribPointer(currentProgram.vertexPositionAttribute2, vertexPositionBuffer2[name].itemSize, gl.FLOAT, false, 0, 0);
    }

    if (currentProgram.vertexNormalAttribute >= 0) {
        gl.bindBuffer(gl.ARRAY_BUFFER, vertexNormalBuffer[name]);
        gl.vertexAttribPointer(currentProgram.vertexNormalAttribute, vertexNormalBuffer[name].itemSize, gl.FLOAT, false, 0, 0);
    }

    if (currentProgram.vertexColorAttribute >= 0) {
        gl.bindBuffer(gl.ARRAY_BUFFER, vertexColorBuffer[name]);
        gl.vertexAttribPointer(currentProgram.vertexColorAttribute, vertexColorBuffer[name].itemSize, gl.FLOAT, false, 0, 0);
    }

    if (currentProgram.textureCoordAttribute >= 0) {
        gl.bindBuffer(gl.ARRAY_BUFFER, vertexTextureCoordBuffer[name]);
        gl.vertexAttribPointer(currentProgram.textureCoordAttribute, vertexTextureCoordBuffer[name].itemSize, gl.FLOAT, false, 0, 0);
    }

    if (currentProgram.textureCoord2Attribute >= 0) {
        gl.bindBuffer(gl.ARRAY_BUFFER, vertexTextureCoordBuffer2[name]);
        gl.vertexAttribPointer(currentProgram.textureCoord2Attribute, vertexTextureCoordBuffer2[name].itemSize, gl.FLOAT, false, 0, 0);
    }

    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, vertexIndexBuffer[name]);
    gl.drawElements(gl.TRIANGLES, vertexIndexBuffer[name].numItems, gl.UNSIGNED_SHORT, 0);
  }
}

function drawWire(name){
  if(vertexPositionBuffer[name]){
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexPositionBuffer[name]);
    gl.vertexAttribPointer(currentProgram.vertexPositionAttribute, vertexPositionBuffer[name].itemSize, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexNormalBuffer[name]);
    gl.vertexAttribPointer(currentProgram.vertexNormalAttribute, vertexNormalBuffer[name].itemSize, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexColorBuffer[name]);
    gl.vertexAttribPointer(currentProgram.vertexColorAttribute, vertexColorBuffer[name].itemSize, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexTextureCoordBuffer[name]);
    gl.vertexAttribPointer(currentProgram.textureCoordAttribute, vertexTextureCoordBuffer[name].itemSize, gl.FLOAT, false, 0, 0);
    gl.bindBuffer(gl.ARRAY_BUFFER, vertexPositionBuffer[name]);
    gl.drawArrays(gl.LINES, 0, vertexIndexBuffer[name].numItems/3);
  }
}
