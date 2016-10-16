uniform mat4 uViewProjection;
attribute vec3 aPos;
attribute vec4 aColor;
attribute vec3 aLightDirection;
varying vec4 vColor;
varying vec3 vLightDirection;

void main() {
	gl_Position = uViewProjection * vec4(aPos, 1.0);
	vColor = aColor;
	vLightDirection = aLightDirection;
}
