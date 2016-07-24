precision mediump float;

uniform float uTime;
varying vec3 vPos;


void main() {
    float r = cos((10.0 * uTime + vPos.x) / 13.0) + sin(vPos.z / 13.0) + sin((100.0 * uTime + vPos.z) / 11.0);
    float g = sin((10.0 * uTime + vPos.y) / 7.0) + cos(sin(vPos.z / 7.0));
    float b = cos((10.0 * uTime + vPos.y) / 7.0) + sin((50.0 * uTime + vPos.z) / 11.0);
    float xy = abs(vPos.x) + abs(vPos.y);
    float tunnelStyle = 1.0 - (1.0 + cos(uTime / 5.0)) / 2.0;
    tunnelStyle = tunnelStyle * tunnelStyle;
    r = tunnelStyle * r + (1.0 - tunnelStyle) * (1.0 + sin(vPos.z / 99.0 + xy / 99.0 * vPos.z / 100000.0)) / 2.0;
    g = tunnelStyle * g + (1.0 - tunnelStyle) * (1.0 + sin(vPos.z / 101.0 + xy / 101.0 * vPos.z / 100000.0)) / 2.0;
    b = tunnelStyle * b + (1.0 - tunnelStyle) * (1.0 + sin(vPos.z / 103.0 + xy / 103.0 * vPos.z / 100000.0)) / 2.0;

	gl_FragColor = vec4(r * 0.7, g * 0.7, b * 0.7, 1.0);
}
