precision mediump float;

varying vec3 vPos;

void main() {
	gl_FragColor = vec4(cos(vPos.x) + sin((vPos.z) / 13.0), sin(vPos.y) + sin((vPos.z) / 7.0), sin(vPos.z / 11.0), 1.0);
}
