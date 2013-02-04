#ifdef GL_ES
precision highp float;
#endif

uniform vec2 resolution;
uniform float time;
uniform sampler2D tDiffuse;

varying vec2 vUv;

void main()
{
	vec2 halfres = resolution.xy * vUv.xy / 2.0;
    vec2 cPos = vUv.xy;

    cPos.x -= 0.5 * halfres.x * sin( time / 2.0 ) + 0.3 * halfres.x * cos( time ) + halfres.x;
    cPos.y -= 0.4 * halfres.y * sin( time / 5.0 ) + 0.3 * halfres.y * cos(time) + halfres.y;

    float cLength = length(cPos);

    vec2 uv = vUv.xy + (cPos / cLength) * sin( cLength / 30.0 - time * 10.0 ) / 25.0;
    vec3 col = texture2D( tDiffuse, uv ).xyz;
    // col += vec4(vUv.x, vUv.y, 1.0, 1.0).xyz;

    gl_FragColor = vec4( col, 1.0 );
}
