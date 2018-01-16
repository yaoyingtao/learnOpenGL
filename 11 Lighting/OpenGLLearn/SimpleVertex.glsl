
attribute vec3 Position;
attribute vec3 Normal;



uniform mat4 Projection;
uniform mat4 Modelview;



varying vec3 OutNormal;
varying vec3 OutPos;


void main(void) {
    OutNormal = Normal;
    OutPos = Position;
    gl_Position = Projection*Modelview*vec4(Position,1.0);
}
