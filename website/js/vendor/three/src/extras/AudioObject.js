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
 * 	Modified by Plan8 to send values to scsound.js
 */

THREE.AudioObject = function ( eventName ) {

	THREE.Object3D.call( this );

	
	// private properties
	var eventName = eventName;
	var soundPosition = new THREE.Vector3(),
	oldSoundPosition = new THREE.Vector3(),
	oldSoundDelta = new THREE.Vector3(),
	oldSoundUp = new THREE.Vector3(),
	soundDelta = new THREE.Vector3(),
	soundFront = new THREE.Vector3(),
	soundUp = new THREE.Vector3();

	var _this = this;
	this.updateMatrix = function () {
		soundPosition.copy( _this.position );
		soundDelta.sub( soundPosition, oldSoundPosition );
		soundFront.set( 0, 0, -1 );
		this.matrixWorld.rotateAxis( soundFront );
		soundFront.normalize();
		soundUp.copy( this.up );
		if (soundPosition.x == oldSoundPosition.x && soundPosition.y == oldSoundPosition.y && soundPosition.z == oldSoundPosition.z && soundDelta.x == oldSoundDelta.x && soundDelta.y == oldSoundDelta.y && soundDelta.z == oldSoundDelta.z && soundUp.x == oldSoundUp.x && soundUp.y == oldSoundUp.y && soundUp.z == oldSoundUp.z) {
			return;
		}
		SCSound.setPannerPosition(eventName, soundPosition.x, soundPosition.y, soundPosition.z, soundDelta.x, soundDelta.y, soundDelta.z,soundFront.x, soundFront.y, soundFront.z, soundUp.x, soundUp.y, soundUp.z);
		oldSoundPosition.copy( soundPosition );
		oldSoundDelta.copy( soundDelta );
		oldSoundUp.copy( soundUp );

	};

};

THREE.AudioObject.prototype = Object.create( THREE.Object3D.prototype );

THREE.AudioObject.prototype.context = null;
THREE.AudioObject.prototype.type = null;

