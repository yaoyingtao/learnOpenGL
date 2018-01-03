
uniform lowp vec3 objectColor;
uniform lowp vec3 lightColor;

void main(void) {
    lowp float ambientStrength = 0.3;
    gl_FragColor = vec4(ambientStrength * objectColor * lightColor, 1.0);
}

