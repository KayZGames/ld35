uniform mat4 uViewProjection;
attribute vec3 aPos;
attribute vec4 aColor;
varying vec4 vColor;

void main() {
	gl_Position = uViewProjection * vec4(aPos, 1.0);
	vColor = aColor;
}
