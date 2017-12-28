
attribute vec4 pos;


uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;


void main(void) {
    gl_Position = projection*view*model*pos;
}
