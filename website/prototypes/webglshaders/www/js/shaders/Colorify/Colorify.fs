uniform sampler2D tDiffuse;
varying vec2 vUv;

vec3 color = vec3 (2.0, 0.7, 0.7);

void main() {

    vec4 texel = texture2D( tDiffuse, vUv );

    vec3 luma = vec3( 0.299, 0.587, 0.114 );
    float v = dot( texel.xyz, luma );

    gl_FragColor = vec4( v * color, texel.w );

}