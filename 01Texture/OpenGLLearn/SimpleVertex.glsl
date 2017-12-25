
attribute vec4 Position;
attribute vec3 SourceColor;
attribute vec2 TexturCoord;


uniform mat4 Projection;
uniform mat4 Modelview;



varying vec4 DestinationColor;
varying vec2 DestTexturCoord;

void main(void) {
    DestinationColor = vec4(SourceColor, 1.0);
    DestTexturCoord = TexturCoord;
    gl_Position = Position;
}
