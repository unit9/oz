
var creature;
var xAxis, yAxis, zAxis;

function initCreature() {
    // Arguments: pos, scale, id, time, alive?
    creature = new Creature(
        V3.$(0,-15,-200), 1, 0, 0, true);

    if (!xAxis) {
        xAxis = V3.$(1, 0, 0);
        yAxis = V3.$(0, 1, 0);
        zAxis = V3.$(0, 0, 1);
    }
}

function drawCreature(){
    creature.update();
    creature.drawWings();

    setShader("creature");
    //bindTexture1('caustics'+localParam.cycle32);
	setMatrixUniforms();
    //bindTexture1('caustics'+localParam.cycle32);
    //creature.drawShadow();
    creature.draw();
}

function Creature(pos,scl,id,time,alive){
  this.pos = pos;
  this.rot = V3.$(0,0,0);
  this.scl = scl;
  this.id = id;
  this.time = time;
  this.alive = alive;
  this.transform = M4x4.makeTranslate3(0, -10, 0);
  this.wingTransform = M4x4.clone(M4x4.I);
}

Creature.prototype.update = function() {
    this.time += 0.1; // TODO: Replace with timestep
    M4x4.makeTranslate3(this.pos[0], this.pos[1], this.pos[2], this.transform);
    M4x4.rotate(this.rot[0], xAxis, this.transform, this.transform);
    M4x4.rotate(this.rot[1], yAxis, this.transform, this.transform);
    M4x4.rotate(this.rot[2], zAxis, this.transform, this.transform);
};

Creature.prototype.drawWings = function() {
    setShader('wing');
    bindTexture0('wingFull');
    bindTexture1('wingAlpha');

    var pos = jfAnimator.interpolatedPivot;
    M4x4.translate3(pos[0], pos[1], pos[2], this.transform, this.wingTransform);

    setMatrixUniforms();
    gl.uniform1f(currentProgram.currentTime, this.time);
    gl.uniformMatrix4fv(currentProgram.uTransform, gl.FALSE, this.wingTransform);

    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
    gl.disable(gl.DEPTH_TEST);
    drawBuffer('wing');
    gl.enable(gl.DEPTH_TEST);
}

Creature.prototype.draw = function(){ 
  if (zoaParam.showJellyfish == 1){    

    setShader("creature");
	
    if (window.jfAnimator) {
        jfAnimator.update();
        setBlendUniform(jfAnimator.blendFactor);
        vertexPositionBuffer['creature'] = jfAnimator.frame0;
        vertexPositionBuffer2['creature'] = jfAnimator.frame1;
    }

    gl.uniformMatrix4fv(currentProgram.uTransform, gl.FALSE, this.transform);

    bindTexture0('creatureColor');
    bindTexture1('panorama');
    bindTexture2('creatureNormals');

    drawBuffer('creature');
  }
}
Creature.prototype.drawShadow = function(){ 
  if (zoaParam.showRays == 1){    
    mTemp = M4x4.clone(mWorld);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE);
    gl.depthMask(false);
    gl.disable(gl.DEPTH_TEST);
    gl.blendEquation(gl.FUNC_REVERSE_SUBTRACT);
	
    setShader("ray");
    bindTexture0('halfBlob');
    var lookAt = new M4x4.$();  
    M4x4.makeLookAt(V3.$(zoaParam.lightPos[0],zoaParam.lightPos[1],zoaParam.lightPos[2]),V3.$(0,0,0),localParam.camera.eye,lookAt);

    setMatrixUniforms();
    pMatrix = M4x4.makeTranslate3(0,0,0);
    M4x4.mul(M4x4.makeLookAt(V3.$(zoaParam.lightPos[0],zoaParam.lightPos[1],zoaParam.lightPos[2]),V3.$(0,0,0),localParam.camera.eye),pMatrix,pMatrix);
    M4x4.scale3(6,180,0,pMatrix,pMatrix);
	  M4x4.scale1(this.scl,pMatrix,pMatrix);

    pPosition = this.pos;
    setParticleUniforms();
	  gl.uniform1f(currentProgram.rAlpha, zoaParam.rAlpha*5);
    drawBuffer('quad');
    gl.uniform1f(currentProgram.rAlpha, zoaParam.rAlpha);
	
    gl.blendEquation(gl.FUNC_ADD);  
    gl.depthMask(true);
    gl.enable(gl.DEPTH_TEST);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
    mWorld = M4x4.clone(mTemp);
  }
}
