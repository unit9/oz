attribute float displacement;
uniform float amplitude;

varying vec2 vUv;

void main()
{
	vUv  = uv;

	vec3 newPosition = position + vec3( uv, 1.0) * vec3( displacement * amplitude );

	gl_Position = projectionMatrix * modelViewMatrix * vec4( newPosition, 1.0 );

}