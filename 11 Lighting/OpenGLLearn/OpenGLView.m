//
//  OpenGLView.m
//  OpenGLLearn
//
//  Created by tomy yao on 2017/11/17.
//  Copyright © 2017年 tomy yao. All rights reserved.
//

#import "OpenGLView.h"
#import "CC3GLMatrix.h"

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;





float vertices[] = {
    -0.5f, -0.5f, -0.5f,
    0.5f, -0.5f, -0.5f,
    0.5f,  0.5f, -0.5f,
    0.5f,  0.5f, -0.5f,
    -0.5f,  0.5f, -0.5f,
    -0.5f, -0.5f, -0.5f,
    
    -0.5f, -0.5f,  0.5f,
    0.5f, -0.5f,  0.5f,
    0.5f,  0.5f,  0.5f,
    0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f,  0.5f,
    -0.5f, -0.5f,  0.5f,
    
    -0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f, -0.5f,
    -0.5f, -0.5f, -0.5f,
    -0.5f, -0.5f, -0.5f,
    -0.5f, -0.5f,  0.5f,
    -0.5f,  0.5f,  0.5f,
    
    0.5f,  0.5f,  0.5f,
    0.5f,  0.5f, -0.5f,
    0.5f, -0.5f, -0.5f,
    0.5f, -0.5f, -0.5f,
    0.5f, -0.5f,  0.5f,
    0.5f,  0.5f,  0.5f,
    
    -0.5f, -0.5f, -0.5f,
    0.5f, -0.5f, -0.5f,
    0.5f, -0.5f,  0.5f,
    0.5f, -0.5f,  0.5f,
    -0.5f, -0.5f,  0.5f,
    -0.5f, -0.5f, -0.5f,
    
    -0.5f,  0.5f, -0.5f,
    0.5f,  0.5f, -0.5f,
    0.5f,  0.5f,  0.5f,
    0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f,  0.5f,
    -0.5f,  0.5f, -0.5f,
};


const GLubyte indices[] = {
    0, 1, 2,
    0, 2, 3
};


//可以使用两个texture，来使用两个采集器，对两个图片分别处理
//加载图片数据，设置参数，上传

@interface OpenGLView ()
@property (nonatomic, strong) CAEAGLLayer *eaglLayer;
@property (nonatomic, strong) EAGLContext *contex;
@property (nonatomic, assign) GLuint colorRenderBuffer;
@property (nonatomic, assign) GLuint depthRenderBuffer;

@property (nonatomic, assign) GLuint positionSlot;
@property (nonatomic, assign) GLuint colorSlot;
@property (nonatomic, assign) GLuint texureSlot;

@property (nonatomic, assign) GLuint projectionUniform;
@property (nonatomic, assign) GLuint modelViewUniform;
@property (nonatomic, assign) GLuint textureUniform;
@property (nonatomic, assign) GLuint fishUniform;

@property (nonatomic, assign) GLuint floorTexture;
@property (nonatomic, assign) GLuint fishTexture;

@property (nonatomic, assign) float currentRotation;

@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLuint lightProgram;
@property (nonatomic, assign) GLuint objectColorUniform;
@property (nonatomic, assign) GLuint lightColorUniform;

@property (nonatomic, assign) GLuint lightVAO;
@property (nonatomic, assign) GLuint VAO;

@property (nonatomic, assign) GLuint lightModel;
@property (nonatomic, assign) GLuint lightView;
@property (nonatomic, assign) GLuint lightProject;
@property (nonatomic, assign) GLuint lightPos;



@end

@implementation OpenGLView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContex];
        [self setupdepthBuffer];    //必须再renderbuffer之前
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        self.lightProgram = [self compileLightShaders];
        self.program = [self compileShaders];
        [self setupVBO];
//        [self setupDisplayLink];
//        _floorTexture = [self setupTexture:@"tile_floor.png" texure:GL_TEXTURE0];
        _fishTexture = [self setupTexture:@"item_powerup_fish.png" texure:GL_TEXTURE0];
        [self render:nil];
        
    }
    
    return self;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*)self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContex {
    _contex = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    if (!_contex) {
        NSLog(@"failed to create contex opengles 3");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_contex]) {
        NSLog(@"failed to set current opengl context");
        exit(1);
    }
    
}

- (void)setupRenderBuffer {    
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_contex renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupLightVAO {
}

- (void)setupVBO {
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), 0);
    glEnableVertexAttribArray(0);

    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    GLuint VAO;
    glGenVertexArraysOES(1, &VAO);
    self.VAO = VAO;
    glBindVertexArrayOES(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), 0);
    glEnableVertexAttribArray(0);
    
    GLuint lightVAO;
    glGenVertexArraysOES(1, &lightVAO);
    self.lightVAO = lightVAO;
    glBindVertexArrayOES(lightVAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), 0);
    glEnableVertexAttribArray(0);
}

- (void)setupFrameBuffer {
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

- (void)setupdepthBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
}

- (void)render:(CADisplayLink*)displayLink {
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);

    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);


    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    glUseProgram(self.program);

    CC3GLMatrix *projection = [[CC3GLMatrix alloc] initIdentity];
    float h = 4*self.frame.size.height/self.frame.size.width;
    [projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h/2 andTop:h/2 andNear:4 andFar:100];
