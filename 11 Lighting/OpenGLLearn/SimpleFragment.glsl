
uniform lowp vec3 objectColor;
uniform lowp vec3 lightColor;
uniform lowp vec3 lightPos;

varying lowp vec3 OutNormal;
varying lowp vec3 OutPos;


void main(void) {
    lowp vec3 norm = normalize(OutNormal);
    lowp vec3 lightDir = normalize(lightPos - OutPos);
    lowp float diff = max(dot(norm, lightDir), 0.0);
    lowp float ambientStrength = 0.9;
    gl_FragColor = vec4((ambientStrength + diff) * lightColor * objectColor, 1.0);
}

