
attribute vec4 Position;
attribute vec3 SourceColor;
attribute vec2 TexturCoord;
attribute vec3 Normal;



uniform mat4 Projection;
uniform mat4 Modelview;



varying vec4 DestinationColor;
varying vec2 DestTexturCoord;
varying vec3 OutNormal;
varying vec3 OutPos;


void main(void) {
   // DestinationColor = vec4(SourceColor, 1.0);
    DestinationColor = vec4(1.0,0,0, 1.0);
    DestTexturCoord = TexturCoord;
    OutNormal = Normal;
    OutPos = vec3(Modelview*Position);
    gl_Position = Projection*Modelview*Position;
}
