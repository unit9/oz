/*
uniform float height;
uniform vec2 resolution;
uniform sampler2D tDiffuse;

varying vec2 vUv;

void main()
{
    vec4 color = texture2D( tDiffuse, vUv );
    gl_FragColor = vec4( color.rgb, 1.0 );

}
*/

#ifdef GL_ES
precision highp float;
#endif

uniform sampler2D tDiffuse;
uniform float time;
uniform vec2 resolution;
uniform vec4 mouse;

varying vec2 vUv;

void main(void)
{
    vec2 p = -1.0 + 2.0 * gl_FragCoord.xy / resolution.xy;
    vec2 uv;
   
    float a = atan(p.y,p.x);
    float r = sqrt(dot(p,p));

    uv.x =          7.0*a/3.1416;
    uv.y = -time+ sin(7.0*r+time) + .7*cos(time+7.0*a);

    float w = .5+.5*(sin(time+7.0*r)+ .7*cos(time+7.0*a));

    vec3 col =  texture2D(tDiffuse,uv*.5).xyz;

    gl_FragColor = vec4(col*w,1.0);
}