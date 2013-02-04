uniform sampler2D tDiffuse;

varying vec2 vUv;

void main() {

    vec4 color = texture2D( tDiffuse, vUv );

    // calc the dot product and clamp
    // 0 -> 1 rather than -1 -> 1
    vec3 light = vec3(0.5,0.2,1.0);

    // ensure it's normalized
    light = normalize(light);

    // calculate the dot product of
    // the light to the vertex normal
    float dProd = max(0.0, dot( color.rgb, light));

    // feed into our frag colour
    gl_FragColor = vec4(dProd, // R
                        dProd, // G
                        dProd, // B
                        1.0);  // A

    // gl_FragColor = vec4( color.rgb, 1.0 );
}