//    [projection populateOrthoFromFrustumLeft:-2 andRight:2 andBottom:-h/2 andTop:h/2 andNear:0.1 andFar:100];

    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);
    
    
    NSInteger time =  [[NSDate date] timeIntervalSince1970];
    time %=180;
    
    
    
    static NSInteger count = 0;
    CC3Vector camPos = CC3VectorMake(5, 3, -5);
    CC3Vector originPos = CC3VectorMake(0, 0, -1);
    CC3Vector upPos = CC3VectorMake(0, 1, 0);
    
    float radius = 10.0f;
    float camX = sin(time)*radius;
    float camZ = cos(time)*radius;
    CC3GLMatrix *model = [[CC3GLMatrix alloc] initIdentity];
    [model populateToLookAt:originPos withEyeAt:CC3VectorMake(camPos.x + originPos.x, camPos.y + originPos.y, camPos.z + originPos.z) withUp:upPos];
//    [model translateByZ:-5];

//    [model rotateByZ:-time];
//    [model rotateByY:-time];
    glUniformMatrix4fv(_modelViewUniform, 1, 0, model.glMatrix);
    glUniform1i(_textureUniform, 0);
    glUniform1i(_fishUniform, 1);
    glUniform3f(_objectColorUniform, 1.0f, 1.0f, 1.0f);
    glUniform3f(_lightColorUniform, 1.0f, 0.5f, 0.31f);
    glBindVertexArrayOES(self.VAO);

    glDrawArrays(GL_TRIANGLES, 0, 36);
    

    
    glUseProgram(self.lightProgram);
    CC3GLMatrix *model1 = [[CC3GLMatrix alloc] initIdentity];
    CC3GLMatrix *identity = [CC3GLMatrix identity];
    [model1 populateToLookAt:CC3VectorMake(0, 0, 0) withEyeAt:CC3VectorMake(camX, 0, camZ) withUp:CC3VectorMake(0, 1, 0)];


//        [model1 translateByZ:-5-i];


//        [CC3GLMatrix populate:model1.glMatrix toLookAt:originPos withEyeAt:CC3VectorMake(camPos.x + originPos.x, camPos.y + originPos.y, camPos.z + originPos.z) withUp:upPos];
//        [model1 translateByY:130];
//        [model1 translateByX:140];

    [model1 populateOrthoFromFrustumLeft:-2 andRight:2 andBottom:-h/2 andTop:h/2 andNear:0.1 andFar:100];
    [model1 rotateByZ:40];
    [model1 rotateByY:30];
    [model1 scaleByX:0.1];
    [model1 scaleByY:0.1];
    [model1 scaleByZ:0.1];
    [model1 translateBy:CC3VectorMake(13, 3, 0)];
    glUniformMatrix4fv(_lightProject, 1, 0, model1.glMatrix);

    glBindVertexArrayOES(self.lightVAO);
    glDrawArrays(GL_TRIANGLES, 0, 36);



    [_contex presentRenderbuffer:GL_RENDERBUFFER];
}

- (GLuint)compileShaders {
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragementShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];

    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragementShader);
    glLinkProgram(programHandle);

    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }

    glUseProgram(programHandle);

    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    _texureSlot = glGetAttribLocation(programHandle, "TexturCoord");

    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
    
    _textureUniform = glGetUniformLocation(programHandle, "ourTexture");
    _fishUniform = glGetUniformLocation(programHandle, "fishTexture");

    _objectColorUniform = glGetUniformLocation(programHandle, "objectColor");
    _lightColorUniform = glGetUniformLocation(programHandle, "lightColor");

    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    glEnableVertexAttribArray(_texureSlot);
    
    return programHandle;


}

- (GLuint)compileLightShaders {
    GLuint vertexShader = [self compileShader:@"LightSimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragementShader = [self compileShader:@"LightSimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragementShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    glUseProgram(programHandle);
    
    _lightPos = glGetAttribLocation(programHandle, "pos");
    
    _lightModel = glGetUniformLocation(programHandle, "model");
    _lightView = glGetUniformLocation(programHandle, "view");
    _lightProject = glGetUniformLocation(programHandle, "projection");
    
    glEnableVertexAttribArray(_lightPos);
    
    return programHandle;

}

- (void)setupDisplayLink {
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


#pragma mark - tool
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    NSString *shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"error loading shader");
        exit(1);
    }
    
    GLuint shaderHandle = glCreateShader(shaderType);
    
    const char *shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shaderHandle);
    
    GLuint complieSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &complieSuccess);
    if (complieSuccess == GL_FALSE) {
        GLchar message[256];
        glGetShaderInfoLog(shaderHandle, sizeof(message), 0, &message[0]);
        NSString *messageString = [NSString stringWithUTF8String:message];
        NSLog(@"%@", messageString);
        exit(1);
    }
    return shaderHandle;
}

- (GLuint)setupTexture:(NSString*)fileName texure:(NSInteger)index {
    CGImageRef spirteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spirteImage) {
        NSLog(@"fiale to load image");
        exit(1);
    }
    size_t width = CGImageGetWidth(spirteImage);
    size_t height = CGImageGetHeight(spirteImage);
    
    GLubyte *spirteData = (GLubyte*)calloc(width * height * 4, sizeof(GLubyte));
    CGContextRef spriteContext = CGBitmapContextCreate(spirteData, width, height, 8, width * 4, CGImageGetColorSpace(spirteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spirteImage);
    CGContextRelease(spriteContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    glActiveTexture(index);
    glBindTexture(GL_TEXTURE_2D, texName);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spirteData);
    
    free(spirteData);
    return texName;
}


@end
