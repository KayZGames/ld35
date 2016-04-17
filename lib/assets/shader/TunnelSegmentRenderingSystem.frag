precision mediump float;

uniform float uTime;
varying vec3 vPos;


void main() {
    float r = cos((10.0 * uTime + vPos.x) / 13.0) + sin(vPos.z / 13.0) + sin((100.0 * uTime + vPos.z) / 11.0);
    float g = sin((10.0 * uTime + vPos.y) / 7.0) + cos(sin(vPos.z / 7.0));
    float b = cos((10.0 * uTime + vPos.y) / 7.0) + sin((50.0 * uTime + vPos.z) / 11.0);

	gl_FragColor = vec4(r, g, b, 1.0);
}
