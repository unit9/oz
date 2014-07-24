#ifdef GL_ES
precision highp float;
#endif

uniform vec2 resolution;
uniform float time;
uniform sampler2D tDiffuse;

varying vec2 vUv;

void main()
{
    
    vec2 uv;

    vec2 p = vUv.xy - 0.5;

    float a = atan(p.y,p.x);
    float r = sqrt(dot(p,p));
    float s = r * (1.0+0.8*cos(time*1.0));

    uv.x = .02*p.y+.03*cos(-time+a*3.0)/s;
    uv.y = .1*time +.02*p.x+.03*sin(-time+a*3.0)/s;

    float w = .9 + pow(max(1.5-r,0.0),4.0);

    w*=0.6+0.4*cos(time+3.0*a);

    vec3 col =  texture2D(tDiffuse,uv).xyz;

    gl_FragColor = vec4(col,1.0);
}