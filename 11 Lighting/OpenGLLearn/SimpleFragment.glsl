
uniform lowp vec3 objectColor;
uniform lowp vec3 lightColor;
uniform lowp vec3 lightPos;
uniform lowp vec3 viewPos;


varying lowp vec3 OutNormal;
varying lowp vec3 OutPos;


void main(void) {
    lowp vec3 norm = normalize(OutNormal);
    lowp vec3 lightDir = normalize(lightPos - OutPos);

    lowp float specularStrength = 0.9;
    lowp vec3 viewDir = normalize(viewPos - OutPos);
    lowp vec3 reflectDir = reflect(-lightDir, norm);
    lowp float power = 256.0;
    lowp float spec = pow(max(dot(viewDir, reflectDir), 0.0), power);

    lowp float diff = max(dot(norm, lightDir), 0.0);
    lowp float ambientStrength = 0.9;
    gl_FragColor = vec4((ambientStrength + diff + specularStrength * spec) * lightColor * objectColor, 1.0);
}

