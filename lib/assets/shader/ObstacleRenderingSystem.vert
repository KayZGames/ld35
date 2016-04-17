uniform mat4 uViewProjection;
attribute vec3 aPos;

void main() {
	gl_Position = uViewProjection * vec4(aPos, 1.0);
}
