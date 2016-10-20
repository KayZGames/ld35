uniform mat4 uViewProjection;
attribute vec3 aPos;
attribute vec3 aNormal;
attribute vec3 aLightDirection;
varying vec3 vPos;
varying vec3 vNormal;
varying vec3 vLightDirection;

void main() {
	gl_Position = uViewProjection * vec4(aPos, 1.0);
	vNormal = aNormal;
	vLightDirection = aLightDirection * 5.0;
	vPos = aPos;
}
