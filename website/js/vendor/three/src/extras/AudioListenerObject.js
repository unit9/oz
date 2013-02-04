/**
 * @author alteredq / http://alteredqualia.com/
 *
 * AudioObject
 *
 *	- 3d spatialized sound with Doppler-shift effect
 *
 *	- uses Audio API (currently supported in WebKit-based browsers)
 *		https://dvcs.w3.org/hg/audio/raw-file/tip/webaudio/specification.html
 *
 *	- based on Doppler effect demo from Chromium
 * 		http://chromium.googlecode.com/svn/trunk/samples/audio/doppler.html
 *
 * Modified by Plan8 to send camera position to SCSound.js
 *
 */

THREE.AudioListenerObject = function (camera) {

	THREE.Object3D.call( this );

	// private properties
	var cameraPosition = new THREE.Vector3(),
	oldCameraPosition = new THREE.Vector3(),
	cameraDelta = new THREE.Vector3(),
	cameraFront = new THREE.Vector3(),
	cameraUp = new THREE.Vector3();

	var _this = this;

	this.updateMatrix = function () {
		if (camera.matrixWorld.getPosition().x == oldCameraPosition.x && camera.matrixWorld.getPosition().y == oldCameraPosition.y && camera.matrixWorld.getPosition().z == oldCameraPosition.z) {
			return;
		}
		oldCameraPosition.copy( cameraPosition );
		cameraPosition.copy( camera.matrixWorld.getPosition() );
		cameraDelta.sub( cameraPosition, oldCameraPosition );
		cameraUp.copy( camera.up );
		cameraFront.set( 0, 0, -1 );
		camera.matrixWorld.rotateAxis( cameraFront );
		cameraFront.normalize();
		SCSound.setListenerPosition(cameraPosition.x, cameraPosition.y, cameraPosition.z, cameraDelta.x, cameraDelta.y, cameraDelta.z, cameraFront.x, cameraFront.y, cameraFront.z, cameraUp.x, cameraUp.y, cameraUp.z);
	};
};

THREE.AudioListenerObject.prototype = Object.create( THREE.Object3D.prototype );

THREE.AudioListenerObject.prototype.context = null;
THREE.AudioListenerObject.prototype.type = null;

