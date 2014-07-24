/**
 * @author Jordi Ros: shine.3p@gmail.com
 * Simple Hud camera renderer for Three.js
 *
 */

var UTILS = UTILS || {};

UTILS.deg2rad = function (angle) {
    return Math.PI * angle / 180;
}

UTILS.rad2deg = function(angle) {
    return 180 * angle / Math.PI;
}

UTILS.lerp = function(step, a, b) {
    return (b-a)*step + a;
}

UTILS.lerp1f = function(step, a, b) {
    step = (step + 1) * 0.5
    return (b-a)*step + a;
}

UTILS.lerpv3 = function(step, a, b, r) {
    r.x = (b.x-a.x)*step + a.x;
    r.y = (b.y-a.y)*step + a.y;
    r.z = (b.z-a.z)*step + a.z;
    return r;
}

UTILS.time01 = function(cur, ini, len) {
    if (len > 0) {
        if (cur > ini) {
            var dt = cur - ini;
            if (dt > len) dt = len;
            return (dt / len);
        }
        return 0;
    }
    return 1;
}

UTILS.time10 = function(cur, ini, len) {
    return 1 - UTILS.time01(cur, ini, len);
}

UTILS.clamp = function(v, min, max) {
    return Math.max(min, Math.min(max, v));
}

var Hud = function(renderer, w, h, flipx, flipy) {
    this.renderer = renderer;
    this.w = w;
    this.h = h;
    this.flipx = flipx;
    this.flipy = flipy;    
    this.renderTarget = null;
    // Scene
    this.defaultMaterial = new THREE.MeshBasicMaterial({ color: 0xffffff });
    this.defaultMaterial.name = "HUD_DefaultMaterial"
    this.plane = new THREE.PlaneGeometry(1, 1);
    this.plane.dynamic = true;
    this.quad  = new THREE.Mesh(this.plane, this.defaultMaterial);
    this.quad.name = "HUD_Quad"
    this.quad.doubleSided = true;
    this.camera = new THREE.OrthographicCamera(0,w, 0,h, 1000, -1000);
    this.scene  = new THREE.Scene();
    this.scene.autoClear = false;
    this.scene.add(this.quad);
    this.scene.add(this.camera);
}

Hud.prototype.resize = function(w, h) {
    if (this.w != w && this.h != h) {
        this.w = w;
        this.h = h;
        this.camera.right  = w;
        this.camera.bottom = h;
        this.camera.updateProjectionMatrix();
        this.camera.updateMatrixWorld();
    }
}

Hud.prototype.renderDef = function(x, y, w, h, rotz, fade, blending, texsrc) {
    if (rotz === undefined) rotz = 0;
    if (fade === undefined) fade = 1;
    if (blending === undefined) blending = THREE.NormalBlending;
    if (texsrc)
        this.setQuadSrc(texsrc.x, texsrc.y, texsrc.w, texsrc.h);
    else
        this.setQuadSrc(0,0, 1,1);        
    this.setQuad(x, y, w, h, rotz);
    this.quad.material.opacity = fade;
    this.quad.material.blending = blending;
    this.quad.material.side = THREE.DoubleSide;
    this.quad.material.transparent = true;
    this.quad.material.depthTest = false;
    this.quad.material.depthWrite = false;
    this.renderer.render(this.scene, this.camera, this.renderTarget, false);
}

Hud.prototype.render = function(texture, x, y, w, h, rotz, fade, blending, texsrc) {
    this.quad.material = this.defaultMaterial;
    this.quad.material.map = texture;
    this.renderDef(x,y, w,h, rotz, fade, blending, texsrc);
}

Hud.prototype.renderMaterial = function(material, x, y, w, h, rotz, fade, blending, texsrc) {
    this.quad.material = material;
    this.renderDef(x,y, w,h, rotz, fade, blending, texsrc);
}

Hud.prototype.setQuadSrc = function(x, y, w, h) {
    this.quad.geometry.faceVertexUvs[0][0][0].set(x,   y);
    this.quad.geometry.faceVertexUvs[0][0][1].set(x,   y+h);
    this.quad.geometry.faceVertexUvs[0][0][2].set(x+w, y+h);
    this.quad.geometry.faceVertexUvs[0][0][3].set(x+w, y);
    this.quad.geometry.__dirtyUvs = true;
    this.quad.geometry.uvsNeedUpdate = true;
}

Hud.prototype.setQuad = function(x, y, w, h, rotz) {
    var xt = x + w*0.5;
    var yt = y + h*0.5;
    var rotx = 0;
    var roty = 0;
    if (this.flipx == true)
    {
        xt = this.w - xt;
        roty = UTILS.deg2rad(180);
    }
    if (this.flipy == true)
    {
        yt = this.h - yt;
        rotx = UTILS.deg2rad(180);
    }
    this.quad.rotation.set(rotx + UTILS.deg2rad(180), roty, rotz);
    this.quad.position.set(xt, yt, 1);
    this.quad.scale.set(w, h, 1);
}
