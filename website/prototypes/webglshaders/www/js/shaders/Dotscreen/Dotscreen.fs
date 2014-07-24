#ifdef GL_OES_standard_derivatives
#extension GL_OES_standard_derivatives : enable
#endif
 
#ifdef GL_ES
precision highp float;
#endif
 
float uScale = 1.0;  // For imperfect, isotropic anti-aliasing in
float uYrot = 2.0;  // absence of dFdx() and dFdy() functions
uniform sampler2D tDiffuse;
 
varying vec2 vUv;
 
float frequency = 40.0; // Needed globally for lame version of aastep()
 
float aastep(float threshold, float value)
{
	#ifdef GL_OES_standard_derivatives
	  float afwidth = 0.7 * length(vec2(dFdx(value), dFdy(value)));
	#else
	  float afwidth = frequency * (1.0/200.0) / uScale / cos(uYrot);
	#endif
	  return smoothstep(threshold-afwidth, threshold+afwidth, value);
}
 
void main() {
    // Distance to nearest point in a grid of
    // (frequency x frequency) points over the unit square
    vec2 st2 = mat2(0.707, -0.707, 0.707, 0.707) * vUv;
    vec2 nearest = 2.0*fract(frequency * st2) - 1.0;
    float dist = length(nearest);
    // Use a texture to modulate the size of the dots
    vec3 texcolor = texture2D(tDiffuse, vUv).rgb; // Unrotated coords
    float radius = sqrt(1.0-texcolor.g); // Use green channel
    vec3 white = vec3(1.0, 0.0, 0.0);
    vec3 black = vec3(0.0, 0.0, 0.0);
    vec3 fragcolor = mix(black, white, aastep(radius, dist));
    gl_FragColor = vec4(fragcolor, 1.0);
}